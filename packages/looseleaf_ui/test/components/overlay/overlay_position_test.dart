import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const Rect _anchor = Rect.fromLTWH(200, 200, 100, 40);
const Size _bounds = Size(800, 600);
const Size _content = Size(160, 80);

OverlayPosition _resolve({
  Rect anchor = _anchor,
  OverlaySide side = OverlaySide.bottom,
  OverlayAlign align = OverlayAlign.center,
  TextDirection textDirection = TextDirection.ltr,
}) => OverlayPosition.resolve(
  anchor: anchor,
  content: _content,
  bounds: _bounds,
  side: side,
  align: align,
  sideOffset: 8,
  collisionPadding: 8,
  textDirection: textDirection,
);

void main() {
  test('each side sits sideOffset away from the anchor', () {
    expect(_resolve().offset, const Offset(170, 248));
    expect(_resolve(side: OverlaySide.top).offset, const Offset(170, 112));
    expect(_resolve(side: OverlaySide.right).offset, const Offset(308, 180));
    expect(_resolve(side: OverlaySide.left).offset, const Offset(32, 180));
  });

  test('start and end align with the anchor edges, mirrored in RTL', () {
    expect(_resolve(align: OverlayAlign.start).offset.dx, 200);
    expect(_resolve(align: OverlayAlign.end).offset.dx, 140);
    expect(
      _resolve(
        align: OverlayAlign.start,
        textDirection: TextDirection.rtl,
      ).offset.dx,
      140,
    );
  });

  test('flips to the other side when there is no room', () {
    final low = _resolve(anchor: const Rect.fromLTWH(200, 540, 100, 40));
    expect(low.side, OverlaySide.top);
    expect(low.offset.dy, 540 - 8 - 80);
    final left = _resolve(
      anchor: const Rect.fromLTWH(10, 200, 40, 40),
      side: OverlaySide.left,
    );
    expect(left.side, OverlaySide.right);
  });

  test('slides along the side to stay inside the padding', () {
    final edge = _resolve(anchor: const Rect.fromLTWH(0, 200, 40, 40));
    expect(edge.offset.dx, 8);
    expect(edge.anchorCenter, 12);
  });

  test('reports where the anchor centre falls on the popup', () {
    expect(_resolve().anchorCenter, 80);
  });
}
