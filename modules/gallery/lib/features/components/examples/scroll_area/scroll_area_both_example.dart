import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ScrollAreaBothExample extends StatelessWidget {
  const ScrollAreaBothExample({super.key});

  static const _columns = 8;
  static const _rows = 12;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final rule = Border.all(
      color: theme.colors.pencilMark.withValues(alpha: 0.5),
      width: Spacing.d1,
    );
    return SizedBox(
      width: Spacing.d320,
      height: Spacing.d256,
      child: Paper(
        seed: 'grid',
        child: ScrollArea(
          orientation: ScrollAreaOrientation.both,
          type: ScrollAreaType.always,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.d12),
            child: SizedBox(
              width: Spacing.d64 * 10,
              child: Column(
                children: [
                  for (var row = 1; row <= _rows; row++)
                    Row(
                      children: [
                        for (var column = 1; column <= _columns; column++)
                          Expanded(
                            child: Container(
                              height: Spacing.d56,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(border: rule),
                              child: Text(
                                '$column·$row',
                                style: theme.typography.mono(cssSize: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
