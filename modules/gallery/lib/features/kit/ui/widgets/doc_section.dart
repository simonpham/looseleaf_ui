import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/doc_heading.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A titled part of a page, upstream `Section` (`src/docs/kit/Section.tsx`).
class DocSection extends StatelessWidget {
  const DocSection({
    super.key,
    required this.title,
    this.level = 2,
    this.description,
    this.trailing,
    required this.children,
  });

  final String title;
  final int level;
  final String? description;

  /// Shown after the title, like a count chip.
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        Wrap(
          spacing: Spacing.d16,
          runSpacing: Spacing.d8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DocHeading(title, level: level),
            ?trailing,
          ],
        ),
        if (description case final text?)
          Text(
            text,
            style: theme.typography.interface(color: theme.colors.inkMuted),
          ),
        ...children,
      ],
    );
  }
}
