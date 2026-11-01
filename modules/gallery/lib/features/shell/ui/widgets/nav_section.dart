import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:gallery/features/shell/ui/widgets/nav_count.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A labelled part of the side nav, its label linking to [onPressed].
///
/// Mirrors `NavSection` in upstream `src/docs/kit/Nav.tsx`.
class NavSection extends StatelessWidget {
  const NavSection({
    super.key,
    required this.label,
    this.count,
    this.active = false,
    this.onPressed,
    required this.children,
  });

  final String label;
  final int? count;
  final bool active;
  final VoidCallback? onPressed;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final style = theme.typography.stamp(
      cssSize: 12,
      color: switch (active) {
        true => theme.colors.ink,
        false => theme.colors.inkMuted,
      },
    );
    final Widget text = switch (onPressed) {
      null => Text(label, style: style),
      final press => DocPressable(
        onPressed: press,
        selected: active,
        builder: (context, highlighted) => Highlight(
          show: highlighted || active,
          seed: 'section:$label',
          child: Text(label, style: style),
        ),
      ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.d12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.d8,
              vertical: Spacing.d6,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: text,
                  ),
                ),
                if (count case final value?) NavCount(value, large: true),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
