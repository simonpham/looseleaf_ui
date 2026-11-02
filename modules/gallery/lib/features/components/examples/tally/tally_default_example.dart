import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TallyDefaultExample extends StatelessWidget {
  const TallyDefaultExample({super.key});

  @override
  Widget build(BuildContext context) =>
      const Tally(count: 7, glyphHeight: Spacing.d52);
}
