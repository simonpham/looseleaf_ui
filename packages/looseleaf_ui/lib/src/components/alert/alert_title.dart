import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An alert's title: bold, on one line.
///
/// Mirrors `AlertTitle` in upstream `src/components/ui/alert.tsx`
/// (`line-clamp-1 min-h-4 font-bold`).
class AlertTitle extends StatelessWidget {
  const AlertTitle(this.child, {super.key});

  /// The title, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: const TextStyle(fontWeight: FontWeight.w700),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Spacing.d16),
      child: child,
    ),
  );
}
