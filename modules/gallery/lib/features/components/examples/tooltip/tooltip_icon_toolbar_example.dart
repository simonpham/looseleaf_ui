import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TooltipIconToolbarExample extends StatelessWidget {
  const TooltipIconToolbarExample({super.key});

  static const _tools = [
    ('plus', 'Add to library'),
    ('pencil', 'Edit notebook'),
    ('copy', 'Duplicate'),
    ('trash', 'Move to bin'),
    ('settings', 'Settings'),
  ];

  @override
  Widget build(BuildContext context) => TooltipProvider(
    delay: const Duration(milliseconds: 300),
    child: Padding(
      padding: const EdgeInsets.only(top: Spacing.d40),
      child: Semantics(
        container: true,
        label: 'Notebook actions',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d8,
          children: [
            for (final (index, (icon, label)) in _tools.indexed)
              Tooltip(
                content: TooltipContent(
                  seed: 'tool-$index',
                  child: Text(label),
                ),
                child: Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.icon,
                  semanticLabel: label,
                  onPressed: () {},
                  child: InkIcon(icon),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
