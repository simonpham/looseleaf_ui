import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NapkinDefaultExample extends StatelessWidget {
  const NapkinDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => const Napkin(
    seed: 'specials',
    tape: PaperTape.top,
    children: [
      NapkinTitle(Text('Specials')),
      NapkinContent(
        Text('soup of the day, a very small pie, and something with pears'),
      ),
      NapkinFooter(Text('until six')),
    ],
  );
}
