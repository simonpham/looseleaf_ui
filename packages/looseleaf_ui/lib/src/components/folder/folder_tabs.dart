import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A folder's strip of [FolderTab]s, 16 px in from each end, 4 px apart,
/// standing on the body. One Tab stop: Left and Right (swapped right to
/// left), Home and End move between the tabs.
///
/// Tabs wider than the folder scroll sideways instead of running off it
/// (upstream lets them overflow); a focused tab scrolls into view. Tabs
/// wrapped in [Expanded] share the width instead, as upstream's
/// `min-w-0 flex-1` does, shortening long labels; narrow their
/// [FolderTab.inlinePadding] when the folder is small.
///
/// Mirrors `FolderTabs` in upstream `src/components/ui/folder.tsx`.
class FolderTabs extends StatelessWidget {
  const FolderTabs({super.key, required this.children, this.semanticLabel});

  /// The tabs.
  final List<Widget> children;

  /// What the tabs are, for screen readers (upstream's `aria-label`).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final strip = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
      child: Semantics(
        container: true,
        role: SemanticsRole.tabBar,
        label: semanticLabel,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: Spacing.d4,
          children: children,
        ),
      ),
    );
    final sharesWidth = children.any((child) => child is Flexible);
    return InkRovingFocus(
      axis: Axis.horizontal,
      child: switch (sharesWidth) {
        true => strip,
        false => LayoutBuilder(
          builder: (context, constraints) => ClipRect(
            clipper: const _SidewaysClip(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: IntrinsicWidth(child: strip),
              ),
            ),
          ),
        ),
      },
    );
  }
}

/// Clips the strip's ends only, so the open tab still runs into the body
/// below and the focus outline shows above.
class _SidewaysClip extends CustomClipper<Rect> {
  const _SidewaysClip();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, -size.height, size.width, size.height * 2);

  @override
  bool shouldReclip(_SidewaysClip oldClipper) => false;
}
