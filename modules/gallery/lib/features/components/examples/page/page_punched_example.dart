import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/page/page_two_up.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PagePunchedExample extends StatelessWidget {
  const PagePunchedExample({super.key});

  @override
  Widget build(BuildContext context) => PageTwoUp(
    first: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 416),
      child: const PaperPage(
        holes: PageHoles.start,
        reinforced: true,
        stain: true,
        seed: 'binder',
        width: PageWidth.sm,
        children: [
          PageHeader(
            children: [
              PageTitle(Text('For the binder'), underline: TitleMark.double),
              PageDescription(Text('Three holes, gummed rings, one coffee.')),
            ],
          ),
          PageContent(
            children: [
              Text(
                'The rings are stuck on by hand and never quite concentric. The stain is faint on purpose.',
              ),
            ],
          ),
        ],
      ),
    ),
    second: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 416),
      child: const PaperPage(
        holes: PageHoles.top,
        stock: StockName.graph,
        seed: 'legal',
        width: PageWidth.sm,
        children: [
          PageHeader(
            children: [
              PageTitle(Text('Filed at the top'), underline: TitleMark.wavy),
              PageDescription(
                Text('Two holes, a hand apart, like legal paper.'),
              ),
            ],
          ),
          PageContent(
            children: [
              Text(
                'The start padding grows with the punch, so the text never touches it.',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
