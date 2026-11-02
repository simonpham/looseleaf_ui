import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StampButtonInksAndShapesExample extends StatelessWidget {
  const StampButtonInksAndShapesExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 576),
      child: StampSurface(
        child: Paper(
          tilt: false,
          padding: const EdgeInsets.all(Spacing.d24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Spacing.d384),
                child: Text(
                  'Received from the post office on the 14th, signed for and put on the shelf by the window. Stamp it however you like.',
                  style: TextStyle(color: theme.colors.ink),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: Spacing.d160),
                child: Wrap(
                  spacing: Spacing.d16,
                  runSpacing: Spacing.d16,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    StampButton(stamp: 'stamp-paid', place: Offset(0.2, 0.5)),
                    StampButton(
                      stamp: 'stamp-received',
                      sub: 'Mar 14 2026',
                      place: Offset(0.66, 0.42),
                    ),
                    StampButton(
                      text: 'Filed',
                      shape: StampShape.rect,
                      ink: StampButtonInk.ink,
                      dashed: true,
                      w: 140,
                      h: 52,
                      place: Offset(0.5, 0.6),
                    ),
                    StampButton(
                      stamp: 'stamp-urgent',
                      place: Offset(0.78, 0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
