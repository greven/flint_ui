import type { Wave } from "./types";

/**
 * A theme reshapes every cue with one transform.
 *
 * Adapted from Foley (https://github.com/eakbulut/foley), MIT License,
 * Copyright (c) 2026 eakbulut and Foley contributors. See NOTICE.md.
 */
export type ThemeTransform = {
  label: string;
  /** Waveform substitutions, e.g. soft turns sawtooth into triangle. */
  wave: Partial<Record<Wave, Wave>> | null;
  pitch: number;
  attack: number;
  decay: number;
  send: number;
  noiseLvl: number;
  noiseF: number;
  q: number;
  /** Glass adds a quiet inharmonic partial to pitched voices. */
  shimmer: boolean;
};

function mkTheme(overrides: Partial<ThemeTransform>): ThemeTransform {
  return {
    label: "",
    wave: null,
    pitch: 1,
    attack: 1,
    decay: 1,
    send: 1,
    noiseLvl: 1,
    noiseF: 1,
    q: 1,
    shimmer: false,
    ...overrides,
  };
}

export const THEMES = {
  default: mkTheme({ label: "Default" }),
  soft: mkTheme({
    label: "Soft",
    wave: { sawtooth: "triangle", square: "sine", triangle: "sine" },
    pitch: 0.8,
    attack: 2.6,
    decay: 1.45,
    send: 1.5,
    noiseLvl: 0.5,
    noiseF: 0.7,
    q: 0.7,
  }),
  mechanical: mkTheme({
    label: "Mechanical",
    attack: 0.55,
    decay: 0.5,
    send: 0.25,
    noiseLvl: 1.6,
    noiseF: 1.25,
    q: 1.6,
  }),
  glass: mkTheme({
    label: "Glass",
    pitch: 1.45,
    attack: 0.7,
    decay: 1.6,
    send: 1.7,
    noiseLvl: 0.45,
    noiseF: 1.9,
    q: 3.2,
    shimmer: true,
  }),
} as const;

export type ThemeName = keyof typeof THEMES;

/** The untransformed palette. Pass a theme name to reshape it. */
export const DEFAULT_THEME: ThemeName = "default";

export const THEME_NAMES = Object.keys(THEMES) as ThemeName[];

export function isThemeName(name: unknown): name is ThemeName {
  return typeof name === "string" && name in THEMES;
}

export function resolveTheme(name?: string | null): ThemeName {
  return isThemeName(name) ? name : DEFAULT_THEME;
}
