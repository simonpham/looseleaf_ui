import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EmptyBackgroundExample extends StatelessWidget {
  const EmptyBackgroundExample({super.key});

  @override
  Widget build(BuildContext context) {
    final shade = LooseleafTheme.of(context).colors.paperShade;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d512),
      child: SizedBox(
        height: Spacing.d320,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.3, 1],
              colors: [
                shade.withValues(alpha: 0.6),
                shade.withValues(alpha: 0),
              ],
            ),
          ),
          child: Empty(
            children: [
              const EmptyHeader(
                children: [
                  EmptyMedia(
                    variant: EmptyMediaVariant.icon,
                    child: InkIcon('bell'),
                  ),
                  EmptyTitle(child: Text('No Notifications')),
                  EmptyDescription(
                    child: Text(
                      "You're all caught up. New notifications will appear here.",
                    ),
                  ),
                ],
              ),
              EmptyContent(
                children: [
                  Button(
                    variant: ButtonVariant.outline,
                    size: ButtonSize.sm,
                    leading: const InkIcon('rotate-cw'),
                    onPressed: () {},
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
