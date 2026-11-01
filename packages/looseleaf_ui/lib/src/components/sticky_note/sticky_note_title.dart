import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The first word of a sticky note, saying what it is: 27 px bold script,
/// leading none.
///
/// Mirrors `StickyNoteTitle` in upstream `src/components/ui/sticky-note.tsx`.
class StickyNoteTitle extends StatelessWidget {
  const StickyNoteTitle(this.child, {super.key});

  /// The title, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      header: true,
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: 27.2,
          cssLineHeight: 1,
          fontWeight: FontWeight.w700,
          color: theme.colors.ink,
        ),
        child: child,
      ),
    );
  }
}
