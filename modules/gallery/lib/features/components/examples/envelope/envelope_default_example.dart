import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EnvelopeDefaultExample extends StatelessWidget {
  const EnvelopeDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d48),
      child: Envelope(
        seed: 'post',
        children: [
          const EnvelopeFront(
            children: [
              EnvelopeSender(child: Text('The Stationer\nHigh Street')),
              EnvelopeAddress(
                children: [
                  Text('Ada Lovelace'),
                  Text("12 rue de l'Eau"),
                  Text('Paris'),
                ],
              ),
              EnvelopeTrigger(label: 'Read the letter from The Stationer'),
            ],
          ),
          EnvelopeLetter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d8,
              children: [
                Text(
                  'Dear Ada,',
                  style: theme.typography
                      .title(cssSize: 30)
                      .copyWith(height: 1),
                ),
                const Text(
                  'The flap is up and the letter comes out from behind the '
                  'front.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
