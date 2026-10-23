/**
 * Types for the synthesized sound layer.
 *
 * A cue ("spec") is a list of layers rendered through one shared
 * `AudioContext`. Specs are adapted from Foley (MIT); see `recipes.ts`.
 */

export type Wave = "sine" | "triangle" | "square" | "sawtooth";
export type FilterType = "bandpass" | "lowpass" | "highpass";

export type ToneLayer = {
  kind: "tone";
  /** Seconds to wait before this layer starts. */
  at?: number;
  wave?: Wave;
  /** Start frequency in Hz. */
  f: number;
  /** Optional end frequency; glides across `glide`. */
  f2?: number | null;
  glide?: number;
  /** Attack in seconds. */
  a?: number;
  /** Decay in seconds. */
  d?: number;
  /** Peak gain, relative to the performance scale. */
  peak?: number;
  /** Reverb send (0-1). */
  send?: number;
};

export type NoiseLayer = {
  kind: "noise";
  at?: number;
  filter?: FilterType;
  f: number;
  f2?: number | null;
  glide?: number;
  q?: number;
  a?: number;
  d?: number;
  peak?: number;
  send?: number;
};

export type ClusterLayer = {
  kind: "cluster";
  at?: number;
  /** Number of grains. */
  n: number;
  /** Seconds between grains. */
  step: number;
  fMin: number;
  fMax: number;
  d?: number;
  peak?: number;
  send?: number;
  seed?: number;
};

export type Layer = ToneLayer | NoiseLayer | ClusterLayer;
export type Spec = Layer[];

/** The four perceptual dials, plus volume and stereo placement. */
export type Macros = {
  /** Semitones, -12 to 12. */
  pitch?: number;
  /** Decay/attack multiplier, 0.4 to 2.5. */
  length?: number;
  /** Noise/click level multiplier, 0 to 2. */
  air?: number;
  /** Reverb send multiplier, 0 to 2. */
  space?: number;
  /** Level multiplier, 0 to 1. */
  volume?: number;
  /** Stereo placement, -1 (left) to 1 (right). */
  pan?: number;
};

export type PlayOptions = Macros & {
  loop?: boolean;
  every?: number;
  /** Cooldown key. Defaults to the cue name. */
  id?: string;
};

export type PlayHandle = { stop: () => void };
