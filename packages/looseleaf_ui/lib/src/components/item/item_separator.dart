import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/item/item.dart';
import 'package:looseleaf_ui/src/components/separator/separator.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A line between rows of an [ItemGroup]: a ruled pencil line by default,
/// any [Separator] look otherwise.
///
/// Mirrors `ItemSeparator` in upstream `src/components/ui/item.tsx`.
class ItemSeparator extends StatefulWidget {
  const ItemSeparator({
    super.key,
    this.variant = SeparatorVariant.pencil,
    this.orientation = SeparatorOrientation.horizontal,
    this.decorative = true,
    this.seed,
    this.child,
  });

  final SeparatorVariant variant;
  final SeparatorOrientation orientation;

  /// Hidden from screen readers when true.
  final bool decorative;

  /// Picks the pencil frame.
  final String? seed;

  /// A label in the line; draws a [Separator].
  final Widget? child;

  @override
  State<ItemSeparator> createState() => _ItemSeparatorState();
}

class _ItemSeparatorState extends State<ItemSeparator> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final pencil =
        widget.variant == SeparatorVariant.pencil &&
        widget.orientation == SeparatorOrientation.horizontal &&
        widget.child == null;
    if (!pencil) {
      return Separator(
        variant: widget.variant,
        orientation: widget.orientation,
        decorative: widget.decorative,
        seed: widget.seed,
        child: widget.child,
      );
    }
    final theme = LooseleafTheme.of(context);
    final line = CustomPaint(
      painter: ItemPainter(
        frame: ItemFrame.of(inkSeed(widget.seed)),
        kind: ItemPaint.separator,
        color: theme.colors.pencil,
        opacity: switch (theme.density) {
          LooseleafDensity.calm => 0.5,
          _ => 0.75,
        },
        theme: theme,
      ),
      child: const SizedBox(width: double.infinity, height: Spacing.d1),
    );
    if (widget.decorative) return ExcludeSemantics(child: line);
    return Semantics(container: true, child: line);
  }
}
