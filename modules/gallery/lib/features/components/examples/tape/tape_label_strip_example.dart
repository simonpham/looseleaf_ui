import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TapeLabelStripExample extends StatelessWidget {
  const TapeLabelStripExample({super.key});

  static const _length = 132.0;
  static const _height = 32.0;
  static const _labels = [
    (kind: TapeKind.masking, text: 'fragile'),
    (kind: TapeKind.kraft, text: 'this side up'),
    (kind: TapeKind.washiGingham, text: 'picnic'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.d16),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Spacing.d32,
        runSpacing: Spacing.d32,
        children: [
          for (final label in _labels)
            Stack(
              alignment: Alignment.center,
              children: [
                Tape(
                  kind: label.kind,
                  length: _length,
                  height: _height,
                  seed: label.text,
                ),
                SizedBox(
                  width: _length,
                  child: Text(
                    label.text,
                    textAlign: TextAlign.center,
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 24,
                      cssLineHeight: _height / 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
