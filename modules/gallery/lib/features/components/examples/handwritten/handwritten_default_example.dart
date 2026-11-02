import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class HandwrittenDefaultExample extends StatelessWidget {
  const HandwrittenDefaultExample({super.key});

  static const _maxWidth = 576.0;
  static const _wide = 560.0;
  static const _text =
      'Most of what I remember from a book is in the margins: an arrow, a question mark, a small argument with a dead author.';

  @override
  Widget build(BuildContext context) {
    final style = LooseleafTheme.of(
      context,
    ).typography.face(KevinSansFace.hand, cssSize: 17, cssLineHeight: 1.7);
    final columns = [
      Text(_text, style: style),
      Handwritten(_text, style: style),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: LayoutBuilder(
        builder: (context, constraints) =>
            switch (constraints.maxWidth >= _wide) {
              true => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d24,
                children: [
                  for (final column in columns) Expanded(child: column),
                ],
              ),
              false => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d24,
                children: columns,
              ),
            },
      ),
    );
  }
}
