import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TypewriterDefaultExample extends StatelessWidget {
  const TypewriterDefaultExample({super.key});

  static const _maxWidth = 576.0;
  static const _minHeight = 84.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: _maxWidth,
        minHeight: _minHeight,
      ),
      child: Typewriter(
        'Every screen, drawn by hand. Nothing here was made by a ruler.',
        style: theme.typography.face(
          KevinSansFace.type,
          cssSize: 30,
          cssLineHeight: 1.375,
        ),
      ),
    );
  }
}
