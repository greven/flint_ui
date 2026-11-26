/**
 * Pointer "grace" geometry for floating menus.
 *
 * A submenu is offset from its trigger, so the pointer has to cross a gap
 * before it reaches the panel. While that happens it may also pass over the
 * parent menu's chrome or a sibling row. Instead of guessing with a close
 * timeout, the hook builds a buffered corridor from the point where the pointer
 * left the trigger to the near edge of the panel. The panel stays open while
 * the pointer is inside that corridor and closes as soon as it leaves.
 */

export interface Point {
  x: number;
  y: number;
}

/** How far the corridor extends beyond the pointer path and the panel edge. */
export const GRACE_BUFFER = 12;

/**
 * Builds the corridor between `exit` and the near edge of `target`.
 *
 * The near edge is chosen from the relative centers of the trigger and the
 * target, so a submenu that flips to the left and a menu that opens above or
 * below the trigger all produce a sensible corridor. A zero-sized target (a
 * panel that has not been laid out or is closed) yields an empty polygon.
 */
export function getGracePolygon(
  exit: Point,
  trigger: DOMRect,
  target: DOMRect,
  buffer = GRACE_BUFFER,
): Point[] {
  if (target.width === 0 && target.height === 0) return [];

  const triggerX = trigger.left + trigger.width / 2;
  const triggerY = trigger.top + trigger.height / 2;
  const targetX = target.left + target.width / 2;
  const targetY = target.top + target.height / 2;

  // The larger center delta picks the axis the pointer has to travel along,
  // which is also the side of the panel that faces the trigger. The base sits
  // on that edge. The apex sits just behind the exit point so the pointer is
  // already well inside the corridor when the boundary event fires.
  if (Math.abs(targetX - triggerX) >= Math.abs(targetY - triggerY)) {
    const edge = targetX >= triggerX ? target.left : target.right;
    const apexX = exit.x + (targetX >= triggerX ? -buffer : buffer);

    return [
      { x: apexX, y: exit.y - buffer },
      { x: edge, y: target.top - buffer },
      { x: edge, y: target.bottom + buffer },
      { x: apexX, y: exit.y + buffer },
    ];
  }

  const edge = targetY >= triggerY ? target.top : target.bottom;
  const apexY = exit.y + (targetY >= triggerY ? -buffer : buffer);

  return [
    { x: exit.x - buffer, y: apexY },
    { x: target.left - buffer, y: edge },
    { x: target.right + buffer, y: edge },
    { x: exit.x + buffer, y: apexY },
  ];
}

/**
 * Returns whether `point` is inside `polygon`, using the ray-casting rule.
 * Boundary handling is not exact, which is fine for a buffered grace area.
 */
export function isPointInPolygon(point: Point, polygon: Point[]): boolean {
  let inside = false;

  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const a = polygon[i];
    const b = polygon[j];

    if (!a || !b) continue;

    const crosses = a.y > point.y !== b.y > point.y;
    const edgeX = ((b.x - a.x) * (point.y - a.y)) / (b.y - a.y) + a.x;

    if (crosses && point.x < edgeX) inside = !inside;
  }

  return inside;
}
