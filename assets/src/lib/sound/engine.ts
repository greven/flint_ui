import { CUES } from "./recipes";
import { copySpec, normalizeSpec, specDuration } from "./spec";
import { DEFAULT_THEME, resolveTheme, THEMES } from "./themes";
import type { ThemeName, ThemeTransform } from "./themes";
import type {
  ClusterLayer,
  NoiseLayer,
  PlayHandle,
  PlayOptions,
  Spec,
  ToneLayer,
} from "./types";

export const STORAGE_KEY = "flint:sound";

const DEFAULT_VOLUME = 0.7;
const WET_GAIN = 0.22;
const COOLDOWN_MS = 60;
const FLOOR = 0.0001;

export type ReducedMotion = "mute" | "allow";

export type InitOptions = {
  enabled?: boolean;
  theme?: string | null;
  volume?: number;
  /** `mute` (default) starts silent when the OS asks for reduced motion. */
  reducedMotion?: ReducedMotion;
};

type Performance = {
  bus: GainNode;
  sendBus: GainNode;
  pitch: number;
  length: number;
  air: number;
  space: number;
  scale: number;
  drift: number;
};

function semitones(n: number): number {
  return Math.pow(2, n / 12);
}

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

class SoundEngine {
  private ctx: AudioContext | null = null;
  private master: GainNode | null = null;
  private dry: GainNode | null = null;
  private verb: ConvolverNode | null = null;
  private noiseData: AudioBuffer | null = null;

  private recipes: Record<string, Spec> = { ...CUES };
  private lastPlayed = new Map<string, number>();
  private primed = false;

  private volume = DEFAULT_VOLUME;
  private themeName: ThemeName = DEFAULT_THEME;
  private theme: ThemeTransform = THEMES[DEFAULT_THEME];

  get enabled(): boolean {
    return document.documentElement.dataset.flintSound === "on";
  }

  get currentTheme(): ThemeName {
    return this.themeName;
  }

  get currentVolume(): number {
    return this.volume;
  }

  get cueNames(): string[] {
    return Object.keys(this.recipes);
  }

  init(options: InitOptions = {}): void {
    this.setVolume(options.volume ?? DEFAULT_VOLUME, false);
    this.setTheme(options.theme ?? DEFAULT_THEME, false);

    let enabled = options.enabled ?? false;

    try {
      const stored = localStorage.getItem(STORAGE_KEY);

      if (stored === "on") {
        enabled = true;
      } else if (stored === "off") {
        enabled = false;
      } else if (
        enabled &&
        options.reducedMotion !== "allow" &&
        prefersReducedMotion()
      ) {
        enabled = false;
      }
    } catch {
      // Storage can be unavailable (private mode, blocked cookies).
    }

    this.apply(enabled, false);
    this.prime();
  }

  setEnabled(enabled: boolean): void {
    this.apply(enabled, true);
    this.prime();
  }

  toggle(): void {
    if (this.enabled) {
      this.play("off");
      this.apply(false, true);
    } else {
      this.apply(true, true);
      this.play("on");
    }
  }

  setTheme(name: string | null | undefined, persist = true): void {
    const themeName = resolveTheme(name);
    this.themeName = themeName;
    this.theme = THEMES[themeName];

    if (typeof document === "undefined") return;

    document.documentElement.dataset.soundTheme = themeName;

    document
      .querySelectorAll<HTMLElement>("[data-sound-theme-option]")
      .forEach((el) => {
        el.setAttribute(
          "aria-pressed",
          String(el.dataset.soundThemeOption === themeName),
        );
      });

    if (persist) {
      document.dispatchEvent(
        new CustomEvent("fl:sound:theme:changed", {
          detail: { theme: themeName },
        }),
      );
    }
  }

  setVolume(value: number, persist = true): void {
    this.volume = clamp(Number.isFinite(value) ? value : DEFAULT_VOLUME, 0, 1);
    this.applyGain();

    if (persist && typeof document !== "undefined") {
      document.dispatchEvent(
        new CustomEvent("fl:sound:volume:changed", {
          detail: { volume: this.volume },
        }),
      );
    }
  }

  /** Registers or replaces a cue. `null` removes it. */
  register(name: string, spec: unknown): void {
    if (spec === null) {
      delete this.recipes[name];
      return;
    }

    const normalized = normalizeSpec(spec);
    if (normalized.length) this.recipes[name] = normalized;
  }

