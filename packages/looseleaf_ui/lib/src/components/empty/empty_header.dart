import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The media, title and description of an [Empty], centered at most
/// 384 wide with 8 between them.
///
/// Mirrors `EmptyHeader` in upstream `src/components/ui/empty.tsx`.
class EmptyHeader extends StatelessWidget {
  const EmptyHeader({super.key, required this.children});

  final List<Widget> children;

  /// `max-w-sm`.
  static const double maxWidth = 384;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: maxWidth),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d8,
      children: children,
    ),
  );
}
