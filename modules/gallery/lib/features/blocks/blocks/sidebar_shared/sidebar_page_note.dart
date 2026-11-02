import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A note in the middle of an empty page: Stubby in a [pose] (or a
/// [doodle]), a script [title] and a [description] written by hand.
/// Takes the height left in a [SidebarPageBody].
///
/// Mirrors `PageNote` in upstream
/// `src/blocks/sidebar-shared/sidebar-page.tsx`.
class SidebarPageNote extends StatelessWidget {
  const SidebarPageNote({
    super.key,
    required this.title,
    this.pose,
    this.doodle,
    this.description,
  });

  final String title;
  final String? pose;
  final String? doodle;
  final String? description;

  static const double _maxWidth = 384;
  static const double _mediaSize = 72;
  static const double _mediumWidth = 768;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final description = this.description;
    final padding = switch (MediaQuery.sizeOf(context).width >= _mediumWidth) {
      true => Spacing.d24,
      false => Spacing.d16,
    };
    return Expanded(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Empty(
            padding: EdgeInsets.all(padding),
            seed: 'page-note',
            children: [
              EmptyHeader(
                children: [
                  if (pose != null || doodle != null)
                    EmptyMedia(pose: pose, doodle: doodle, size: _mediaSize),
                  EmptyTitle(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 24,
                        cssLineHeight: 32 / 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (description != null)
                    EmptyDescription(
                      child: Handwritten(
                        description,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
