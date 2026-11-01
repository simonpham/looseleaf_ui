import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AsteriskMarksAndPensExample extends StatelessWidget {
  const AsteriskMarksAndPensExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.interface(cssSize: 17),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d12,
        children: [
          Wrap(
            spacing: Spacing.d24,
            children: [
              Asterisk(child: Text('asterisk')),
              Asterisk(mark: AsteriskMark.star, child: Text('star')),
              Asterisk(mark: AsteriskMark.dagger, child: Text('dagger')),
              Asterisk(
                mark: AsteriskMark.doubleDagger,
                child: Text('double dagger'),
              ),
            ],
          ),
          Wrap(
            spacing: Spacing.d24,
            children: [
              Asterisk(child: Text('red')),
              Asterisk(tone: AsteriskTone.ink, child: Text('ink')),
              Asterisk(tone: AsteriskTone.blue, child: Text('blue')),
              Asterisk(tone: AsteriskTone.pencil, child: Text('pencil')),
            ],
          ),
        ],
      ),
    );
  }
}
