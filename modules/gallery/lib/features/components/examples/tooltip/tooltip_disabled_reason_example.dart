import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TooltipDisabledReasonExample extends StatelessWidget {
  const TooltipDisabledReasonExample({super.key});

  @override
  Widget build(BuildContext context) => const TooltipProvider(
    child: Padding(
      padding: EdgeInsets.only(top: Spacing.d40),
      child: Tooltip(
        content: TooltipContent(
          stock: StockName.stickyPink,
          child: Text('Add a title first, then you can publish.'),
        ),
        child: Focus(
          child: Button(disabled: true, child: Text('Publish notebook')),
        ),
      ),
    ),
  );
}
