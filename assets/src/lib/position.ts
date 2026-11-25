import {
  arrow,
  autoUpdate,
  computePosition,
  flip,
  offset,
  shift,
  type Middleware,
  type Placement as FloatingPlacement,
} from "@floating-ui/dom";

/**
 * The side of the reference element a floating element is placed on.
 */
export type Side = "top" | "bottom" | "left" | "right";

/**
 * The alignment of a floating element along its side.
 */
export type Align = "start" | "center" | "end";

/**
 * The resolved placement after collision handling. It may differ from the
 * requested placement when the floating element had to flip to stay in view.
 */
export interface Placement {
  side: Side;
  align: Align;
}

export interface PositionOptions {
  /** Preferred side. Defaults to `"top"`. */
  placement?: Side;
  /** Preferred alignment. Defaults to `"center"`. */
  align?: Align;
  /** Gap between the reference and the floating element, in pixels. */
  offset?: number;
  /** Viewport padding every collision middleware keeps free, in pixels. */
  padding?: number;
  /** Optional arrow element to keep aligned with the reference. */
  arrow?: HTMLElement | null;
  /**
   * CSS custom property namespace for the arrow offsets, e.g. `"tooltip"`
   * publishes `--_fl-tooltip-arrow-x` and `--_fl-tooltip-arrow-y`.
   */
  arrowVarPrefix?: string;
}

export interface Positioner {
  /**
   * Positions the floating element once, then keeps it in place while the
   * reference or the viewport scrolls, resizes, or shifts.
   */
  start(): Promise<void>;
  /** Stops tracking. The floating element keeps its last position. */
  stop(): void;
  /** Recomputes the position a single time. */
  update(): Promise<void>;
  /** The last resolved placement. */
  placement(): Placement;
}

const DEFAULT_OFFSET = 6;
const DEFAULT_PADDING = 5;
const ARROW_PADDING = 6;

function toFloatingPlacement(side: Side, align: Align): FloatingPlacement {
  return align === "center" ? side : (`${side}-${align}` as FloatingPlacement);
}

function parsePlacement(value: string, fallbackAlign: Align): Placement {
  const [side, align] = value.split("-") as [Side, Align | undefined];

  return { side, align: align ?? fallbackAlign };
}

/**
 * Positions a floating element next to a reference element.
 */
export function createPositioner(
  reference: HTMLElement,
  floating: HTMLElement,
  options: PositionOptions = {},
): Positioner {
  const {
    placement: requestedSide = "top",
    align: requestedAlign = "center",
    offset: gap = DEFAULT_OFFSET,
    padding = DEFAULT_PADDING,
    arrow: arrowElement = null,
    arrowVarPrefix = "floating",
  } = options;

  let resolved: Placement = { side: requestedSide, align: requestedAlign };
  let stopTracking: (() => void) | null = null;

  function middleware(): Middleware[] {
    const list: Middleware[] = [offset(gap), flip({ padding }), shift({ padding })];

    if (arrowElement) {
      list.push(arrow({ element: arrowElement, padding: ARROW_PADDING }));
    }

    return list;
  }

  function applyArrow(data: { x?: number; y?: number } | undefined): void {
    if (!arrowElement) return;

    if (typeof data?.x === "number") {
      floating.style.setProperty(`--_fl-${arrowVarPrefix}-arrow-x`, `${Math.round(data.x)}px`);
    }

    if (typeof data?.y === "number") {
      floating.style.setProperty(`--_fl-${arrowVarPrefix}-arrow-y`, `${Math.round(data.y)}px`);
    }
  }

  async function update(): Promise<void> {
    const result = await computePosition(reference, floating, {
      strategy: "fixed",
      placement: toFloatingPlacement(requestedSide, requestedAlign),
      middleware: middleware(),
    });

    floating.style.position = "fixed";
    floating.style.inset = "auto";
    floating.style.margin = "0";
    floating.style.left = "0";
    floating.style.top = "0";
    floating.style.transform = `translate3d(${Math.round(result.x)}px, ${Math.round(result.y)}px, 0)`;

    resolved = parsePlacement(result.placement, requestedAlign);

    floating.dataset.side = resolved.side;
    floating.dataset.align = resolved.align;

    applyArrow(result.middlewareData.arrow);
  }

  async function start(): Promise<void> {
    stop();
    await update();

    stopTracking = autoUpdate(
      reference,
      floating,
      () => {
        void update();
      },
      {
        ancestorScroll: true,
        ancestorResize: true,
        elementResize: true,
        layoutShift: true,
        animationFrame: false,
      },
    );
  }

  function stop(): void {
    stopTracking?.();
    stopTracking = null;
  }

  return {
    start,
    stop,
    update,
    placement: () => resolved,
  };
}
