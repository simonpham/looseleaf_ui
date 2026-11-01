import 'package:flutter/widgets.dart';

/// Groups rows of a menu.
///
/// Mirrors the `*MenuGroup` parts of upstream `dropdown-menu.tsx`,
/// `context-menu.tsx` and `menubar.tsx`.
class InkMenuGroup extends StatelessWidget {
  const InkMenuGroup({super.key, required this.children});

  /// The rows.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}
