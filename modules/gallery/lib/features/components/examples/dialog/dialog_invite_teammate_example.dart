import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DialogInviteTeammateExample extends StatefulWidget {
  const DialogInviteTeammateExample({super.key});

  @override
  State<DialogInviteTeammateExample> createState() =>
      _DialogInviteTeammateExampleState();
}

class _DialogInviteTeammateExampleState
    extends State<DialogInviteTeammateExample> {
  final _email = TextEditingController();
  final _emailFocus = FocusNode();
  final _invited = <String>[];
  bool _open = false;

  @override
  void dispose() {
    _email.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _invited.add(email);
      _open = false;
    });
    _email.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d12,
      children: [
        Dialog(
          open: _open,
          onOpenChange: (open) => setState(() => _open = open),
          content: DialogContent(
            tape: PaperTape.top,
            tapeKind: TapeKind.kraft,
            seed: 'invite',
            maxWidth: Spacing.d384,
            children: [
              const DialogHeader(
                children: [
                  DialogTitle(Text('Invite a teammate')),
                  DialogDescription(
                    Text('They will get a link to this notebook by email.'),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d8,
                children: [
                  Label(focusNode: _emailFocus, child: const Text('Email')),
                  Input(
                    controller: _email,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    placeholder: 'ada@analytical.engine',
                    semanticLabel: 'Email',
                    onSubmitted: (_) => _submit(),
                  ),
                ],
              ),
              DialogFooter(
                children: [
                  Button(
                    variant: ButtonVariant.ghost,
                    onPressed: () => setState(() => _open = false),
                    child: const Text('Not now'),
                  ),
                  Button(onPressed: _submit, child: const Text('Send invite')),
                ],
              ),
            ],
          ),
          child: DialogTrigger.builder(
            builder: (context, dialog) => Button(
              onPressed: dialog.show,
              child: const Text('Invite a teammate'),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Spacing.d24),
          child: Semantics(
            liveRegion: true,
            child: Text(
              switch (_invited) {
                [] => 'Nobody invited yet.',
                final emails => 'Invited: ${emails.join(', ')}',
              },
              textAlign: TextAlign.center,
              style: theme.typography.interface(
                cssSize: 14,
                color: theme.colors.inkMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
