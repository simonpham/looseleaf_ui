import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A shortcut made of several keys, such as Ctrl + K: [children] in a row
/// with a small gap.
///
/// ```dart
/// const KbdGroup(children: [Kbd(child: Text('Ctrl')), Kbd(child: Text('K'))])
/// ```
///
/// Mirrors `KbdGroup` in upstream `src/components/ui/kbd.tsx`.
class KbdGroup extends StatelessWidget {
  const KbdGroup({super.key, required this.children});

  /// The keys, and any separators between them.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d4,
    children: children,
  );
}
