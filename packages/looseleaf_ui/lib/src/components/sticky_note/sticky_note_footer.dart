import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Who wrote a sticky note and when: 14 px hand font in soft ink, 8 px
/// below what comes before it.
///
/// Mirrors `StickyNoteFooter` in upstream `src/components/ui/sticky-note.tsx`.
class StickyNoteFooter extends StatelessWidget {
  const StickyNoteFooter(this.child, {super.key});

  /// The footer, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d8),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 14,
          cssLineHeight: 20 / 14,
          color: theme.colors.inkSoft,
        ),
        child: child,
      ),
    );
  }
}
