import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/separator/separator.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A pencil line between fields of a [FieldGroup], with an optional word
/// in it ("or", "then"). It pulls its neighbours 8 px closer.
///
/// Mirrors `FieldSeparator` in upstream `src/components/ui/field.tsx`.
class FieldSeparator extends StatelessWidget {
  const FieldSeparator({super.key, this.child, this.seed});

  /// The word in the line.
  final Widget? child;

  /// Pins the line's hand.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      height: Spacing.d20,
      child: Center(
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 14,
            cssLineHeight: 20 / 14,
          ),
          child: Separator(seed: seed, child: child),
        ),
      ),
    );
  }
}
