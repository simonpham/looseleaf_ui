import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

typedef _Json = Map<String, dynamic>;

double _d(Object? v) => (v as num).toDouble();

double? _od(Object? v) => switch (v) {
  final num x => x.toDouble(),
  _ => null,
};

T _by<T extends Enum>(List<T> values, Object? id, [String Function(T)? key]) =>
    values.firstWhere((v) => (key?.call(v) ?? v.name) == id);

List<LayerName> _layers(Object? v) => [
  for (final n in v as List? ?? const []) LayerName.values.byName(n as String),
];

final class _Entry<P> {
  _Entry(this.recipe, this.decode, this.json);

  final Recipe<P> recipe;
  final P Function(_Json p) decode;
  final Map<String, Object?> Function(P p) json;

  (RawFrame, String) run(_Json c) {
    final params = decode(c['params'] as _Json);
    final knobs = c['knobs'] as _Json;
    final frame = runRecipe(
      recipe,
      RunRequest<P>(
        box: Box(_d(c['w']), _d(c['h'])),
        params: params,
        seed: c['seed'] as String,
        tier: Tier.values.byName(c['tier'] as String),
        density: Density.values.byName(c['density'] as String),
        dir: Dir.values.byName(c['dir'] as String),
        knobs: Knobs(
          wobble: _d(knobs['wobble']),
          misreg: _d(knobs['misreg']),
          bleed: _d(knobs['bleed']),
          width: _d(knobs['width']),
        ),
        lazy: _layers(c['lazy']),
        lazyOnly: c['lazyOnly'] == true,
        pad: _od(c['pad']),
      ),
    );
    return (frame, stableStringify(json(params)));
  }
}

_Entry<NoParams> _none(Recipe<NoParams> recipe) =>
    _Entry<NoParams>(recipe, (_) => const NoParams(), (p) => p.toJson());

final Map<String, _Entry<Object?>> _entries = {
  'attachment': _Entry<AttachmentParams>(
    attachmentRecipe,
    (p) => AttachmentParams(
      state: _by(AttachmentState.values, p['state']),
      orientation: _by(AttachmentOrientation.values, p['orientation']),
      interactive: p['interactive'] as bool?,
    ),
    (p) => p.toJson(),
  ),
  'attachment-media': _Entry<AttachmentMediaParams>(
    attachmentMediaRecipe,
    (p) => AttachmentMediaParams(
      state: _by(AttachmentState.values, p['state']),
      variant: _by(AttachmentMediaVariant.values, p['variant']),
    ),
    (p) => p.toJson(),
  ),
  'attachment-progress': _Entry<AttachmentProgressParams>(
    attachmentProgressRecipe,
    (p) => AttachmentProgressParams(
      indeterminate: p['indeterminate'] as bool?,
    ),
    (p) => p.toJson(),
  ),
  'bubble': _Entry<BubbleParams>(
    bubbleRecipe,
    (p) => BubbleParams(
      variant: _by(BubbleVariant.values, p['variant'], (v) => v.id),
      tail: _by(BubbleTail.values, p['tail']),
      pen: switch (p['pen']) {
        final String pen => _by(BubblePen.values, pen),
        _ => null,
      },
      interactive: p['interactive'] as bool?,
    ),
    (p) => p.toJson(),
  ),
  'bubble-reactions': _Entry<BubbleReactionsParams>(
    bubbleReactionsRecipe,
    (p) => BubbleReactionsParams(dashed: p['dashed'] as bool?),
    (p) => p.toJson(),
  ),
  'carousel-tick': _Entry<CarouselTickParams>(
    carouselTickRecipe,
    (p) => CarouselTickParams(
      slash: p['slash'] as bool,
      pitch: _d(p['pitch']),
    ),
    (p) => p.toJson(),
  ),
  'code-block-rule': _none(codeRuleRecipe),
  'code-block-body': _none(codeBodyRecipe),
  'corkboard': _Entry<CorkBoardParams>(
    corkBoardRecipe,
    (p) => CorkBoardParams(frame: _od(p['frame'])),
    (p) => p.toJson(),
  ),
  'corkboard-pin': _Entry<CorkPinParams>(
    corkPinRecipe,
    (p) => CorkPinParams(color: _by(PaintKey.values, p['color'], (k) => k.id)),
    (p) => p.toJson(),
  ),
  'corkboard-note': _none(corkNoteRecipe),
  'dropzone': _Entry<DropzoneParams>(
    dropzoneRecipe,
    (p) => DropzoneParams(
      over: p['over'] as bool?,
      invalid: p['invalid'] as bool?,
      disabled: p['disabled'] as bool?,
    ),
    (p) => p.toJson(),
  ),
  'dropzone-item': _Entry<DropzoneItemParams>(
    dropzoneItemRecipe,
    (p) => DropzoneItemParams(
      status: _by(DropzoneItemStatus.values, p['status']),
    ),
    (p) => p.toJson(),
  ),
  'empty-frame': _none(emptyFrameRecipe),
  'empty-media': _none(emptyMediaRecipe),
  'flip-card-trigger': _Entry<FlipTriggerParams>(
    flipTriggerRecipe,
    (p) => FlipTriggerParams(hint: p['hint'] as bool?),
    (p) => p.toJson(),
  ),
  'peel-corner-flap': _Entry<PeelFlapParams>(
    peelFlapRecipe,
    (p) => PeelFlapParams(
      back: switch (p['back']) {
        final String b => _by(PaintKey.values, b, (k) => k.id),
        _ => null,
      },
      mirror: p['mirror'] as bool?,
    ),
    (p) => p.toJson(),
  ),
  'peel-corner-trigger': _none(peelTriggerRecipe),
};

void main() {
  final fixture =
      jsonDecode(
            File('test/fixtures/marks_surfaces.json').readAsStringSync(),
          )
          as _Json;
  for (final c in (fixture['frames'] as List).cast<_Json>()) {
    test(c['name'], () {
      final entry = _entries[c['recipe']];
      if (entry == null) fail('no entry for ${c['recipe']}');
      final (frame, key) = entry.run(c);
      final out = c['out'] as _Json;
      expect(key, c['key']);
      expect(frame.layers.map((l) => l.name), out['layers']);
      expect(frame.lazyLayers.map((l) => l.name), out['lazyLayers']);
      expect([frame.pad, frame.w, frame.h], [out['pad'], out['w'], out['h']]);
      final parts = out['parts'] as _Json;
      expect(frame.parts.keys.map((k) => k.name), parts.keys);
      for (final MapEntry(:key, :value) in parts.entries) {
        expect(frame.parts[LayerName.values.byName(key)], value, reason: key);
      }
    });
  }
}