  /** A deep copy of a cue, for inspection or re-registration. */
  spec(name: string): Spec | null {
    const spec = this.recipes[name];
    return spec ? copySpec(spec) : null;
  }

  play(name: string, options: PlayOptions = {}): PlayHandle | undefined {
    if (!this.enabled) return undefined;

    const spec = this.recipes[name];
    if (!spec) return undefined;

    const id = options.id ?? name;
    const now = performance.now();
    const last = this.lastPlayed.get(id) ?? -Infinity;
    if (now - last < COOLDOWN_MS) return undefined;
    this.lastPlayed.set(id, now);

    const ctx = this.context();
    if (!ctx) return undefined;

    if (ctx.state === "running") return this.perform(spec, options);

    // The first sound of a session resumes the context; the triggering click
    // counts as user activation.
    void ctx
      .resume()
      .then(() => this.perform(spec, options))
      .catch(() => {});

    return undefined;
  }

  /** Wakes the audio context on the first gesture, so the first real cue is immediate. */
  prime(): void {
    if (this.primed || typeof document === "undefined") return;
    this.primed = true;

    const warm = () => {
      const ctx = this.context();
      if (ctx && ctx.state !== "running") void ctx.resume().catch(() => {});
      document.removeEventListener("pointerdown", warm, true);
      document.removeEventListener("keydown", warm, true);
    };

    document.addEventListener("pointerdown", warm, true);
    document.addEventListener("keydown", warm, true);
  }

  private apply(enabled: boolean, persist: boolean): void {
    const root = document.documentElement;
    // Deliberately not `data-sound`: that is a trigger attribute, and putting it
    // on <html> would make every click match an ancestor cue.
    root.dataset.flintSound = enabled ? "on" : "off";

    if (persist) {
      try {
        localStorage.setItem(STORAGE_KEY, enabled ? "on" : "off");
      } catch {
        // Ignore: the document is still the source of truth for this session.
      }
    }

    document
      .querySelectorAll<HTMLElement>("[data-sound-enable]")
      .forEach((el) => {
        el.setAttribute("aria-pressed", String(enabled));
      });

    this.applyGain();

    document.dispatchEvent(
      new CustomEvent("fl:sound:changed", { detail: { enabled } }),
    );
  }

  private applyGain(): void {
    if (!this.ctx || !this.master) return;
    const gain = this.enabled ? this.volume : 0;
    this.master.gain.setTargetAtTime(gain, this.ctx.currentTime, 0.02);
  }

  private perform(spec: Spec, options: PlayOptions): PlayHandle | undefined {
    const ctx = this.ctx;
    const dry = this.dry;
    const verb = this.verb;
    if (!ctx || !dry || !verb) return undefined;

    const bus = ctx.createGain();
    const sendBus = ctx.createGain();
    sendBus.connect(verb);

    const pan = clamp(options.pan ?? 0, -1, 1);
    if (pan !== 0) {
      const panner = ctx.createStereoPanner();
      panner.pan.value = pan;
      bus.connect(panner);
      panner.connect(dry);
    } else {
      bus.connect(dry);
    }

    const performance: Performance = {
      bus,
      sendBus,
      pitch: options.pitch ?? 0,
      length: clamp(options.length ?? 1, 0.1, 4),
      air: clamp(options.air ?? 1, 0, 4),
      space: clamp(options.space ?? 1, 0, 4),
      scale: clamp(options.volume ?? 1, 0, 1) * (0.92 + Math.random() * 0.16),
      drift: Math.random() * 0.6 - 0.3,
    };

    const once = () => this.runSpec(spec, ctx.currentTime + 0.015, performance);
    once();

    let timer: number | null = null;

    if (options.loop) {
      const period = ((options.every ?? specDuration(spec)) + 0.06) * 1000;
      timer = window.setInterval(
        () => {
          if (!document.hidden) once();
        },
        Math.max(80, period),
      );
    }

    return {
      stop: () => {
        if (timer !== null) {
          clearInterval(timer);
          timer = null;
        }

        const t = ctx.currentTime;
        bus.gain.setTargetAtTime(0, t, 0.02);
        sendBus.gain.setTargetAtTime(0, t, 0.02);

        window.setTimeout(() => {
          bus.disconnect();
          sendBus.disconnect();
        }, 300);
      },
    };
  }

