import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ProgressStepsExample extends StatefulWidget {
  const ProgressStepsExample({super.key});

  @override
  State<ProgressStepsExample> createState() => _ProgressStepsExampleState();
}

class _ProgressStepsExampleState extends State<ProgressStepsExample> {
  static const _steps = [
    'Name your notebook',
    'Pick a cover',
    'Add a first page',
    'Invite someone',
    'Done',
  ];

  int _step = 2;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final stepText = 'Step $_step of ${_steps.length}';
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  _steps[_step - 1],
                  style: theme.typography
                      .face(KevinSansFace.script, cssSize: 24)
                      .copyWith(height: 1),
                ),
              ),
              Text(
                stepText,
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.inkMuted,
                ),
              ),
            ],
          ),
          Progress(
            value: _step.toDouble(),
            max: _steps.length.toDouble(),
            semanticLabel: 'Setup progress',
            semanticValue: stepText,
          ),
          Row(
            spacing: Spacing.d12,
            children: [
              Button(
                size: ButtonSize.sm,
                variant: ButtonVariant.outline,
                onPressed: () => setState(() => _step = math.max(1, _step - 1)),
                child: const Text('Back'),
              ),
              Button(
                size: ButtonSize.sm,
                onPressed: () =>
                    setState(() => _step = math.min(_steps.length, _step + 1)),
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
