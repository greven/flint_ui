import {
  afterAll,
  beforeAll,
  beforeEach,
  describe,
  expect,
  it,
  vi,
} from "vitest";
import { sound } from "./engine";

class FakeParam {
  value = 0;
  setValueAtTime = vi.fn();
  linearRampToValueAtTime = vi.fn();
  exponentialRampToValueAtTime = vi.fn();
  setTargetAtTime = vi.fn();
}

class FakeNode {
  connect = vi.fn(() => this);
  disconnect = vi.fn();
}

class FakeGain extends FakeNode {
  gain = new FakeParam();
}

class FakeOscillator extends FakeNode {
  type = "sine";
  frequency = new FakeParam();
  detune = new FakeParam();
  start = vi.fn();
  stop = vi.fn();
}

class FakeFilter extends FakeNode {
  type = "bandpass";
  frequency = new FakeParam();
  Q = new FakeParam();
}

class FakeBufferSource extends FakeNode {
  buffer: unknown = null;
  loop = false;
  start = vi.fn();
  stop = vi.fn();
}

class FakeBuffer {
  constructor(private readonly channels: number) {}
  duration = 1;
  getChannelData() {
    return new Float32Array(128);
  }
  get numberOfChannels() {
    return this.channels;
  }
}

class FakeAudioContext {
  state = "running";
  currentTime = 0;
  sampleRate = 48000;
  destination = new FakeNode();
  oscillators: FakeOscillator[] = [];

  resume = vi.fn(async () => {
    this.state = "running";
  });

  createGain() {
    return new FakeGain();
  }
  createOscillator() {
    const osc = new FakeOscillator();
    this.oscillators.push(osc);
    return osc;
  }
  createBiquadFilter() {
    return new FakeFilter();
  }
  createBufferSource() {
    return new FakeBufferSource();
  }
  createConvolver() {
    return Object.assign(new FakeNode(), { buffer: null });
  }
  createStereoPanner() {
    return Object.assign(new FakeNode(), { pan: new FakeParam() });
  }
  createDynamicsCompressor() {
    return Object.assign(new FakeNode(), {
      threshold: new FakeParam(),
      knee: new FakeParam(),
      ratio: new FakeParam(),
      attack: new FakeParam(),
      release: new FakeParam(),
    });
  }
  createBuffer(channels: number) {
    return new FakeBuffer(channels);
  }
}

const context = new FakeAudioContext();

describe("sound engine", () => {
  beforeAll(() => {
    (window as unknown as { AudioContext: unknown }).AudioContext =
      function () {
        return context;
      };
  });

  beforeEach(() => {
    context.oscillators = [];
    localStorage.clear();
    sound.init({ enabled: true });
  });

  afterAll(() => {
    delete (window as unknown as { AudioContext?: unknown }).AudioContext;
  });

  it("enables from the provider and schedules a cue", () => {
    expect(sound.enabled).toBe(true);

    sound.play("tap");

    expect(context.oscillators.length).toBeGreaterThan(0);
  });

  it("does not put a trigger attribute on the document root", () => {
    // `data-sound` is a trigger attribute. On <html> it would match
    // `closest("[data-sound]")` for every click in the document.
    expect(document.documentElement.dataset.flintSound).toBe("on");
    expect(document.documentElement.hasAttribute("data-sound")).toBe(false);
  });

  it("stays silent while disabled", () => {
    sound.setEnabled(false);
    context.oscillators = [];
    sound.play("tap");

    expect(context.oscillators).toHaveLength(0);
  });

  it("applies the dials without throwing", () => {
    sound.play("press", {
      pitch: -4,
      length: 1.4,
      air: 0.5,
      space: 1.8,
      pan: -0.4,
    });

    expect(context.oscillators.length).toBeGreaterThan(0);
  });

  it("registers and removes custom cues", () => {
    sound.register("boop", [{ kind: "tone", f: 440 }]);
    sound.play("boop");
    expect(context.oscillators.length).toBeGreaterThan(0);

    sound.register("boop", null);
    expect(sound.spec("boop")).toBeNull();
  });

  it("returns a copy of a cue", () => {
    const spec = sound.spec("success");
    expect(spec).not.toBeNull();
    expect(spec).not.toBe(sound.spec("success"));
  });
});
