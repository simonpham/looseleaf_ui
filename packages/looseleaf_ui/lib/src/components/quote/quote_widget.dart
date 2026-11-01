import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A pull quote: a [QuoteText] with its marks in the gutters and an
/// optional [QuoteAttribution] below, 10 px apart, as wide as the words.
///
/// ```dart
/// const Quote(
///   children: [
///     QuoteText(child: Text('The best time to write it down was when it happened.')),
///     QuoteAttribution(child: Text('Ada, in the margin of a book')),
///   ],
/// )
/// ```
///
/// Mirrors upstream `Quote` (`src/components/ui/quote.tsx`).
class Quote extends StatelessWidget {
  const Quote({super.key, required this.children});

  /// Usually a [QuoteText] and a [QuoteAttribution].
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d10,
      children: children,
    ),
  );
}
