import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DeskMorningDeskExample extends StatelessWidget {
  const DeskMorningDeskExample({super.key});

  static const _minHeight = 544.0;
  static const _maxWidth = 896.0;
  static const _pageWidth = Spacing.d288;
  static const _pageMaxWidth = Spacing.d512;
  static const _pageMinHeight = 352.0;
  static const _sideWidth = Spacing.d256;
  static const _noteSide = 112.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final noteStyle = theme.typography.face(
      KevinSansFace.script,
      cssSize: 24,
      cssLineHeight: 1,
      fontWeight: FontWeight.w700,
    );
    return Semantics(
      container: true,
      label: 'Workspace',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minHeight),
        child: Desk(
          objects: const [
            DeskObject.coffee,
            DeskObject.pencil,
            DeskObject.clips,
          ],
          seed: 'morning',
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d24,
            vertical: Spacing.d48,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final page = ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: _pageWidth,
                      maxWidth: _pageMaxWidth,
                      minHeight: _pageMinHeight,
                    ),
                    child: const PaperPage(
                      holes: PageHoles.start,
                      reinforced: true,
                      width: PageWidth.sm,
                      seed: 'morning-page',
                      children: [
                        PageHeader(
                          children: [
                            PageTitle(
                              Text('Monday'),
                              underline: TitleMark.highlight,
                            ),
                            PageDescription(
                              Text('Three things, in this order.'),
                            ),
                          ],
                        ),
                        PageContent(
                          children: [
                            Text('1. Ink the outline'),
                            Text('2. Answer Marguerite'),
                            Text('3. Tea'),
                          ],
                        ),
                      ],
                    ),
                  );
                  final side = SizedBox(
                    width: _sideWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.d32,
                      children: [
                        Card(
                          stock: StockName.indexCard,
                          tape: PaperTape.top,
                          seed: 'morning-card',
                          gap: Spacing.d12,
                          padding: const EdgeInsets.symmetric(
                            vertical: Spacing.d16,
                          ),
                          children: [
                            const CardHeader(
                              children: [CardTitle(Text('Reminder'))],
                            ),
                            CardContent(
                              child: Text(
                                'Post the parcel before the office shuts.',
                                style: theme.typography.interface(cssSize: 14),
                              ),
                            ),
                            CardFooter(
                              children: [
                                Button(
                                  size: ButtonSize.sm,
                                  variant: ButtonVariant.secondary,
                                  onPressed: () {},
                                  child: const Text('Done'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          spacing: Spacing.d20,
                          children: [
                            SizedBox.square(
                              dimension: _noteSide,
                              child: Paper(
                                stock: StockName.stickyYellow,
                                seed: 's1',
                                padding: const EdgeInsets.all(Spacing.d12),
                                child: Text('call mum', style: noteStyle),
                              ),
                            ),
                            SizedBox.square(
                              dimension: _noteSide,
                              child: Paper(
                                stock: StockName.stickyPink,
                                seed: 's2',
                                padding: const EdgeInsets.all(Spacing.d12),
                                child: Text('pens!!', style: noteStyle),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                  return switch (constraints.maxWidth >=
                      _pageWidth + Spacing.d40 + _sideWidth) {
                    true => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.d40,
                      children: [
                        Flexible(child: page),
                        side,
                      ],
                    ),
                    false => Column(
                      spacing: Spacing.d40,
                      children: [page, side],
                    ),
                  };
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
