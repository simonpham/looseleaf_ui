import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class HandwrittenStickyNoteExample extends StatelessWidget {
  const HandwrittenStickyNoteExample({super.key});

  static const _width = Spacing.d224;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _width,
    child: Paper(
      stock: StockName.stickyYellow,
      seed: 'sticky',
      curl: true,
      padding: const EdgeInsets.all(Spacing.d20),
      child: Handwritten(
        'call mum before six, and bring the good umbrella!',
        style: LooseleafTheme.of(context).typography.face(
          KevinSansFace.script,
          cssSize: 26,
          cssLineHeight: 1.15,
        ),
      ),
    ),
  );
}
