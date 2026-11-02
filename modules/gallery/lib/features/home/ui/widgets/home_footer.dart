import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The foot of the home desk: the name, a line about it, links into the
/// docs and a red "Made by hand" stamp.
///
/// Mirrors `Footer` in upstream `src/docs/content/home/footer.tsx`.
class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key, required this.links});

  /// The links, by label.
  final List<(String, VoidCallback)> links;

  static const double _stampWidth = 196;
  static const double _stampHeight = 76;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d112),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d36,
        children: [
          const Separator(variant: SeparatorVariant.dashed),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: Spacing.d40,
            runSpacing: Spacing.d32,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Looseleaf',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 36,
                      cssLineHeight: 1,
                      fontWeight: FontWeight.w700,
                      color: theme.colors.ink,
                    ),
                  ),
                  const SizedBox(height: Spacing.d8),
                  Text(
                    'shadcn/ui, drawn by hand. MIT licensed, with accessible parts and a pencil.',
                    style: theme.typography.interface(color: theme.colors.ink),
                  ),
                  const SizedBox(height: Spacing.d16),
                  Wrap(
                    spacing: Spacing.d24,
                    runSpacing: Spacing.d8,
                    children: [
                      for (final (label, onPressed) in links)
                        DocLink(label, onPressed: onPressed),
                    ],
                  ),
                ],
              ),
              const Stamp(
                text: 'Made by hand',
                sub: 'Looseleaf UI 0.1.0',
                shape: StampShape.rect,
                ink: StampPadInk.red,
                w: _stampWidth,
                h: _stampHeight,
                tilt: -5,
                seed: 'made-by-hand',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
