import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/login_02/login_02.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Two columns: the sign-in form on a sheet of paper, and a hand-made cover
/// on the desk that shows from 768 px of width.
///
/// Mirrors upstream `src/blocks/login-02/page.tsx`.
class Login02Block extends StatelessWidget {
  const Login02Block({super.key});

  static const double _minHeight = 680;
  static const double _paddedFrom = 576;
  static const double _splitFrom = 768;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final split = width >= _splitFrom;
      final sheet = _Sheet(
        padding: switch (width >= _paddedFrom) {
          true => Spacing.d40,
          false => Spacing.d24,
        },
        split: split,
        minHeight: _minHeight,
      );
      if (!split) return sheet;
      final half = width / 2;
      return Stack(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: half),
            child: sheet,
          ),
          PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 0,
            width: half,
            child: const ClipRect(
              child: Desk(
                seed: 'login-02-desk',
                child: Center(
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: Login02Cover(),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.padding,
    required this.split,
    required this.minHeight,
  });

  final double padding;
  final bool split;
  final double minHeight;

  static const double _formMaxWidth = 320;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Paper(
      tilt: false,
      shadow: PaperShadow.none,
      seed: 'login-02',
      padding: EdgeInsets.all(padding),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight - padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d16,
          children: [
            Align(
              alignment: switch (split) {
                true => AlignmentDirectional.centerStart,
                false => AlignmentDirectional.center,
              },
              child: GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d8,
                  children: [
                    const InkIcon(
                      'book-open',
                      tone: ArtTone.doodle,
                      size: Spacing.d24,
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
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _formMaxWidth),
                child: const Login02Form(),
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
