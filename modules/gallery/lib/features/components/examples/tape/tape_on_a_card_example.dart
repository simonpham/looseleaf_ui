import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TapeOnACardExample extends StatelessWidget {
  const TapeOnACardExample({super.key});

  static const _width = 288.0;
  static const _minHeight = 120.0;
  static const _pitch = 30.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d24),
      child: Center(
        child: SizedBox(
          width: _width,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: _minHeight,
                  minWidth: _width,
                ),
                child: Paper(
                  stock: StockName.indexCard,
                  seed: 'taped',
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.d24,
                    Spacing.d14,
                    Spacing.d24,
                    Spacing.d16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Taped at an angle',
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: 27.2,
                          cssLineHeight: _pitch / 27.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Two strips of washi, no pins.',
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 15,
                          cssLineHeight: _pitch / 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                top: -Spacing.d8,
                left: -Spacing.d28,
                child: Tape(
                  kind: TapeKind.washiStripes,
                  angle: -36,
                  seed: 'l',
                ),
              ),
              const Positioned(
                top: -Spacing.d8,
                right: -Spacing.d28,
                child: Tape(
                  kind: TapeKind.washiZigzag,
                  angle: 34,
                  seed: 'r',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
