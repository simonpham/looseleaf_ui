import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A postcard sign-up on a card: an email field that checks its address
/// and a Subscribe button, then a thank-you once sent.
///
/// Mirrors upstream `src/blocks/sidebar-06/components/sidebar-06-opt-in-form.tsx`.
class Sidebar06OptInForm extends StatefulWidget {
  const Sidebar06OptInForm({super.key, this.onSubmit});

  /// Called with the address once it looks right.
  final ValueChanged<String>? onSubmit;

  @override
  State<Sidebar06OptInForm> createState() => _Sidebar06OptInFormState();
}

class _Sidebar06OptInFormState extends State<Sidebar06OptInForm> {
  final _email = TextEditingController();
  bool _sent = false;
  String? _error;

  static final _address = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    if (!_address.hasMatch(email)) {
      setState(() => _error = 'That does not look like an email address yet.');
      return;
    }
    widget.onSubmit?.call(email);
    setState(() {
      _error = null;
      _sent = true;
    });
  }

  Widget _form(LooseleafThemeData theme) {
    final error = _error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d10,
      children: [
        SidebarInput(
          controller: _email,
          placeholder: 'you@example.com',
          semanticLabel: 'Email address',
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _submit(),
        ),
        if (error != null)
          Semantics(
            liveRegion: true,
            child: Text(
              error,
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: 14,
                color: theme.colors.red,
              ),
            ),
          ),
        Button(
          size: ButtonSize.sm,
          onPressed: _submit,
          child: const Text('Subscribe'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Card(
      gap: Spacing.d8,
      padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
      seed: 'sidebar-06-opt-in',
      children: [
        CardHeader(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
          children: [
            CardTitle(
              Text(
                'Get the postcard',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 20,
                  cssLineHeight: 28 / 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const CardDescription(
              Text(
                'A short note on new pens and papers, every other Friday. Only ink, no spam.',
              ),
            ),
          ],
        ),
        CardContent(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
          child: switch (_sent) {
            true => Semantics(
              liveRegion: true,
              child: Text(
                'Thank you! Watch your mailbox on Friday.',
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 14,
                  color: theme.colors.green,
                ),
              ),
            ),
            false => _form(theme),
          },
        ),
      ],
    );
  }
}
