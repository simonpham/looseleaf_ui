import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/doc_pressable.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A page to go to from the [DocPager]: its title and how to get there.
typedef PagerLink = ({String title, VoidCallback onPressed});

/// Previous and next links at the foot of a page: side by side from the `sm`
/// breakpoint (640) up, stacked below it, each title truncated to its half.
///
/// Mirrors `Pager` in upstream `src/docs/kit/Pager.tsx`.
class DocPager extends StatelessWidget {
  const DocPager({super.key, this.previous, this.next});

  final PagerLink? previous;
  final PagerLink? next;

  static const double _smallBreakpoint = 640;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d16,
    children: [
      const Separator(variant: SeparatorVariant.dashed),
      LayoutBuilder(
        builder: (context, constraints) {
          final previousEnd = switch (previous) {
            final link? => _PagerEnd(label: 'Previous', link: link, end: false),
            null => null,
          };
          final nextEnd = switch (next) {
            final link? => _PagerEnd(label: 'Next', link: link, end: true),
            null => null,
          };
          if (constraints.maxWidth < _smallBreakpoint) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d8,
              children: [?previousEnd, ?nextEnd],
            );
          }
          return Row(
            spacing: Spacing.d8,
            children: [
              Expanded(child: previousEnd ?? const SizedBox.shrink()),
              Expanded(child: nextEnd ?? const SizedBox.shrink()),
            ],
          );
        },
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
