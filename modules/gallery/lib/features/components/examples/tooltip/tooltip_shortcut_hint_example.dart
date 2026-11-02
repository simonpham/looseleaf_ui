import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TooltipShortcutHintExample extends StatelessWidget {
  const TooltipShortcutHintExample({super.key});

  static const _patientWidth = 224.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return TooltipProvider(
      delay: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.only(top: Spacing.d40),
        child: Wrap(
          spacing: Spacing.d16,
          runSpacing: Spacing.d16,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Tooltip(
              delay: Duration.zero,
              content: const TooltipContent(child: Text('Instant: Search')),
              child: Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.icon,
                semanticLabel: 'Search',
                onPressed: () {},
                child: const InkIcon('search'),
              ),
            ),
            Tooltip(
              content: TooltipContent(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d8,
                  children: [
                    const Text('Copy'),
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        '⌘C',
                        style: theme.typography.mono(cssSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              child: Button(
                variant: ButtonVariant.outline,
                size: ButtonSize.icon,
                semanticLabel: 'Copy',
                onPressed: () {},
                child: const InkIcon('copy'),
              ),
            ),
            Tooltip(
              delay: const Duration(seconds: 1),
              content: const TooltipContent(
                maxWidth: _patientWidth,
                child: Text(
                  'Patient: sends every unsaved page to the cloud and waits for the answer.',
                ),
              ),
              child: Button(
                variant: ButtonVariant.outline,
                onPressed: () {},
                child: const Text('Sync now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
