import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-xl`.
const _maxWidth = 576.0;

class RibbonVariantsAndColoursExample extends StatelessWidget {
  const RibbonVariantsAndColoursExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d20,
      children: [
        const Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Spacing.d16,
          runSpacing: Spacing.d16,
          children: [
            Ribbon(child: Text('Banner')),
            Ribbon(
              variant: RibbonVariant.swallow,
              tone: RibbonTone.lemon,
              child: Text('Swallow'),
            ),
            Ribbon(
              variant: RibbonVariant.flag,
              tone: RibbonTone.tangerine,
              child: Text('Flag'),
            ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Spacing.d12,
          runSpacing: Spacing.d12,
          children: [
            for (final tone in RibbonTone.values)
              Ribbon(tone: tone, size: RibbonSize.sm, child: Text(tone.name)),
          ],
        ),
      ],
    ),
  );
}
