import 'package:flutter/widgets.dart';
import 'package:gallery/features/home/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "This desk is made of real components.": seven live cards in three rows.
///
/// Mirrors the `live` section of upstream `src/docs/content/home.tsx`.
class LiveDesk extends StatelessWidget {
  const LiveDesk({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: const EdgeInsets.only(top: Spacing.d64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                'This desk is made of real components.',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: switch (constraints.maxWidth >=
                      DeskSection.roomyFrom) {
                    true => 48,
                    false => 36,
                  },
                  cssLineHeight: 1.25,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
            ),
            const SizedBox(height: Spacing.d40),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d56,
              children: [
                LiveCardRow(
                  cards: [
                    (span: 7, fullAtMedium: false, child: ChartCard()),
                    (span: 5, fullAtMedium: false, child: PrefsCard()),
                  ],
                ),
                LiveCardRow(
                  cards: [
                    (span: 7, fullAtMedium: false, child: AnnotatedCard()),
                    (span: 5, fullAtMedium: false, child: PlannerCard()),
                  ],
                ),
                LiveCardRow(
                  cards: [
                    (span: 5, fullAtMedium: false, child: ChatCard()),
                    (span: 4, fullAtMedium: false, child: TabsCard()),
                    (span: 3, fullAtMedium: true, child: ToastSlipCard()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
