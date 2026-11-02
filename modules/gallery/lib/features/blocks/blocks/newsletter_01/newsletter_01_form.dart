import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/newsletter_01/newsletter_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The sign-up: an address field and a Subscribe button (side by side
/// when [wide]), the small print and any error. Once [status] is done, a
/// thank-you with a way to start over.
///
/// Mirrors upstream
/// `src/blocks/newsletter-01/components/newsletter-01-form.tsx`.
class Newsletter01Form extends StatefulWidget {
  const Newsletter01Form({
    super.key,
    required this.status,
    required this.email,
    required this.onSubmit,
    required this.onReset,
    this.wide = false,
  });

  /// Where the sign-up is.
  final Newsletter01Status status;

  /// The address being typed.
  final TextEditingController email;

  /// Called by Subscribe and by Enter in the field.
  final VoidCallback onSubmit;

  /// Called by "Use a different address".
  final VoidCallback onReset;

  /// Whether the field and the button share a row.
  final bool wide;

  @override
  State<Newsletter01Form> createState() => _Newsletter01FormState();
}

class _Newsletter01FormState extends State<Newsletter01Form> {
  final _input = FocusNode(debugLabel: 'newsletter email');
  final _done = FocusNode(debugLabel: 'newsletter done');

  @override
  void didUpdateWidget(Newsletter01Form oldWidget) {
    super.didUpdateWidget(oldWidget);
    final status = widget.status;
    if (status == oldWidget.status) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (status == Newsletter01Status.done) _done.requestFocus();
      if (status.bad) _input.requestFocus();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _done.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final status = widget.status;
    if (status == Newsletter01Status.done) {
      return Focus(
        focusNode: _done,
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d8,
            children: [
              Text(
                'You’re on the list.',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 30,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'We sent a note to '),
                    TextSpan(
                      text: widget.email.text.trim(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.ink,
                      ),
                    ),
                    const TextSpan(
                      text: '. Click the link inside to confirm, and the first letter lands on Sunday.',
                    ),
                  ],
                ),
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 18,
                  cssLineHeight: 28 / 18,
                  color: theme.colors.inkSoft,
                ),
              ),
              Button(
                variant: ButtonVariant.link,
                size: ButtonSize.sm,
                onPressed: widget.onReset,
                child: const Text('Use a different address'),
              ),
            ],
          ),
        ),
      );
    }
    final input = Input(
      controller: widget.email,
      focusNode: _input,
      placeholder: 'you@example.com',
      invalid: status.bad,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      onSubmitted: (_) => widget.onSubmit(),
    );
    final button = Button(
      disabled: status == Newsletter01Status.sending,
      onPressed: widget.onSubmit,
      child: Text(switch (status) {
        Newsletter01Status.sending => 'Subscribing…',
        _ => 'Subscribe',
      }),
    );
    return Field(
      invalid: status.bad,
      children: [
        FieldLabel(focusNode: _input, child: const Text('Your email address')),
        switch (widget.wide) {
          true => Row(
            spacing: Spacing.d16,
            children: [
              Expanded(child: input),
              button,
            ],
          ),
          false => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: [input, button],
          ),
        },
        const FieldDescription(
          Text('No spam. Leave with one click. 12,400 people read it.'),
        ),
        if (status == Newsletter01Status.invalid)
          const FieldError(
            child: Text(
              'That does not look like an email address. Check it for typos?',
            ),
          ),
        if (status == Newsletter01Status.failed)
          const FieldError(
            child: Text(
              'Something went wrong on our side. Please try again in a moment.',
            ),
          ),
      ],
    );
  }
}
