import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-md`.
const _maxWidth = 448.0;

class IconInContextExample extends StatelessWidget {
  const IconInContextExample({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final status = [
      (
        icon: 'circle-check',
        text: 'Saved to your notebook',
        color: colors.green,
      ),
      (
        icon: 'info',
        text: 'Drafts are kept for thirty days',
        color: colors.inkYou,
      ),
      (
        icon: 'triangle-alert',
        text: 'This page has unsaved changes',
        color: colors.orangeText,
      ),
      (
        icon: 'octagon-x',
        text: 'Could not reach the server',
        color: colors.red,
      ),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d8,
            children: [
              for (final row in status)
                Row(
                  spacing: Spacing.d8,
                  children: [
                    InkIcon(row.icon, size: Spacing.d20, color: row.color),
                    Expanded(child: Text(row.text)),
                  ],
                ),
            ],
          ),
          Row(
            spacing: Spacing.d12,
            children: [
              Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.sm,
                onPressed: () {},
                leading: const InkIcon('copy'),
                child: const Text('Copy'),
              ),
              Button(
                variant: ButtonVariant.ghost,
                size: ButtonSize.iconSm,
                semanticLabel: 'More',
                onPressed: () {},
                child: const InkIcon('ellipsis'),
              ),
              Button(
                variant: ButtonVariant.ghost,
                size: ButtonSize.sm,
                onPressed: () {},
                trailing: const InkIcon('chevron-down'),
                child: const Text('Options'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
