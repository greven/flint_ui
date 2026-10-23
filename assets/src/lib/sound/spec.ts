import type {
  ClusterLayer,
  FilterType,
  NoiseLayer,
  Spec,
  ToneLayer,
  Wave,
} from "./types";

const LIMITS = {
  at: [0, 1.5],
  f: [40, 8000],
  f2: [40, 8000],
  glide: [0.005, 1],
  a: [0, 0.5],
  d: [0.005, 2.5],
  peak: [0, 0.4],
  send: [0, 1],
  q: [0.3, 12],
  n: [1, 12],
  step: [0, 0.2],
  fMin: [40, 8000],
  fMax: [40, 8000],
} satisfies Record<string, [number, number]>;

type NumericKey = keyof typeof LIMITS;

const WAVES: Wave[] = ["sine", "triangle", "square", "sawtooth"];
const FILTERS: FilterType[] = ["bandpass", "lowpass", "highpass"];
const MAX_LAYERS = 8;

function clampNum(value: unknown, key: NumericKey, fallback?: number): number {
  const [lo, hi] = LIMITS[key];
  const n = Number(value);
  if (!Number.isFinite(n)) return fallback ?? lo;
  return Math.min(hi, Math.max(lo, n));
}

function num(value: unknown, key: NumericKey, fallback?: number): number {
  return clampNum(value, key, fallback);
}

/**
 * Validates and clamps a spec into a safe, playable copy.
 * Unknown kinds are dropped, unknown fields stripped, at most 8 layers.
 */
export function normalizeSpec(input: unknown): Spec {
  if (!Array.isArray(input)) return [];

  const out: Spec = [];

  for (const raw of input) {
    if (!raw || typeof raw !== "object") continue;

    const layer = raw as Record<string, unknown>;
    const at = num(layer.at, "at", 0);

    if (layer.kind === "tone") {
      const tone: ToneLayer = {
        kind: "tone",
        at,
        wave: WAVES.includes(layer.wave as Wave)
          ? (layer.wave as Wave)
          : "sine",
        f: num(layer.f, "f", 440),
        f2: layer.f2 ? num(layer.f2, "f2") : null,
        glide: num(layer.glide, "glide", 0.06),
        a: num(layer.a, "a", 0.004),
        d: num(layer.d, "d", 0.15),
        peak: num(layer.peak, "peak", 0.15),
        send: num(layer.send, "send", 0),
      };
      out.push(tone);
    } else if (layer.kind === "noise") {
      const noise: NoiseLayer = {
        kind: "noise",
        at,
        filter: FILTERS.includes(layer.filter as FilterType)
          ? (layer.filter as FilterType)
          : "bandpass",
        f: num(layer.f, "f", 2000),
        f2: layer.f2 ? num(layer.f2, "f2") : null,
        glide: num(layer.glide, "glide", 0.1),
        q: num(layer.q, "q", 1),
        a: num(layer.a, "a", 0.002),
        d: num(layer.d, "d", 0.05),
        peak: num(layer.peak, "peak", 0.12),
        send: num(layer.send, "send", 0),
      };
      out.push(noise);
    } else if (layer.kind === "cluster") {
      const fMin = num(layer.fMin, "fMin", 1600);
      const cluster: ClusterLayer = {
        kind: "cluster",
        at,
        n: Math.round(num(layer.n, "n", 5)),
        step: num(layer.step, "step", 0.035),
        fMin,
        fMax: Math.max(fMin, num(layer.fMax, "fMax", 4600)),
        d: num(layer.d, "d", 0.1),
        peak: num(layer.peak, "peak", 0.04),
        send: num(layer.send, "send", 0.5),
        seed: Math.round(Number(layer.seed)) || 1,
      };
      out.push(cluster);
    }

    if (out.length >= MAX_LAYERS) break;
  }

  return out;
}

/** The audible length of a spec in seconds, before theme/macro scaling. */
export function specDuration(spec: Spec): number {
  let end = 0;

  for (const layer of spec) {
    const at = layer.at ?? 0;
    const tail =
      layer.kind === "cluster"
        ? (layer.n - 1) * layer.step + (layer.d ?? 0.1) + 0.01
        : (layer.a ?? 0.004) + (layer.d ?? 0.15);

    if (at + tail > end) end = at + tail;
  }

  return end;
}

/** A deep copy, safe to hand to app code that may edit it. */
export function copySpec(spec: Spec): Spec {
  return JSON.parse(JSON.stringify(spec)) as Spec;
}
