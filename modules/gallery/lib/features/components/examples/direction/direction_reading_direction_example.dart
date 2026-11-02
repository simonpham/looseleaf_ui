import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DirectionReadingDirectionExample extends StatefulWidget {
  const DirectionReadingDirectionExample({super.key});

  @override
  State<DirectionReadingDirectionExample> createState() =>
      _DirectionReadingDirectionExampleState();
}

class _DirectionReadingDirectionExampleState
    extends State<DirectionReadingDirectionExample> {
  static const _maxWidth = Spacing.d448;

  TextDirection _direction = TextDirection.rtl;
  var _size = [35.0];

  @override
  Widget build(BuildContext context) {
    final rtl = _direction == TextDirection.rtl;
    String say(String english, String arabic) => switch (rtl) {
      true => arabic,
      false => english,
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ToggleGroup<TextDirection>(
              variant: ToggleVariant.outline,
              semanticLabel: 'Reading direction',
              value: {_direction},
              onChanged: (value) {
                if (value.firstOrNull case final direction?) {
                  setState(() => _direction = direction);
                }
              },
              children: const [
                ToggleGroupItem(
                  value: TextDirection.ltr,
                  child: Text('Left to right'),
                ),
                ToggleGroupItem(
                  value: TextDirection.rtl,
                  child: Text('Right to left'),
                ),
              ],
            ),
          ),
          DirectionProvider(
            direction: _direction,
            child: Card(
              seed: 'direction-default',
              children: [
                CardHeader(
                  children: [
                    CardTitle(Text(say('Notebook', 'دفتر الملاحظات'))),
                    CardDescription(
                      Text(
                        say(
                          'Every page reads from left to right.',
                          'كل صفحة تُقرأ من اليمين إلى اليسار.',
                        ),
                      ),
                    ),
                  ],
                ),
                CardContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d20,
                    children: [
                      Tabs(
                        defaultValue: 'one',
                        children: [
                          TabsList(
                            children: [
                              TabsTrigger(
                                value: 'one',
                                child: Text(say('First', 'الأول')),
                              ),
                              TabsTrigger(
                                value: 'two',
                                child: Text(say('Second', 'الثاني')),
                              ),
                              TabsTrigger(
                                value: 'three',
                                child: Text(say('Third', 'الثالث')),
                              ),
                            ],
                          ),
                          for (final tab in ['one', 'two', 'three'])
                            TabsContent(value: tab, child: const _Readout()),
                        ],
                      ),
                      Slider(
                        values: _size,
                        tickCount: 4,
                        semanticLabel: say('Type size', 'حجم الخط'),
                        onChanged: (values) => setState(() => _size = values),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout();

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final direction = DirectionProvider.of(context);
    final step = switch (direction) {
      TextDirection.rtl => 'previous',
      TextDirection.ltr => 'next',
    };
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'DirectionProvider.of(context)',
              style: theme.typography.mono(cssSize: 13),
            ),
            const TextSpan(text: ' says '),
            TextSpan(
              text: direction.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.colors.ink,
              ),
            ),
            TextSpan(text: '. ArrowRight moves to the $step tab.'),
          ],
        ),
        style: theme.typography.interface(
          cssSize: 14,
          color: theme.colors.inkMuted,
        ),
      ),
    );
  }
}
