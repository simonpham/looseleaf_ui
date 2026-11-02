import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PaginationSimpleExample extends StatefulWidget {
  const PaginationSimpleExample({super.key});

  @override
  State<PaginationSimpleExample> createState() =>
      _PaginationSimpleExampleState();
}

class _PaginationSimpleExampleState extends State<PaginationSimpleExample> {
  static const _total = 12;

  int _page = 3;

  void _go(int page) => setState(() => _page = page.clamp(1, _total));

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d24,
      children: [
        Pagination(
          child: PaginationContent(
            children: [
              PaginationLink(
                size: ButtonSize.iconSm,
                semanticLabel: 'Go to previous page',
                disabled: _page == 1,
                onPressed: () => _go(_page - 1),
                child: const InkIcon('chevron-left'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.d12),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    'page $_page of $_total',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 20,
                    ),
                  ),
                ),
              ),
              PaginationLink(
                size: ButtonSize.iconSm,
                semanticLabel: 'Go to next page',
                disabled: _page == _total,
                onPressed: () => _go(_page + 1),
                child: const InkIcon('chevron-right'),
              ),
            ],
          ),
        ),
        Pagination(
          child: PaginationContent(
            children: [
              PaginationPrevious(onPressed: () {}),
              PaginationNext(onPressed: () {}),
            ],
          ),
        ),
        Pagination(
          child: PaginationContent(
            children: [
              PaginationLink(
                size: ButtonSize.lg,
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.d20),
                  child: Text('Load more notes'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
