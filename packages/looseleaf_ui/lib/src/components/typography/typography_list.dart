import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/typography/typography.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A bulleted or numbered list with marker-colored bullets; numbers are in
/// bold script.
///
/// ```dart
/// const TypographyList(children: [
///   Text('A question you cannot answer yet'),
///   Text('A disagreement, politely worded'),
/// ])
/// ```
///
/// Mirrors `List` in upstream `src/components/ui/typography.tsx` (renamed,
/// as `List` is Dart's own).
class TypographyList extends StatelessWidget {
  const TypographyList({
    super.key,
    required this.children,
    this.ordered = false,
  });

  /// The items, usually [Text]s.
  final List<Widget> children;

  /// Numbers the items (`<ol>`) instead of bulleting them.
  final bool ordered;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final marker = switch (ordered) {
      true => theme.typography.face(
        KevinSansFace.script,
        cssSize: 20,
        fontWeight: FontWeight.w700,
        color: theme.colors.marker,
      ),
      false => theme.typography.face(
        KevinSansFace.hand,
        cssSize: 20,
        color: theme.colors.marker,
      ),
    };
    return TypographyText(
      style: TypographyStyle.list,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d8,
        children: [
          for (final (index, item) in children.indexed)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: Spacing.d24,
                  child: Text.rich(
                    switch (ordered) {
                      true => TextSpan(text: '${index + 1}.'),
                      false => WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: _Disc(color: theme.colors.marker),
                      ),
                    },
                    textAlign: TextAlign.end,
                    style: marker,
                  ),
                ),
                const SizedBox(width: Spacing.d8),
                Expanded(child: item),
              ],
            ),
        ],
      ),
    );
  }
}

/// The `list-disc` bullet at `marker:text-xl`.
class _Disc extends StatelessWidget {
  const _Disc({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: Spacing.d6,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}
