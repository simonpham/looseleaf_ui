import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _reminders = [
  'Water the plants',
  'Call the printer',
  'Sharpen pencils',
  'Post the letters',
];

class CarouselVerticalExample extends StatelessWidget {
  const CarouselVerticalExample({super.key});

  static const _trackHeight = Spacing.d200;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d320),
      child: Carousel(
        semanticLabel: 'Reminders',
        axis: Axis.vertical,
        align: CarouselAlign.start,
        itemFraction: 1 / 2,
        seed: 'vertical',
        children: [
          CarouselContent(
            extent: _trackHeight,
            gap: Spacing.d4,
            children: [
              for (final (index, reminder) in _reminders.indexed)
                CarouselItem(
                  semanticLabel: '${index + 1} of ${_reminders.length}',
                  child: Card(
                    seed: 'r$index',
                    gap: 0,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.d12),
                    children: [
                      CardContent(
                        padding: const EdgeInsets.all(Spacing.d16),
                        child: Center(
                          child: Text(
                            reminder,
                            textAlign: TextAlign.center,
                            style: theme.typography.face(
                              KevinSansFace.script,
                              cssSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const CarouselPrevious(),
          const CarouselNext(),
        ],
      ),
    );
  }
}
