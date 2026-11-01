import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The top of a page: its [PageTitle] and [PageDescription], 8 px apart.
///
/// Mirrors `PageHeader` in upstream `src/components/ui/page.tsx`.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.children});

  /// The title and description.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d8,
    children: children,
  );
}
