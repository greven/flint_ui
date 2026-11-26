import { describe, expect, it } from "vitest";
import { getGracePolygon, isPointInPolygon } from "./geometry";

function rect(left: number, top: number, width: number, height: number): DOMRect {
  return {
    left,
    top,
    width,
    height,
    right: left + width,
    bottom: top + height,
    x: left,
    y: top,
    toJSON: () => ({}),
  } as DOMRect;
}

describe("getGracePolygon", () => {
  it("builds a buffered corridor from the exit point to a right-hand panel", () => {
    const polygon = getGracePolygon(
      { x: 218, y: 118 },
      rect(100, 100, 120, 30),
      rect(260, 120, 160, 80),
    );

    expect(polygon).toEqual([
      { x: 206, y: 106 },
      { x: 260, y: 108 },
      { x: 260, y: 212 },
      { x: 206, y: 130 },
    ]);
    expect(isPointInPolygon({ x: 240, y: 150 }, polygon)).toBe(true);
    expect(isPointInPolygon({ x: 330, y: 150 }, polygon)).toBe(false);
    expect(isPointInPolygon({ x: 160, y: 150 }, polygon)).toBe(false);
  });

  it("uses the near edge when the panel flips to the left", () => {
    const polygon = getGracePolygon(
      { x: 302, y: 118 },
      rect(300, 100, 120, 30),
      rect(100, 120, 160, 80),
    );

    expect(polygon[1]).toEqual({ x: 260, y: 108 });
    expect(polygon[2]).toEqual({ x: 260, y: 212 });
    expect(isPointInPolygon({ x: 280, y: 150 }, polygon)).toBe(true);
    expect(isPointInPolygon({ x: 380, y: 150 }, polygon)).toBe(false);
  });

  it("builds a corridor below and above the trigger", () => {
    const below = getGracePolygon(
      { x: 150, y: 131 },
      rect(100, 100, 120, 30),
      rect(100, 200, 200, 120),
    );

    expect(below[1]).toEqual({ x: 88, y: 200 });
    expect(below[2]).toEqual({ x: 312, y: 200 });
    expect(isPointInPolygon({ x: 160, y: 170 }, below)).toBe(true);
    expect(isPointInPolygon({ x: 300, y: 170 }, below)).toBe(false);

    const above = getGracePolygon(
      { x: 150, y: 301 },
      rect(100, 300, 120, 30),
      rect(100, 100, 200, 80),
    );

    expect(above[1]).toEqual({ x: 88, y: 180 });
    expect(above[2]).toEqual({ x: 312, y: 180 });
    expect(isPointInPolygon({ x: 160, y: 250 }, above)).toBe(true);
    expect(isPointInPolygon({ x: 300, y: 250 }, above)).toBe(false);
  });

  it("returns an empty polygon for a panel that has no layout", () => {
    expect(getGracePolygon({ x: 0, y: 0 }, rect(100, 100, 120, 30), rect(0, 0, 0, 0))).toEqual([]);
  });
});
