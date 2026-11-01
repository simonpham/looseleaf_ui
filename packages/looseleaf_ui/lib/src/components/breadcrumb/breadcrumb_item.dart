import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One stop on a [BreadcrumbList]: a [BreadcrumbLink] or the
/// [BreadcrumbPage], with anything beside it 6 apart.
///
/// Mirrors `BreadcrumbItem` in upstream `src/components/ui/breadcrumb.tsx`.
class BreadcrumbItem extends StatelessWidget {
  const BreadcrumbItem({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d6,
    children: children,
  );
}
