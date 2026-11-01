import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A page's title in the big script face, underlined by hand: a single,
/// double or wavy line, or a highlighter swipe ([underline] null for none;
/// a plain pencil line when calm). The mark spans the title's own width.
///
/// Mirrors `PageTitle` in upstream `src/components/ui/page.tsx`.
class PageTitle extends StatefulWidget {
  const PageTitle(
    this.child, {
    super.key,
    this.underline = TitleMark.single,
    this.seed,
  });

  /// The title.
  final Widget child;

  /// The mark under the title; none when null.
  final TitleMark? underline;

  /// Pins the mark.
  final String? seed;

  @override
  State<PageTitle> createState() => _PageTitleState();
}

class _PageTitleState extends State<PageTitle> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final title = Padding(
      padding: const EdgeInsets.only(bottom: Spacing.d6),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: 41.6,
          cssLineHeight: 1.08,
          fontWeight: FontWeight.w700,
        ),
        child: widget.child,
      ),
    );
    final mark = widget.underline;
    final Widget body = switch (mark) {
      null => title,
      final kind => InkSurface(
        source: RecipeInkSource(
          titleMarkRecipe,
          TitleMarkParams(kind: kind),
          json: TitleMarkParams(kind: kind).toJson(),
        ),
        seed: inkSeed(widget.seed),
        still: true,
        child: title,
      ),
    };
    return Semantics(
      container: true,
      header: true,
      child: Align(alignment: AlignmentDirectional.centerStart, child: body),
    );
  }
}