  private runSpec(spec: Spec, t0: number, performance: Performance): void {
    for (const layer of spec) {
      const start = t0 + (layer.at ?? 0);

      if (layer.kind === "tone") this.tone(layer, start, performance);
      else if (layer.kind === "noise") this.noise(layer, start, performance);
      else this.cluster(layer, start, performance);
    }
  }

  private tone(
    layer: ToneLayer,
    start: number,
    performance: Performance,
    plain = false,
  ): void {
    const ctx = this.ctx;
    if (!ctx) return;

    const { theme } = this;
    const ratio =
      theme.pitch * semitones(performance.pitch + performance.drift);
    const frequency = layer.f * ratio;

    const osc = ctx.createOscillator();
    const wave =
      (layer.wave && theme.wave?.[layer.wave]) || layer.wave || "sine";
    osc.type = wave;
    osc.frequency.setValueAtTime(frequency, start);

    if (layer.f2) {
      osc.frequency.exponentialRampToValueAtTime(
        Math.max(20, layer.f2 * ratio),
        start + (layer.glide ?? 0.06),
      );
    }

    const attack = (layer.a ?? 0.004) * theme.attack * performance.length;
    const decay = (layer.d ?? 0.15) * theme.decay * performance.length;
    const env = ctx.createGain();

    envelope(
      env.gain,
      (layer.peak ?? 0.18) * performance.scale,
      start,
      attack,
      decay,
    );

    osc.connect(env).connect(performance.bus);
    this.send(env, layer.send ?? 0, performance);

    osc.start(start);
    osc.stop(start + attack + decay + 0.15);

    if (theme.shimmer && !plain) {
      // Glass grows a quiet inharmonic partial on every pitched voice.
      this.tone(
        {
          ...layer,
          f: layer.f * 2.99,
          f2: layer.f2 ? layer.f2 * 2.99 : null,
          peak: (layer.peak ?? 0.18) * 0.16,
          d: (layer.d ?? 0.15) * 0.8,
        },
        start,
        performance,
        true,
      );
    }
  }

  private noise(
    layer: NoiseLayer,
    start: number,
    performance: Performance,
  ): void {
    const ctx = this.ctx;
    if (!ctx) return;

    const { theme } = this;
    const source = ctx.createBufferSource();
    source.buffer = this.noiseBuffer(ctx);
    source.loop = true;

    const filter = ctx.createBiquadFilter();
    filter.type = layer.filter ?? "bandpass";
    filter.frequency.setValueAtTime((layer.f ?? 2000) * theme.noiseF, start);

    if (layer.f2) {
      filter.frequency.exponentialRampToValueAtTime(
        Math.max(20, layer.f2 * theme.noiseF),
        start + (layer.glide ?? 0.1),
      );
    }

    filter.Q.value = (layer.q ?? 1) * theme.q;

    const attack = (layer.a ?? 0.002) * theme.attack * performance.length;
    const decay =
      (layer.d ?? 0.05) * (theme.decay * 0.7 + 0.3) * performance.length;

    const env = ctx.createGain();
    envelope(
      env.gain,
      (layer.peak ?? 0.15) *
        performance.scale *
        theme.noiseLvl *
        performance.air,
      start,
      attack,
      decay,
    );

    source.connect(filter).connect(env).connect(performance.bus);
    this.send(env, layer.send ?? 0, performance);

    source.start(start, Math.random() * 0.5);
    source.stop(start + attack + decay + 0.1);
  }

  private cluster(
    layer: ClusterLayer,
    start: number,
    performance: Performance,
  ): void {
    const ctx = this.ctx;
    if (!ctx) return;

    const { theme } = this;
    const random = mulberry32(layer.seed ?? 1);
    const ratio =
      theme.pitch * semitones(performance.pitch + performance.drift);
    const count = Math.round(clamp(layer.n, 1, 12));
    const step = layer.step * performance.length;

    for (let i = 0; i < count; i++) {
      const grainStart = start + i * step;
      const frequency =
        (layer.fMin + random() * (layer.fMax - layer.fMin)) * ratio;
      const attack = 0.004 * theme.attack * performance.length;
      const decay = (layer.d ?? 0.1) * theme.decay * performance.length;

      const osc = ctx.createOscillator();
      osc.type = "sine";
      osc.frequency.setValueAtTime(Math.max(20, frequency), grainStart);

      const env = ctx.createGain();
      envelope(
        env.gain,
        (layer.peak ?? 0.04) * performance.scale * performance.air,
        grainStart,
        attack,
        decay,
      );

      osc.connect(env).connect(performance.bus);
      this.send(env, layer.send ?? 0, performance);
      osc.start(grainStart);
      osc.stop(grainStart + attack + decay + 0.1);
    }
  }

