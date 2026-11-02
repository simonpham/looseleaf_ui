import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/logos_01/logos_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A logo wall: "Kept on desks at", then two strips of tape running team
/// names in opposite directions. Where motion is reduced, the names sit
/// still in a wrapped row.
///
/// Mirrors upstream `src/blocks/logos-01/page.tsx`.
class Logos01Block extends StatefulWidget {
  const Logos01Block({super.key});

  @override
  State<Logos01Block> createState() => _Logos01BlockState();
}

class _Logos01BlockState extends State<Logos01Block> {
  bool _paused = false;

  static const double _maxWidth = 1024;
  static const _rowA = [
    Logos01Logo.oatmeal,
    Logos01Logo.kiln,
    Logos01Logo.paperworkBros,
    Logos01Logo.northwind,
  ];
  static const _rowB = [
    Logos01Logo.teaRoom,
    Logos01Logo.brindle,
    Logos01Logo.loomAndLantern,
    Logos01Logo.saltStudio,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 576;
        return Padding(
          padding: switch (wide) {
            true => const EdgeInsets.symmetric(
              horizontal: Spacing.d32,
              vertical: Spacing.d80,
            ),
            false => const EdgeInsets.symmetric(
              horizontal: Spacing.d16,
              vertical: Spacing.d56,
            ),
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d32,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Kept on desks at',
                      textAlign: TextAlign.center,
                      style: theme.typography.face(
                        KevinSansFace.type,
                        cssSize: 14,
                        cssLineHeight: 20 / 14,
                        color: theme.colors.inkSoft,
                      ),
                    ),
                  ),
                  switch (InkMotion.reducedIn(context)) {
                    true => Semantics(
                      label: 'Teams that use Penmark',
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: Spacing.d40,
                        runSpacing: Spacing.d16,
                        children: [
                          for (final logo in Logos01Logo.values)
                            Logos01Name(logo),
                        ],
                      ),
                    ),
                    false => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d12,
                      children: [
                        Marquee(
                          label: 'Teams that use Penmark',
                          tape: TapeKind.washiStripes,
                          color: Accent.tangerine,
                          speed: 46,
                          paused: _paused,
                          onPausedChange: (paused) =>
                              setState(() => _paused = paused),
                          seed: 'logos-a',
                          children: [
                            for (final logo in _rowA)
                              MarqueeItem(Logos01Name(logo)),
                          ],
                        ),
                        Marquee(
                          label: 'More teams that use Penmark',
                          tape: TapeKind.washiGingham,
                          color: Accent.sky,
                          direction: MarqueeDirection.end,
                          speed: 38,
                          paused: _paused,
                          controls: false,
                          seed: 'logos-b',
                          children: [
                            for (final logo in _rowB)
                              MarqueeItem(Logos01Name(logo)),
                          ],
                        ),
                      ],
                    ),
                  },
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
