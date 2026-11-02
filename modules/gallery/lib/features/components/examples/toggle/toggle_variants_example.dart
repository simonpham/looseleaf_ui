import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleVariantsExample extends StatelessWidget {
  const ToggleVariantsExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d20,
    children: [
      _Row(variant: ToggleVariant.primary),
      _Row(variant: ToggleVariant.outline),
    ],
  );
}

class _Row extends StatelessWidget {
  const _Row({required this.variant});

  final ToggleVariant variant;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d16,
    runSpacing: Spacing.d16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Toggle(
        variant: variant,
        semanticLabel: 'Show hidden pages',
        child: const InkIcon('eye'),
      ),
      Toggle(
        variant: variant,
        defaultValue: true,
        semanticLabel: 'Show hidden pages, on',
        child: const InkIcon('eye'),
      ),
      Toggle(
        variant: variant,
        leading: const InkIcon('bell'),
        child: const Text('Watch'),
      ),
      Toggle(
        variant: variant,
        defaultValue: true,
        leading: const InkIcon('bell'),
        child: const Text('Watching'),
      ),
    ],
  );
}
