import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { autoUpdate, computePosition } from "@floating-ui/dom";
import { createPositioner } from "./position";

vi.mock("@floating-ui/dom", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@floating-ui/dom")>();

  return {
    ...actual,
    computePosition: vi.fn(),
    autoUpdate: vi.fn(() => vi.fn()),
  };
});

const compute = vi.mocked(computePosition);
const track = vi.mocked(autoUpdate);

interface Result {
  x: number;
  y: number;
  placement: string;
  middlewareData: { arrow?: { x?: number; y?: number } };
}

function result(overrides: Partial<Result> = {}): Result {
  return {
    x: 10.4,
    y: 20.6,
    placement: "top-start",
    middlewareData: {},
    ...overrides,
  };
}

function setup(options: Parameters<typeof createPositioner>[2] = {}) {
  const reference = document.createElement("button");
  const floating = document.createElement("div");
  const arrowElement = document.createElement("span");
  floating.appendChild(arrowElement);

  const positioner = createPositioner(reference, floating, options);

  return { reference, floating, arrowElement, positioner };
}

beforeEach(() => {
  compute.mockReset();
  track.mockReset();
  track.mockReturnValue(vi.fn());
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe("createPositioner", () => {
  it("maps side and alignment onto a floating-ui placement", async () => {
    compute.mockResolvedValue(result() as never);
    const { positioner } = setup({ placement: "bottom", align: "end" });

    await positioner.update();

    expect(compute).toHaveBeenCalledWith(
      expect.anything(),
      expect.anything(),
      expect.objectContaining({ placement: "bottom-end", strategy: "fixed" }),
    );
  });

  it("centers by omitting the alignment from the placement", async () => {
    compute.mockResolvedValue(result() as never);
    const { positioner } = setup({ placement: "left" });

    await positioner.update();

    expect(compute).toHaveBeenCalledWith(
      expect.anything(),
      expect.anything(),
      expect.objectContaining({ placement: "left" }),
    );
  });

  it("builds the collision middleware in order", async () => {
    compute.mockResolvedValue(result() as never);
    const arrowElement = document.createElement("span");
    const { positioner } = setup({ offset: 12, padding: 8, arrow: arrowElement });

    await positioner.update();

    const { middleware } = compute.mock.calls[0]![2] as unknown as {
      middleware: { name: string; options: unknown }[];
    };

    expect(middleware.map((entry) => entry.name)).toEqual([
      "offset",
      "flip",
      "shift",
      "arrow",
    ]);
    expect(middleware[0]!.options).toBe(12);
    expect(middleware[1]!.options).toEqual({ padding: 8 });
    expect(middleware[2]!.options).toEqual({ padding: 8 });
  });

  it("omits the arrow middleware when there is no arrow element", async () => {
    compute.mockResolvedValue(result() as never);
    const { positioner } = setup({ arrow: null });

    await positioner.update();

    const { middleware } = compute.mock.calls[0]![2] as unknown as {
      middleware: { name: string }[];
    };

    expect(middleware.map((entry) => entry.name)).not.toContain("arrow");
  });

  it("anchors the floating element at the origin with a rounded translate", async () => {
    compute.mockResolvedValue(result() as never);
    const { floating, positioner } = setup();

    await positioner.update();

    expect(floating.style.position).toBe("fixed");
    expect(floating.style.left).toBe("0px");
    expect(floating.style.top).toBe("0px");
    expect(floating.style.transform).toBe("translate3d(10px, 21px, 0)");
    expect(floating.style.margin).toBe("0px");
  });

  it("publishes the resolved side and alignment after a flip", async () => {
    compute.mockResolvedValue(result({ placement: "bottom" }) as never);
    const { floating, positioner } = setup({ placement: "top" });

    await positioner.update();

    expect(floating.dataset.side).toBe("bottom");
    expect(floating.dataset.align).toBe("center");
    expect(positioner.placement()).toEqual({ side: "bottom", align: "center" });
  });

  it("publishes the arrow offset as CSS variables", async () => {
    compute.mockResolvedValue(
      result({ middlewareData: { arrow: { x: 4.6 } } }) as never,
    );
    const arrowElement = document.createElement("span");
    const { floating, positioner } = setup({
      arrow: arrowElement,
      arrowVarPrefix: "tooltip",
    });

    await positioner.update();

    expect(floating.style.getPropertyValue("--_fl-tooltip-arrow-x")).toBe("5px");
    expect(floating.style.getPropertyValue("--_fl-tooltip-arrow-y")).toBe("");
  });

  it("keeps tracking with autoUpdate until stopped", async () => {
    compute.mockResolvedValue(result() as never);
    const cleanup = vi.fn();
    track.mockReturnValue(cleanup);
    const { reference, floating, positioner } = setup();

    await positioner.start();

    expect(track).toHaveBeenCalledWith(
      reference,
      floating,
      expect.any(Function),
      expect.objectContaining({ ancestorScroll: true, layoutShift: true }),
    );

    positioner.stop();

    expect(cleanup).toHaveBeenCalledTimes(1);
  });
});
