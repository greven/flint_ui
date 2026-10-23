import { afterEach, describe, expect, it, vi } from "vitest";
import { sound } from "../lib/sound";
import { Sound } from "./sound";

const tick = () => new Promise((resolve) => setTimeout(resolve, 0));

let hook: Sound | null = null;

function mount() {
  const el = document.createElement("div");
  el.id = "flint-sound";
  document.body.appendChild(el);
  hook = new Sound(null, el);
  hook.mounted();
  return hook;
}

afterEach(() => {
  hook?.destroyed();
  hook = null;
  vi.restoreAllMocks();
  document.body.innerHTML = "";
});

describe("Sound hook", () => {
  it("plays an enter cue when a marked element is inserted", async () => {
    const play = vi.spyOn(sound, "play").mockImplementation(() => undefined);
    mount();

    const toast = document.createElement("div");
    toast.setAttribute("data-sound-enter", "bubble");
    document.body.appendChild(toast);
    await tick();

    expect(play).toHaveBeenCalledWith("bubble", expect.anything());
  });

  it("plays an enter cue when an existing element gains the attribute", async () => {
    const play = vi.spyOn(sound, "play").mockImplementation(() => undefined);
    mount();

    const status = document.createElement("span");
    document.body.appendChild(status);
    await tick();
    play.mockClear();

    status.setAttribute("data-sound-enter", "loading");
    await tick();

    expect(play).toHaveBeenCalledWith("loading", expect.anything());
  });

  it("does not replay when the attribute value changes in place", async () => {
    const play = vi.spyOn(sound, "play").mockImplementation(() => undefined);
    mount();

    const status = document.createElement("span");
    status.setAttribute("data-sound-enter", "loading");
    document.body.appendChild(status);
    await tick();
    play.mockClear();

    status.setAttribute("data-sound-enter", "bubble");
    await tick();

    expect(play).not.toHaveBeenCalled();
  });
});
