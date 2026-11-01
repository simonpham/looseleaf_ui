import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A page's body: a column of [children], 16 px apart.
///
/// Mirrors `PageContent` in upstream `src/components/ui/page.tsx`.
class PageContent extends StatelessWidget {
  const PageContent({super.key, required this.children});

  /// Paragraphs and whatever else the page holds.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d16,
    children: children,
  );
}
