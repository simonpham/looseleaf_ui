import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/sticker_sheet/sticker_sheet.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A sheet of die-cut stickers on backing paper: each sticker sits in its
/// kiss-cut line, curls a corner up on hover or focus, and peels off with
/// a tap, a key or a pull, leaving the cut line behind.
///
/// Give [stickers] by name, or [children] ([StickerSheetItem]s) for ids,
/// labels or sizes of their own. They sit in [columns] cells of [size] + 22
/// px. A [title] adds a header with how many are left. Which are peeled is
/// yours with [peeled] and [onPeeledChange], or the sheet's own starting at
/// [defaultPeeled]. [onPeel] and [onStick] hear each change, with where a
/// pull let go (to drop the sticker on a `StickerBoard`). Peeled stickers
/// stick back on a tap unless not [restorable].
///
/// ```dart
/// StickerSheet(
///   title: 'Sticker sheet no. 4',
///   stickers: const ['rocket', 'cloud', 'sun', 'planet'],
///   onPeel: (peel) => print(peel.label),
/// )
/// ```
///
/// Mirrors `StickerSheet` in upstream `src/components/ui/sticker-sheet.tsx`.
class StickerSheet extends StatefulWidget {
  const StickerSheet({
    super.key,
    this.stickers = const [],
    this.children,
    this.columns = 4,
    this.size = 72,
    this.title,
    this.backing = StickerSheetBacking.glassine,
    this.peeled,
    this.defaultPeeled = const [],
    this.onPeeledChange,
    this.onPeel,
    this.onStick,
    this.restorable = true,
    this.disabled = false,
    this.label = 'Sticker sheet',
    this.tilt = true,
    this.seed,
  });

  /// The stickers by name, when there are no [children].
  final List<String> stickers;

  /// The items; [stickers] when null.
  final List<StickerSheetItem>? children;

  /// Cells per row.
  final int columns;

  /// The stickers' size in pixels.
  final double size;

  /// The header; none when null.
  final String? title;

  /// The backing paper.
  final StickerSheetBacking backing;

  /// The peeled ids; the sheet keeps its own when null.
  final List<String>? peeled;

  /// The starting peeled ids, when [peeled] is null.
  final List<String> defaultPeeled;

  /// Called with every peeled id after a change.
  final ValueChanged<List<String>>? onPeeledChange;

  /// Called when a sticker comes off.
  final ValueChanged<StickerSheetPeel>? onPeel;

  /// Called when a sticker goes back on.
  final ValueChanged<StickerSheetPeel>? onStick;

  /// Peeled stickers can be stuck back.
  final bool restorable;

  /// Nothing can be peeled; the sheet fades to 70%.
  final bool disabled;

  /// The accessible name when there is no [title].
  final String label;

  /// The seeded resting tilt of the sheet.
  final bool tilt;

  /// Pins the hand.
  final String? seed;

  /// The cell side for stickers of [size].
  static double cellOf(double size) => JsMath.round(size + 22);

  @override
  State<StickerSheet> createState() => _StickerSheetState();
}

class _StickerSheetState extends State<StickerSheet> with InkSeed {
  late List<String> _inner = widget.defaultPeeled;
  late List<String> _latest = _peeled;

  List<String> get _peeled => widget.peeled ?? _inner;

  List<StickerSheetItem> get _items =>
      widget.children ??
      [for (final name in widget.stickers) StickerSheetItem(name: name)];

  void _change(List<String> next) {
    _latest = next;
    if (widget.peeled == null) setState(() => _inner = next);
    widget.onPeeledChange?.call(next);
  }

  void _peel(StickerSheetPeel item) {
    if (_latest.contains(item.id)) return;
    _change([..._latest, item.id]);
    widget.onPeel?.call(item);
    _say('${item.label} peeled off.');
  }

  void _stick(StickerSheetPeel item) {
    if (!_latest.contains(item.id)) return;
    _change([
      for (final id in _latest)
        if (id != item.id) id,
    ]);
    widget.onStick?.call(item);
    _say('${item.label} stuck back on.');
  }

  void _say(String message) => SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
  );

  int get _left {
    final here = {
      for (final item in _items)
        if (hasSticker(item.name)) item.id ?? item.name,
    };
    return math.max(0, here.length - here.where(_peeled.contains).length);
  }

  @override
  Widget build(BuildContext context) {
    _latest = _peeled;
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final title = widget.title;
    final header = switch (title) {
      null => 0.0,
      _ => Spacing.d34,
    };
    final columns = math.max(1, widget.columns);
    final items = _items;
    final caption = theme.typography.face(
      KevinSansFace.type,
      cssSize: 14,
      cssLineHeight: 20 / 14,
      color: theme.colors.pencilText,
    );
    final sheet = Paper(
      stock: widget.backing.stock,
      tilt: widget.tilt,
      seed: seed,
      padding: const EdgeInsets.all(Spacing.d16),
      decor: StickerSheetPrint(
        backing: widget.backing,
        top: header,
        seed: seed,
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.d6,
                  0,
                  Spacing.d6,
                  Spacing.d8,
                ),
                child: SizedBox(
                  height: Spacing.d24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    spacing: Spacing.d12,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ExcludeSemantics(
                        child: Text(
                          '$_left left',
                          style: caption.copyWith(
                            fontSize: 12 * KevinSansFace.type.sizeAdjust,
                            height: 16 / 12 / KevinSansFace.type.sizeAdjust,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(Spacing.d8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d4,
                children: [
                  for (var row = 0; row * columns < items.length; row++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Spacing.d4,
                      children: [
                        for (final item
                            in items.skip(row * columns).take(columns))
                          item,
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: title ?? widget.label,
      child: StickerSheetScope(
        peeled: _peeled,
        peel: _peel,
        stick: _stick,
        size: widget.size,
        restorable: widget.restorable,
        disabled: widget.disabled,
        child: Opacity(
          opacity: switch (widget.disabled) {
            true => 0.7,
            false => 1,
          },
          child: sheet,
        ),
      ),
    );
  }
}
