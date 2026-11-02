import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Where the photograph would be: a graph-paper greeting, Stubby waving and
/// a pinned note.
///
/// Mirrors upstream `src/blocks/login-02/components/login-02-cover.tsx`.
class Login02Cover extends StatelessWidget {
  const Login02Cover({super.key});

  static const Size _size = Size(368, 480);

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ExcludeSemantics(
      child: SizedBox.fromSize(
        size: _size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            PositionedDirectional(
              start: Spacing.d24,
              top: Spacing.d40,
              width: Spacing.d288,
              height: 352,
              child: Paper(
                stock: StockName.graph,
                tiltDegrees: -1.5,
                tape: PaperTape.both,
                tapeKind: TapeKind.washiStripes,
                seed: 'login-02-sheet',
                padding: const EdgeInsets.fromLTRB(
                  Spacing.d24,
                  Spacing.d32,
                  Spacing.d24,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'hi again!',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 44,
                        cssLineHeight: 0.95,
                        fontWeight: FontWeight.w700,
                        color: theme.colors.ink,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.d8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: Spacing.d176,
                        ),
                        child: Text(
                          'we kept your page open and the kettle on.',
                          style: theme.typography.face(
                            KevinSansFace.hand,
                            cssSize: 16,
                            cssLineHeight: 1.375,
                            color: theme.colors.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const PositionedDirectional(
              start: 120,
              top: 184,
              child: Mascot(pose: 'wave', size: 216, seed: 'login-02-stubby'),
            ),
            PositionedDirectional(
              start: 0,
              top: 208,
              child: StickyNote(
                fastener: FastenerKind.pin,
                tiltDegrees: -3,
                width: Spacing.d112,
                minHeight: Spacing.d40,
                seed: 'login-02-note',
                children: [
                  Text(
                    'psst: tab works too',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 18,
                      cssLineHeight: 28 / 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
