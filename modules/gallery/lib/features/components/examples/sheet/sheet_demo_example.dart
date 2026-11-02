import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/sheet/sheet.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SheetDemoExample extends StatelessWidget {
  const SheetDemoExample({super.key});

  @override
  Widget build(BuildContext context) => Sheet(
    content: SheetContent(
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
          padding: EdgeInsets.symmetric(horizontal: Spacing.d16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d24,
            children: [
              SheetProfileField(label: 'Name', value: 'Pedro Duarte'),
              SheetProfileField(label: 'Username', value: '@peduarte'),
            ],
          ),
        ),
        SheetFooter(
          children: [
            Button(onPressed: () {}, child: const Text('Save changes')),
            SheetClose(
              builder: (context, close) => Button(
                variant: ButtonVariant.outline,
                onPressed: close,
                child: const Text('Close'),
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
        child: const Text('Open'),
      ),
    ),
  );
}
