import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-xs`.
const _footerMaxWidth = 320.0;

const _directions = [
  OverlaySide.bottom,
  OverlaySide.top,
  OverlaySide.left,
  OverlaySide.right,
];

class DrawerDirectionsExample extends StatelessWidget {
  const DrawerDirectionsExample({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: Spacing.d12,
    runSpacing: Spacing.d12,
    children: [
      for (final direction in _directions)
        Drawer(
          direction: direction,
          content: DrawerContent(
            seed: 'dir-${direction.name}',
            children: [
              DrawerHeader(
                children: [
                  DrawerTitle(Text('From the ${direction.name}')),
                  DrawerDescription(
                    Text(
                      'Drag it back toward the ${direction.name} edge to put '
                      'it away.',
                    ),
                  ),
                ],
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _footerMaxWidth),
                  child: DrawerFooter(
                    children: [
                      DrawerClose(
                        builder: (context, close) => Button(
                          variant: ButtonVariant.outline,
                          onPressed: close,
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          child: DrawerTrigger.builder(
            builder: (context, drawer) => Button(
              variant: ButtonVariant.outline,
              onPressed: drawer.show,
              child: Text(
                '${direction.name[0].toUpperCase()}${direction.name.substring(1)}',
              ),
            ),
          ),
        ),
    ],
  );
}
