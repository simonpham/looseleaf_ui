import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PaginationControlledExample extends StatefulWidget {
  const PaginationControlledExample({super.key});

  @override
  State<PaginationControlledExample> createState() =>
      _PaginationControlledExampleState();
}

class _PaginationControlledExampleState
    extends State<PaginationControlledExample> {
  static const _last = 9;

  int _page = 5;

  void _go(int page) => setState(() => _page = page.clamp(1, _last));

  /// The page numbers to show, null for a gap.
  List<int?> get _windowed {
    final out = <int?>[];
    for (var page = 1; page <= _last; page++) {
      final shown = page == 1 || page == _last || (page - _page).abs() <= 1;
      if (shown) {
        out.add(page);
        continue;
      }
      if (out.last != null) out.add(null);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d16,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Pagination(
            child: PaginationContent(
              children: [
                PaginationPrevious(
                  disabled: _page == 1,
                  onPressed: () => _go(_page - 1),
                ),
                for (final page in _windowed)
                  switch (page) {
                    null => const PaginationEllipsis(),
                    final number => PaginationLink(
                      isActive: number == _page,
                      semanticLabel: 'Page $number',
                      onPressed: () => _go(number),
                      child: Text('$number'),
                    ),
                  },
                PaginationNext(
                  disabled: _page == _last,
                  onPressed: () => _go(_page + 1),
                ),
              ],
            ),
          ),
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            'Page $_page of $_last',
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}
