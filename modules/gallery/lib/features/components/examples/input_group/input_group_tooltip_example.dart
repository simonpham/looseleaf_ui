import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupTooltipExample extends StatelessWidget {
  const InputGroupTooltipExample({super.key});

  @override
  Widget build(BuildContext context) => TooltipProvider(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          InputGroup(
            children: [
              InputGroupInput(
                placeholder: 'Enter password',
                obscureText: true,
                semanticLabel: 'Password',
              ),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: Tooltip(
                  content: TooltipContent(
                    child: Text('Password must be at least 8 characters'),
                  ),
                  child: InputGroupButton(
                    size: InputGroupButtonSize.iconXs,
                    semanticLabel: 'Info',
                    child: InkIcon('info'),
                  ),
                ),
              ),
            ],
          ),
          InputGroup(
            children: [
              InputGroupInput(
                placeholder: 'Your email address',
                semanticLabel: 'Email address',
              ),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: Tooltip(
                  content: TooltipContent(
                    child: Text("We'll use this to send you notifications"),
                  ),
                  child: InputGroupButton(
                    size: InputGroupButtonSize.iconXs,
                    semanticLabel: 'Help',
                    child: InkIcon('circle-question-mark'),
                  ),
                ),
              ),
            ],
          ),
          InputGroup(
            children: [
              InputGroupInput(
                placeholder: 'Enter API key',
                semanticLabel: 'API key',
              ),
              InputGroupAddon(
                child: Tooltip(
                  content: TooltipContent(
                    side: OverlaySide.left,
                    child: Text('Click for help with API keys'),
                  ),
                  child: InputGroupButton(
                    size: InputGroupButtonSize.iconXs,
                    semanticLabel: 'Help',
                    child: InkIcon('circle-question-mark'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
