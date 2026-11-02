import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TypographyProseExample extends StatelessWidget {
  const TypographyProseExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Prose(
      children: [
        const H1(child: Text('Keeping a reading log')),
        P(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'A reading log is '),
                const TextSpan(
                  text: 'not',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                const TextSpan(text: ' a summary. It is a place to '),
                const TextSpan(
                  text: 'argue',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(
                  text: ', and to write down where you stopped believing the author. Start with the ',
                ),
                TextSpan(
                  text: 'field guide to margins',
                  style: TextStyle(
                    color: theme.colors.inkYou,
                    decoration: TextDecoration.underline,
                    decorationColor: theme.colors.inkYou,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        const H2(child: Text('What to write down')),
        const TypographyList(
          children: [
            Text('The date, so future you can blame past you'),
            Text('One sentence you would steal'),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'A question, marked with '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: InlineCode('?'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Blockquote(
          child: Text('The best time to write it down was when it happened.'),
        ),
        const H2(child: Text('Tools')),
        const TypographyList(
          ordered: true,
          children: [Text('A pencil'), Text('A second pencil')],
        ),
        const P(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Press '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Kbd(child: Text('Cmd')),
                ),
                TextSpan(text: ' + '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Kbd(child: Text('S')),
                ),
                TextSpan(text: ' to save, or run '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: InlineCode('npm run notes'),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        const CodeBlock(code: 'read --slowly --with-pencil', copyable: false),
      ],
    );
  }
}
