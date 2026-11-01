import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../support/fixture_frames.dart';

/// Token names upstream emits that no stylesheet defines (a CSS no-op).
const _undefinedTokens = {'undefined'};

void main() {
  final frames = FixtureFrame.load();
  const colors = LooseleafColors();

  test('the fixtures cover every element kind the engine emits', () {
    final markup = frames.expand((frame) => frame.parts.values).join();
    for (final tag in [
      '<path',
      '<g',
      '<use',
      '<defs>',
      '<clipPath',
      '<mask',
      '<linearGradient',
      '<pattern',
      '<rect',
      'mix-blend-mode',
      'stroke-dasharray',
      'pathLength',
      'data-hide-on',
      '--mx',
    ]) {
      expect(markup, contains(tag), reason: tag);
    }
  });

  for (final frame in frames) {
    test('parses ${frame.name} and resolves every reference', () {
      final document = InkDocument.parseLayers(frame.parts);
      expect(document.layers.keys, frame.parts.keys);
      void check(InkNode node) {
        final effects = node.effects;
        if (effects.clipPathId case final id?) {
          expect(document.defs[id], isA<InkClipPathDef>(), reason: id);
        }
        if (effects.maskId case final id?) {
          final def = document.defs[id];
          expect(
            def is InkMaskDef || GrainMask.parse(id) != null,
            isTrue,
            reason: 'mask $id',
          );
        }
        for (final paint in [node.style.fill, node.style.stroke]) {
          switch (paint) {
            case InkTokenPaint(:final token):
              expect(
                colors.token(token) != null || _undefinedTokens.contains(token),
                isTrue,
                reason: 'token $token',
              );
            case InkUrlPaint(:final id):
              expect(document.defs[id], isNotNull, reason: 'paint $id');
            default:
          }
        }
        switch (node) {
          case InkGroupNode(:final children):
            children.forEach(check);
          case InkUseNode(:final href):
            expect(document.elements[href], isNotNull, reason: 'use $href');
          default:
        }
      }

      document.layers.values.forEach(check);
      for (final def in document.defs.values) {
        switch (def) {
          case InkClipPathDef(:final children) ||
              InkMaskDef(:final children) ||
              InkPatternDef(:final children):
            children.forEach(check);
          case InkGradientDef(:final stops):
            for (final stop in stops) {
              if (stop.color case InkTokenPaint(:final token)) {
                expect(colors.token(token), isNotNull, reason: token);
              }
            }
        }
      }
    });
  }

  test('rejects unknown elements, attributes and styles', () {
    expect(() => InkDocument.parse('<foo/>'), throwsA(isA<InkMarkupError>()));
    expect(
      () => InkDocument.parse('<path d="M0 0" bogus="1"/>'),
      throwsA(isA<InkMarkupError>()),
    );
    expect(
      () => InkDocument.parse('<g style="filter:blur(2px)"></g>'),
      throwsA(isA<InkMarkupError>()),
    );
    expect(
      () => InkDocument.parse('<path d="M0 0" fill="hsl(1 2 3)"/>'),
      throwsA(isA<InkMarkupError>()),
    );
    expect(
      () => InkDocument.parse('<g transform="perspective(2)"></g>'),
      throwsA(isA<InkMarkupError>()),
    );
  });
}
