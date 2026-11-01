import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Who said it: small muted hand text after a dash, lined up with the
/// quoted words.
///
/// Mirrors upstream `QuoteAttribution` (`src/components/ui/quote.tsx`).
class QuoteAttribution extends StatelessWidget {
  const QuoteAttribution({super.key, required this.child});

  /// The source, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: Spacing.d52),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 14,
          cssLineHeight: 20 / 14,
          color: theme.colors.inkMuted,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text('— '),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
