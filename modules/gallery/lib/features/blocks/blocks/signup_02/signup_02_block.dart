import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/signup_02/signup_02.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A two-column sign-up page: the form on a plain sheet, and a desk with an
/// admission ticket beside it on wide screens.
///
/// Mirrors upstream `src/blocks/signup-02/page.tsx`.
class Signup02Block extends StatelessWidget {
  const Signup02Block({super.key});

  static const double _minHeight = 780;
  static const double _formWidth = 320;
  static const double _logoHeight = Spacing.d24;
  static const double _paddedFrom = 576;
  static const double _twoColumnsFrom = 768;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final twoColumns = width >= _twoColumnsFrom;
        final padding = switch (width >= _paddedFrom) {
          true => Spacing.d40,
          false => Spacing.d24,
        };
        final sheet = Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            spacing: Spacing.d16,
            crossAxisAlignment: switch (twoColumns) {
              true => CrossAxisAlignment.start,
              false => CrossAxisAlignment.center,
            },
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d8,
                children: [
                  const InkIcon(
                    'book-open',
                    tone: ArtTone.doodle,
                    size: _logoHeight,
                  ),
                  Text(
                    'Looseleaf',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 24,
                      cssLineHeight: 1,
                      fontWeight: FontWeight.w700,
                      color: theme.colors.ink,
                    ),
                  ),
                ],
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      _minHeight - padding * 2 - _logoHeight - Spacing.d16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _formWidth),
                    child: const Signup02Form(),
                  ),
                ),
              ),
            ],
          ),
        );
        return Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  const Expanded(
                    child: PaperBackground(
                      tilt: false,
                      shadow: PaperShadow.none,
                      seed: 'signup-02',
                    ),
                  ),
                  if (twoColumns) const Spacer(),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: sheet),
                if (twoColumns)
                  const Expanded(
                    child: SizedBox(
                      height: _minHeight,
                      child: ClipRect(
                        child: OverflowBox(
                          minWidth: 0,
                          minHeight: 0,
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: Signup02Ticket(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