  private send(
    node: AudioNode,
    amount: number,
    performance: Performance,
  ): void {
    const ctx = this.ctx;
    if (!ctx) return;

    const level = amount * this.theme.send * performance.space;
    if (level <= 0.01) return;

    const send = ctx.createGain();
    send.gain.value = level;
    node.connect(send);
    send.connect(performance.sendBus);
  }

  private context(): AudioContext | null {
    if (this.ctx) return this.ctx;

    const Ctor =
      window.AudioContext ??
      (window as unknown as { webkitAudioContext?: typeof AudioContext })
        .webkitAudioContext;

    if (!Ctor) return null;

    try {
      const ctx = new Ctor({ latencyHint: "interactive" });

      const master = ctx.createGain();
      master.gain.value = this.enabled ? this.volume : 0;

      const limiter = ctx.createDynamicsCompressor();
      limiter.threshold.value = -10;
      limiter.knee.value = 4;
      limiter.ratio.value = 12;
      limiter.attack.value = 0.002;
      limiter.release.value = 0.12;

      master.connect(limiter);
      limiter.connect(ctx.destination);

      const dry = ctx.createGain();
      dry.connect(master);

      const verb = ctx.createConvolver();
      verb.buffer = makeImpulse(ctx, 1.4, 3.2);

      const wet = ctx.createGain();
      wet.gain.value = WET_GAIN;
      verb.connect(wet);
      wet.connect(master);

      this.ctx = ctx;
      this.master = master;
      this.dry = dry;
      this.verb = verb;

      return ctx;
    } catch {
      return null;
    }
  }

  private noiseBuffer(ctx: AudioContext): AudioBuffer {
    if (this.noiseData) return this.noiseData;

    const length = Math.floor(ctx.sampleRate);
    const buffer = ctx.createBuffer(1, length, ctx.sampleRate);
    const data = buffer.getChannelData(0);

    for (let i = 0; i < length; i++) data[i] = Math.random() * 2 - 1;

    this.noiseData = buffer;
    return buffer;
  }
}

/** Exponential decay from `peak` to silence. Never ramps to exactly zero. */
function envelope(
  param: AudioParam,
  peak: number,
  start: number,
  attack: number,
  decay: number,
): void {
  const level = Math.max(peak, FLOOR);
  const attackEnd = start + Math.max(attack, 0.0005);

  param.setValueAtTime(FLOOR, start);
  param.linearRampToValueAtTime(level, attackEnd);
  param.exponentialRampToValueAtTime(FLOOR, attackEnd + Math.max(decay, 0.002));
}

/** A short, synthesized room: decaying noise, no assets. */
function makeImpulse(
  ctx: AudioContext,
  duration: number,
  decay: number,
): AudioBuffer {
  const length = Math.floor(ctx.sampleRate * duration);
  const buffer = ctx.createBuffer(2, length, ctx.sampleRate);

  for (let channel = 0; channel < 2; channel++) {
    const data = buffer.getChannelData(channel);
    for (let i = 0; i < length; i++) {
      data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / length, decay);
    }
  }

  return buffer;
}

/** Deterministic grain positions for cluster layers. */
function mulberry32(seed: number): () => number {
  let s = seed >>> 0;

  return () => {
    s |= 0;
    s = (s + 0x6d2b79f5) | 0;
    let t = Math.imul(s ^ (s >>> 15), 1 | s);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function prefersReducedMotion(): boolean {
  return (
    typeof window !== "undefined" &&
    typeof window.matchMedia === "function" &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches
  );
}

export const sound = new SoundEngine();

/** Plays a cue by name, honoring the global `data-sound` switch. */
export function playSound(
  name: string,
  options?: PlayOptions,
): PlayHandle | undefined {
  return sound.play(name, options);
}

export type { ThemeName };
