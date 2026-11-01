import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A folder's strip of [FolderTab]s, 16 px in from each end, 4 px apart,
/// standing on the body. One Tab stop: Left and Right (swapped right to
/// left), Home and End move between the tabs.
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
    return Semantics(
      container: true,
      role: SemanticsRole.tabBar,
      label: semanticLabel,
      child: InkRovingFocus(
        axis: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: Spacing.d4,
            children: children,
          ),
        ),
      ),
    );
  }
}
