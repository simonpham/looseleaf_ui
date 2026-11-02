import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TooltipDemoExample extends StatelessWidget {
  const TooltipDemoExample({super.key});

  @override
  Widget build(BuildContext context) => TooltipProvider(
    child: Tooltip(
      content: const TooltipContent(child: Text('Add to library')),
      child: Button(
        variant: ButtonVariant.outline,
        onPressed: () {},
        child: const Text('Hover'),
      ),
    ),
  );
}
