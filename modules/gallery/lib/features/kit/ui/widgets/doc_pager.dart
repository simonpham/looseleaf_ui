import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/doc_pressable.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A page to go to from the [DocPager]: its title and how to get there.
typedef PagerLink = ({String title, VoidCallback onPressed});

/// Previous and next links at the foot of a page.
///
/// Mirrors `Pager` in upstream `src/docs/kit/Pager.tsx`.
class DocPager extends StatelessWidget {
  const DocPager({super.key, this.previous, this.next});

  final PagerLink? previous;
  final PagerLink? next;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d16,
    children: [
      const Separator(variant: SeparatorVariant.dashed),
      Row(
        children: [
          if (previous case final link?)
            _PagerEnd(label: 'Previous', link: link, end: false),
          const Spacer(),
          if (next case final link?)
            _PagerEnd(label: 'Next', link: link, end: true),
        ],
      ),
    ],
  );
}

class _PagerEnd extends StatelessWidget {
  const _PagerEnd({required this.label, required this.link, required this.end});

  final String label;
  final PagerLink link;
  final bool end;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DocPressable(
      onPressed: link.onPressed,
      semanticLabel: '$label: ${link.title}',
      builder: (context, highlighted) => Column(
        crossAxisAlignment: switch (end) {
          true => CrossAxisAlignment.end,
          false => CrossAxisAlignment.start,
        },
        children: [
          Text(
            label,
            style: theme.typography.stamp(
              cssSize: 13,
              color: theme.colors.inkMuted,
            ),
          ),
          Highlight(
            show: highlighted,
            seed: 'pager:${link.title}',
            child: Text(
              link.title,
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 24,
                fontWeight: FontWeight.w700,
                color: theme.colors.inkYou,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
