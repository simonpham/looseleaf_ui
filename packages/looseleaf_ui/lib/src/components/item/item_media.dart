import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/item/item.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The picture at the start of an [InkItem]: an icon in a shaded pencil
/// square, a small turned photo, or anything as given. It moves to the top
/// when the row has a description.
///
/// Mirrors `ItemMedia` in upstream `src/components/ui/item.tsx`.
class ItemMedia extends StatefulWidget {
  const ItemMedia({
    super.key,
    required this.child,
    this.variant = ItemMediaVariant.regular,
    this.seed,
  });

  /// The icon, image or avatar.
  final Widget child;

  final ItemMediaVariant variant;

  /// Picks the pencil frame of the icon square.
  final String? seed;

  @override
  State<ItemMedia> createState() => _ItemMediaState();
}

class _ItemMediaState extends State<ItemMedia> with InkSeed {
  static const _shadeAlpha = 0.75;
  static const _outlineOpacity = 0.8;
  static const _oddTurn = -1 * math.pi / 180;
  static const _evenTurn = 0.8 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final media = switch (widget.variant) {
      ItemMediaVariant.regular => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d8,
        children: [widget.child],
      ),
      ItemMediaVariant.icon => _icon(context),
      ItemMediaVariant.image => _image(context),
    };
    if (!ItemRowScope.describedOf(context)) return media;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d2),
      child: media,
    );
  }

  Widget _icon(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    return CustomPaint(
      painter: ItemPainter(
        frame: ItemFrame.of(inkSeed(widget.seed)),
        kind: ItemPaint.outline,
        color: colors.pencil,
        opacity: _outlineOpacity,
        theme: theme,
      ),
      child: ColoredBox(
        color: colors.paperShade.withValues(
          alpha: colors.paperShade.a * _shadeAlpha,
        ),
        child: SizedBox.square(
          dimension: Spacing.d36,
          child: IconTheme.merge(
            data: const IconThemeData(size: Spacing.d16),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }

  Widget _image(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final odd = (ItemScope.maybeOf(context)?.index ?? 0).isEven;
    final turn = switch ((theme.density, odd)) {
      (LooseleafDensity.calm, _) => 0.0,
      (_, true) => _oddTurn,
      (_, false) => _evenTurn,
    };
    return Transform.rotate(
      angle: turn,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.photo,
          boxShadow: [
            BoxShadow(
              color: colors.shade.withValues(alpha: 0.16 * theme.shadowK),
              offset: const Offset(0, Spacing.d1),
              blurRadius: 1.5,
            ),
          ],
        ),
        child: SizedBox.square(
          dimension: Spacing.d40,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.d2),
            child: ClipRect(
              child: SizedBox.expand(
                child: FittedBox(fit: BoxFit.cover, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
