import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The mark between two stops of a [BreadcrumbList]: a pencil slash, or
/// any [child]. Hidden from screen readers.
///
/// Mirrors `BreadcrumbSeparator` in upstream
/// `src/components/ui/breadcrumb.tsx`.
class BreadcrumbSeparator extends StatelessWidget {
  const BreadcrumbSeparator({super.key, this.child});

  /// Replaces the slash, such as `InkIcon('chevron-right')`.
  final Widget? child;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: InkContent(
      style: TextStyle(color: LooseleafTheme.of(context).colors.pencilMark),
      iconSize: Spacing.d16,
      child: child ?? const InkIcon('slash', size: Spacing.d16),
    ),
  );
}
