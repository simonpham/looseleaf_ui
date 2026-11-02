import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/sheet/sheet.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SheetSideExample extends StatelessWidget {
  const SheetSideExample({super.key});

  static const _triggerWidth = 120.0;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _triggerWidth * 2 + Spacing.d8,
    child: Wrap(
      spacing: Spacing.d8,
      runSpacing: Spacing.d8,
      children: [
        for (final side in OverlaySide.values)
          SizedBox(
            width: _triggerWidth,
            child: Sheet(
              content: SheetContent(
                side: side,
                children: [
                  const SheetHeader(
                    children: [
                      SheetTitle(Text('Edit profile')),
                      SheetDescription(
                        Text(
                          "Make changes to your profile here. Click save when you're done.",
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(Spacing.d16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d16,
                      children: [
                        SheetProfileField(
                          label: 'Name',
                          value: 'Pedro Duarte',
                          inline: true,
                        ),
                        SheetProfileField(
                          label: 'Username',
                          value: '@peduarte',
                          inline: true,
                        ),
                      ],
                    ),
                  ),
                  SheetFooter(
                    children: [
                      SheetClose(
                        builder: (context, close) => Button(
                          onPressed: close,
                          child: const Text('Save changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              child: SheetTrigger.builder(
                builder: (context, sheet) => Button(
                  variant: ButtonVariant.outline,
                  onPressed: sheet.show,
                  child: Text(side.name),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
