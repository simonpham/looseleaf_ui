import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/newsletter_01/newsletter_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A newsletter sign-up: the pitch and the form on a taped sheet, beside an
/// envelope that opens and gets a "Subscribed" stamp once you are on the
/// list.
///
/// Mirrors upstream `src/blocks/newsletter-01/page.tsx`.
class Newsletter01Block extends StatefulWidget {
  const Newsletter01Block({super.key, this.onSubscribe});

  /// Signs [email] up; throw to show the failure message.
  final Future<void> Function(String email)? onSubscribe;

  @override
  State<Newsletter01Block> createState() => _Newsletter01BlockState();
}

class _Newsletter01BlockState extends State<Newsletter01Block> {
  final _email = TextEditingController();
  Newsletter01Status _status = Newsletter01Status.idle;
  bool _open = false;

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static const double _maxWidth = 1024;

  @override
  void initState() {
    super.initState();
    _email.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _email
      ..removeListener(_onEmailChanged)
      ..dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    if (!_status.bad) return;
    setState(() => _status = Newsletter01Status.idle);
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _status = Newsletter01Status.invalid);
      return;
    }
    setState(() => _status = Newsletter01Status.sending);
    try {
      await widget.onSubscribe?.call(email);
      if (!mounted) return;
      setState(() {
        _status = Newsletter01Status.done;
        _open = true;
      });
    } on Object {
      if (!mounted) return;
      setState(() => _status = Newsletter01Status.failed);
    }
  }

  void _reset() {
    _email.clear();
    setState(() {
      _status = Newsletter01Status.idle;
      _open = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final roomy = width >= 576;
        final card = Paper(
          tilt: false,
          tape: PaperTape.corner,
          tapeKind: TapeKind.washiDots,
          seed: 'newsletter-card',
          padding: switch (roomy) {
            true => const EdgeInsets.symmetric(
              horizontal: Spacing.d36,
              vertical: Spacing.d40,
            ),
            false => const EdgeInsets.symmetric(
              horizontal: Spacing.d24,
              vertical: Spacing.d32,
            ),
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'The Sunday letter',
                style: theme.typography.face(
                  KevinSansFace.type,
                  cssSize: 14,
                  cssLineHeight: 20 / 14,
                  color: theme.colors.pencilText,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: Spacing.d12),
                child: Lettering(
                  'One short letter, every Sunday',
                  size: LetteringSize.md,
                  wobble: 0.4,
                  seed: 'newsletter-title',
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: Spacing.d16,
                  bottom: Spacing.d24,
                ),
                child: Text(
                  'What we shipped, what we drew, and one good link. Three minutes, best with tea.',
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 18,
                    cssLineHeight: 28 / 18,
                    color: theme.colors.inkSoft,
                  ),
                ),
              ),
              Newsletter01Form(
                status: _status,
                email: _email,
                wide: width >= 512,
                onSubmit: () => unawaited(_submit()),
                onReset: _reset,
              ),
            ],
          ),
        );
        final envelope = Newsletter01Envelope(
          open: _open,
          onOpenChange: (open) => setState(() => _open = open),
          stamped: _status == Newsletter01Status.done,
        );
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.d32,
            vertical: switch (roomy) {
              true => Spacing.d80,
              false => Spacing.d56,
            },
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: switch (width >= 768) {
                true => Row(
                  spacing: Spacing.d56,
                  children: [
                    Expanded(flex: 11, child: card),
                    Expanded(flex: 10, child: envelope),
                  ],
                ),
                false => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d24,
                  children: [card, envelope],
                ),
              },
            ),
          ),
        );
      },
    );
  }
}
