import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NapkinFoldsAndStainsExample extends StatelessWidget {
  const NapkinFoldsAndStainsExample({super.key});

  static const _width = 208.0;

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(Spacing.d16),
    child: Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: Spacing.d24,
        runSpacing: Spacing.d40,
        children: [
          Napkin(
            fold: NapkinFold.quarter,
            seed: 'q',
            width: _width,
            children: [
              NapkinTitle(Text('Quarter')),
              NapkinContent(Text('a crease each way')),
            ],
          ),
          Napkin(
            fold: NapkinFold.half,
            stain: true,
            seed: 'h',
            width: _width,
            children: [
              NapkinTitle(Text('Half')),
              NapkinContent(Text('and a cup stood here')),
            ],
          ),
          Napkin(
            fold: NapkinFold.none,
            seed: 'f',
            width: _width,
            children: [
              NapkinTitle(Text('Flat')),
              NapkinContent(Text('never folded')),
            ],
          ),
        ],
      ),
    ),
  );
}
