import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TypewriterRotatingWordExample extends StatelessWidget {
  const TypewriterRotatingWordExample({super.key});

  static const _cssSize = 36.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'We make ',
          style: theme.typography.face(
            KevinSansFace.script,
            cssSize: _cssSize,
            cssLineHeight: 1.25,
          ),
        ),
        Flexible(
          child: SizedBox(
            width: _cssSize * 11,
            child: Typewriter.phrases(
              const ['notebooks', 'stickers', 'tape', 'small good things'],
              mode: TypingMode.cycle,
              loop: true,
              cursor: CaretShape.block,
              pause: const Duration(milliseconds: 1100),
              speed: 14,
              style: theme.typography.face(
                KevinSansFace.type,
                cssSize: _cssSize,
                cssLineHeight: 1.25,
                color: theme.colors.orangeText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
