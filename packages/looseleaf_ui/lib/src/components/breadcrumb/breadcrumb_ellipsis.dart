import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Stands for the stops left out of a long trail: three dots in a 36
/// square, read as "More".
///
/// Mirrors `BreadcrumbEllipsis` in upstream
/// `src/components/ui/breadcrumb.tsx`.
class BreadcrumbEllipsis extends StatelessWidget {
  const BreadcrumbEllipsis({super.key, this.semanticLabel = 'More'});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticLabel,
    child: const SizedBox.square(
      dimension: Spacing.d36,
      child: Center(child: InkIcon('ellipsis', size: Spacing.d16)),
    ),
  );
}
