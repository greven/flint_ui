import { Sound } from "./components/sound";

export { Sound };

/** Register this object alongside the core hooks to enable `FlintUI.Sound`. */
export const hooks = {
  "FlintUI.Sound": Sound,
};

export * from "./lib/sound";
