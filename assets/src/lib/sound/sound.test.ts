import { describe, expect, it } from "vitest";
import { CUES } from "./recipes";
import { normalizeSpec, specDuration } from "./spec";
import { DEFAULT_THEME, THEMES } from "./themes";

describe("sound spec", () => {
  it("ships a non-empty spec for every cue", () => {
    for (const [name, spec] of Object.entries(CUES)) {
      expect(spec.length, name).toBeGreaterThan(0);
      expect(specDuration(spec), name).toBeGreaterThan(0);
    }
  });

  it("normalizes the shipped catalog without dropping layers", () => {
    for (const [name, spec] of Object.entries(CUES)) {
      expect(normalizeSpec(spec).length, name).toBe(spec.length);
    }
  });

  it("clamps out-of-range values and drops unknown layers", () => {
    const spec = normalizeSpec([
      { kind: "tone", f: 440, at: 99, peak: 99, d: 99 },
      { kind: "noise", f: 2000, q: 0 },
      { kind: "nope" },
      { kind: "cluster", n: 99, step: 99, fMin: 900, fMax: 100 },
    ]);

    expect(spec).toHaveLength(3);

    const [tone, noise, cluster] = spec;
    expect(tone).toMatchObject({ kind: "tone", at: 1.5, peak: 0.4, d: 2.5 });
    expect(noise).toMatchObject({ kind: "noise", q: 0.3 });
    expect(cluster).toMatchObject({ kind: "cluster", n: 12, step: 0.2 });
  });

  it("defaults to the untransformed theme", () => {
    expect(DEFAULT_THEME).toBe("default");
    expect(THEMES.default.pitch).toBe(1);
    expect(THEMES.soft.pitch).toBe(0.8);
    expect(THEMES.glass.shimmer).toBe(true);
  });
});
