import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What a page shows when there is nothing to show: centered media, a
/// script title, a muted description and actions, stacked with room
/// around them.
///
/// [framed] draws a dashed pencil frame round it (upstream's `border`
/// class).
///
/// ```dart
/// Empty(children: [
///   EmptyHeader(children: [
///     EmptyMedia(variant: EmptyMediaVariant.icon, child: InkIcon('folder-plus')),
///     EmptyTitle(child: Text('No projects yet')),
///     EmptyDescription(child: Text('Get started by creating one.')),
///   ]),
///   EmptyContent(children: [Button(child: Text('Create project'))]),
/// ])
/// ```
///
/// Mirrors `Empty` in upstream `src/components/ui/empty.tsx`.
class Empty extends StatefulWidget {
  const Empty({
    super.key,
    required this.children,
    this.framed = false,
    this.padding,
    this.seed,
  });

  final List<Widget> children;

  /// Draws the pencil frame.
  final bool framed;

  /// The padding; 24, or 48 on screens 768 wide and up (`p-6 md:p-12`).
  final EdgeInsetsGeometry? padding;

  /// Pins the hand: the same seed always draws the same frame.
  final String? seed;

  /// Tailwind's `md` breakpoint.
  static const double mediumWidth = 768;

  @override
  State<Empty> createState() => _EmptyState();
}

class _EmptyState extends State<Empty> with InkSeed {
  static final _frame = RecipeInkSource(
    emptyFrameRecipe,
    const NoParams(),
    json: const NoParams().toJson(),
  );

  @override
  Widget build(BuildContext context) {
    final wide =
        (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= Empty.mediumWidth;
    final body = Padding(
      padding:
          widget.padding ??
          EdgeInsets.all(switch (wide) {
            true => Spacing.d48,
            false => Spacing.d24,
          }),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: Spacing.d24,
        children: widget.children,
      ),
    );
    final content = DefaultTextStyle.merge(
      textAlign: TextAlign.center,
      child: body,
    );
    if (!widget.framed) return content;
    return InkSurface(
      source: _frame,
      seed: inkSeed(widget.seed),
      still: true,
      child: content,
    );
  }
}
