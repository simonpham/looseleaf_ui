import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

enum _Phase { idle, saving, saved }

class SpinnerInButtonsExample extends StatefulWidget {
  const SpinnerInButtonsExample({super.key});

  @override
  State<SpinnerInButtonsExample> createState() =>
      _SpinnerInButtonsExampleState();
}

class _SpinnerInButtonsExampleState extends State<SpinnerInButtonsExample> {
  _Phase _phase = _Phase.idle;
  Timer? _timer;

  void _save() {
    setState(() => _phase = _Phase.saving);
    _timer = Timer(const Duration(milliseconds: 1800), () {
      setState(() => _phase = _Phase.saved);
      _timer = Timer(
        const Duration(milliseconds: 1400),
        () => setState(() => _phase = _Phase.idle),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d20,
    children: [
      Wrap(
        spacing: Spacing.d16,
        runSpacing: Spacing.d16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Button(
            onPressed: _save,
            disabled: _phase == _Phase.saving,
            variant: switch (_phase) {
              _Phase.saved => ButtonVariant.secondary,
              _ => ButtonVariant.primary,
            },
            leading: switch (_phase) {
              _Phase.saving => const Spinner(),
              _ => null,
            },
            child: Text(switch (_phase) {
              _Phase.idle => 'Save changes',
              _Phase.saving => 'Saving',
              _Phase.saved => 'Saved, thanks',
            }),
          ),
          const Button(
            variant: ButtonVariant.outline,
            disabled: true,
            leading: Spinner(),
            child: Text('Please wait'),
          ),
          const Button(
            variant: ButtonVariant.outline,
            size: ButtonSize.icon,
            disabled: true,
            semanticLabel: 'Refreshing',
            child: Spinner(),
          ),
        ],
      ),
      const Wrap(
        spacing: Spacing.d16,
        runSpacing: Spacing.d16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Badge(
            variant: BadgeVariant.secondary,
            leading: Spinner(size: Spacing.d14, semanticLabel: 'Syncing'),
            child: Text('Syncing'),
          ),
          Badge(
            variant: BadgeVariant.outline,
            leading: Spinner(size: Spacing.d14, semanticLabel: 'Uploading'),
            child: Text('Uploading 3 of 7'),
          ),
        ],
      ),
    ],
  );
}
