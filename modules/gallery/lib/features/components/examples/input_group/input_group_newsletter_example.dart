import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

enum _Sent { idle, bad, ok }

class InputGroupNewsletterExample extends StatefulWidget {
  const InputGroupNewsletterExample({super.key});

  @override
  State<InputGroupNewsletterExample> createState() =>
      _InputGroupNewsletterExampleState();
}

class _InputGroupNewsletterExampleState
    extends State<InputGroupNewsletterExample> {
  static final _address = RegExp(r'^\S+@\S+\.\S+$');

  final _focus = FocusNode();
  String _email = '';
  _Sent _sent = _Sent.idle;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _subscribe() => setState(
    () => _sent = switch (_address.hasMatch(_email)) {
      true => _Sent.ok,
      false => _Sent.bad,
    },
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d8,
        children: [
          Label(
            focusNode: _focus,
            child: const Text('Field notes, twice a month'),
          ),
          InputGroup(
            focusNode: _focus,
            invalid: _sent == _Sent.bad,
            children: [
              const InputGroupAddon(child: InkIcon('mail')),
              InputGroupInput(
                placeholder: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                semanticLabel: 'Field notes, twice a month',
                onChanged: (email) => setState(() {
                  _email = email;
                  _sent = _Sent.idle;
                }),
                onSubmitted: (_) => _subscribe(),
              ),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: InputGroupButton(
                  variant: ButtonVariant.primary,
                  onPressed: _subscribe,
                  child: const Text('Subscribe'),
                ),
              ),
            ],
          ),
          Semantics(
            liveRegion: true,
            child: Text(
              switch (_sent) {
                _Sent.bad => 'That does not look like an address.',
                _Sent.ok => 'Thank you. Watch your inbox.',
                _Sent.idle => 'No spam, and you can leave with one click.',
              },
              style: theme.typography.interface(
                cssSize: 14,
                color: switch (_sent) {
                  _Sent.bad => theme.colors.red,
                  _ => theme.colors.inkMuted,
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
