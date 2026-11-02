import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/page/page_two_up.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PageTornPadExample extends StatelessWidget {
  const PageTornPadExample({super.key});

  @override
  Widget build(BuildContext context) => PageTwoUp(
    first: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Spacing.d320),
      child: const PaperPage(
        torn: PageTorn.top,
        stock: StockName.slip,
        width: PageWidth.sm,
        tape: PaperTape.top,
        seed: 'pad',
        children: [
          PageHeader(
            children: [
              PageTitle(Text('Order pad'), underline: TitleMark.highlight),
              PageDescription(Text('Top edge ragged.')),
            ],
          ),
          PageContent(
            children: [
              Text('2 x oat latte, one for the road.'),
              Text('1 x croissant, warm.'),
            ],
          ),
          PageFooter(children: [Text('no. 0042')]),
        ],
      ),
    ),
    second: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Spacing.d320),
      child: const PaperPage(
        torn: PageTorn.both,
        width: PageWidth.sm,
        fastener: FastenerKind.clip,
        seed: 'scrap',
        children: [
          PageHeader(
            children: [
              PageTitle(Text('A scrap'), underline: null),
              PageDescription(
                Text('Torn at both ends and clipped to something.'),
              ),
            ],
          ),
          PageContent(
            children: [Text('Not every page has to be a whole one.')],
          ),
        ],
      ),
    ),
  );
}
