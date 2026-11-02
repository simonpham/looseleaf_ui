import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CalloutMarginNotesExample extends StatelessWidget {
  const CalloutMarginNotesExample({super.key});

  static const _maxWidth = 768.0;
  static const _wide = 720.0;
  static const _noteWidth = Spacing.d192;
  static const _pitch = 28.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final text = Text.rich(
      const TextSpan(
        children: [
          TextSpan(
            text:
                'Most of what I remember from a book is in the margins: an arrow, a question mark, a small argument with a dead author. The good bits get ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Highlight(child: Text('a swipe of yellow')),
          ),
          TextSpan(
            text:
                ' so I can find them on the next read, and the parts I do not believe get a red pencil. I go back for them in winter, when a page is the only company.',
          ),
        ],
      ),
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 17,
        cssLineHeight: _pitch / 17,
      ),
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _wide;
          return Paper(
            rules: RuleName.ruled,
            seed: 'margin',
            padding: EdgeInsetsDirectional.fromSTEB(
              Spacing.d56,
              Spacing.d16,
              switch (wide) {
                true => Spacing.d16,
                false => Spacing.d24,
              },
              Spacing.d24,
            ),
            child: switch (wide) {
              true => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d32,
                children: [
                  Expanded(child: text),
                  const SizedBox(
                    width: _noteWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: _pitch * 3 + Spacing.d6),
                        Callout('the best line'),
                        SizedBox(height: _pitch),
                        Callout(
                          'ha, true',
                          direction: ArrowDirection.left,
                          bend: ArrowBend.down,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              false => text,
            },
          );
        },
      ),
    );
  }
}
