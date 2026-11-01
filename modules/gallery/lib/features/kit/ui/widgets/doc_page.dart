import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/doc_kicker.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A docs page: a taped sheet with a kicker, a highlighted title, a lede,
/// a row of [meta] chips and the [children] 40 px apart.
///
/// Mirrors `Page` in upstream `src/docs/kit/Page.tsx`.
class DocPage extends StatelessWidget {
  const DocPage({
    super.key,
    this.kicker,
    required this.title,
    this.description,
    this.meta = const [],
    required this.children,
    this.footer,
  });

  final String? kicker;
  final String title;
  final String? description;
  final List<Widget> meta;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return PaperPage(
      width: PageWidth.lg,
      tape: PaperTape.top,
      tilt: false,
      seed: 'page:$title',
      children: [
        PageHeader(
          children: [
            if (kicker case final text?) DocKicker(text),
            PageTitle(Text(title), underline: TitleMark.highlight),
            if (description case final text?)
              Text(
                text,
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 18,
                  cssLineHeight: 1.375,
                  color: theme.colors.inkSoft,
                ),
              ),
            if (meta.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.d4),
                child: Wrap(
                  spacing: Spacing.d8,
                  runSpacing: Spacing.d8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: meta,
                ),
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d40,
          children: children,
        ),
        ?footer,
      ],
    );
  }
}
