import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupTextExample extends StatelessWidget {
  const InputGroupTextExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d24,
        children: [
          const InputGroup(
            children: [
              InputGroupAddon(child: InputGroupText(child: Text(r'$'))),
              InputGroupInput(placeholder: '0.00', semanticLabel: 'Amount'),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: InputGroupText(child: Text('USD')),
              ),
            ],
          ),
          const InputGroup(
            children: [
              InputGroupAddon(child: InputGroupText(child: Text('https://'))),
              InputGroupInput(
                placeholder: 'example.com',
                semanticLabel: 'Domain',
              ),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: InputGroupText(child: Text('.com')),
              ),
            ],
          ),
          const InputGroup(
            children: [
              InputGroupInput(
                placeholder: 'Enter your username',
                semanticLabel: 'Username',
              ),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: InputGroupText(child: Text('@company.com')),
              ),
            ],
          ),
          InputGroup(
            children: [
              const InputGroupTextarea(
                placeholder: 'Enter your message',
                semanticLabel: 'Message',
              ),
              InputGroupAddon(
                align: InputGroupAlign.blockEnd,
                child: InputGroupText(
                  child: Text(
                    '120 characters left',
                    style: theme.typography.interface(
                      cssSize: 12,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
