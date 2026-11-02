import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/footer_01/footer_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A site footer on torn kraft paper: the brand and a rubber stamp, three
/// columns of links, a stitched rule, then the small print, the social
/// links and a status badge.
///
/// Mirrors upstream `src/blocks/footer-01/page.tsx`.
class Footer01Block extends StatelessWidget {
  const Footer01Block({super.key});

  static const double _maxWidth = 1152;

  static const _social = [
    (label: 'Email us', icon: 'mail'),
    (label: 'Read the blog', icon: 'book-open'),
    (label: 'Join the chat', icon: 'message-circle'),
    (label: 'See the source', icon: 'code'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final roomy = width >= 576;
        final wide = width >= 768;
        final columns = switch (roomy) {
          true => 3,
          false => 2,
        };
        return Padding(
          padding: EdgeInsets.fromLTRB(
            switch (roomy) {
              true => Spacing.d32,
              false => Spacing.d16,
            },
            Spacing.d56,
            switch (roomy) {
              true => Spacing.d32,
              false => Spacing.d16,
            },
            Spacing.d24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Semantics(
                container: true,
                label: 'Footer',
                child: Paper(
                  stock: StockName.kraft,
                  edge: const EdgeSpec(top: EdgeKind.torn),
                  tilt: false,
                  seed: 'footer-01',
                  padding: EdgeInsets.fromLTRB(
                    switch (roomy) {
                      true => Spacing.d48,
                      false => Spacing.d24,
                    },
                    Spacing.d48,
                    switch (roomy) {
                      true => Spacing.d48,
                      false => Spacing.d24,
                    },
                    Spacing.d28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      switch (wide) {
                        true => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Spacing.d48,
                          children: [
                            const Expanded(child: Footer01Brand(stacked: true)),
                            Expanded(
                              flex: 2,
                              child: Footer01Links(columns: columns),
                            ),
                          ],
                        ),
                        false => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: Spacing.d48,
                          children: [
                            const Footer01Brand(),
                            Footer01Links(columns: columns),
                          ],
                        ),
                      },
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: Spacing.d32),
                        child: Separator(variant: SeparatorVariant.stitched),
                      ),
                      DefaultTextStyle.merge(
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 15,
                          color: theme.colors.ink,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: Spacing.d24,
                          runSpacing: Spacing.d16,
                          children: [
                            const Text(
                              '© 2026 Penmark. Every page checked by hand.',
                            ),
                            Semantics(
                              container: true,
                              label: 'Elsewhere',
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: Spacing.d4,
                                children: [
                                  for (final link in _social)
                                    Button(
                                      variant: ButtonVariant.ghost,
                                      size: ButtonSize.icon,
                                      semanticLabel: link.label,
                                      onPressed: () {},
                                      child: InkIcon(
                                        link.icon,
                                        size: Spacing.d20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: Spacing.d16,
                              runSpacing: Spacing.d8,
                              children: [
                                Footer01Link(
                                  'Privacy',
                                  underline: true,
                                  padding: EdgeInsets.symmetric(
                                    vertical: Spacing.d4,
                                  ),
                                ),
                                Footer01Link(
                                  'Terms',
                                  underline: true,
                                  padding: EdgeInsets.symmetric(
                                    vertical: Spacing.d4,
                                  ),
                                ),
                                Badge(
                                  tone: BadgeTone.grass,
                                  child: Text('All systems normal'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
