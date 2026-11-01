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
      _HeldToggle(
        variant: variant,
        semanticLabel: 'Show hidden pages',
        child: const InkIcon('eye'),
      ),
      _HeldToggle(
        variant: variant,
        initialValue: true,
        semanticLabel: 'Show hidden pages, on',
        child: const InkIcon('eye'),
      ),
      _HeldToggle(
        variant: variant,
        leading: const InkIcon('bell'),
        child: const Text('Watch'),
      ),
      _HeldToggle(
        variant: variant,
        initialValue: true,
        leading: const InkIcon('bell'),
        child: const Text('Watching'),
      ),
    ],
  );
}

class _HeldToggle extends StatefulWidget {
  const _HeldToggle({
    required this.variant,
    required this.child,
    this.initialValue = false,
    this.leading,
    this.semanticLabel,
  });

  final ToggleVariant variant;
  final Widget child;
  final bool initialValue;
  final Widget? leading;
  final String? semanticLabel;

  @override
  State<_HeldToggle> createState() => _HeldToggleState();
}

class _HeldToggleState extends State<_HeldToggle> {
  late bool _value = widget.initialValue;

  @override
  Widget build(BuildContext context) => Toggle(
    value: _value,
    onChanged: (value) => setState(() => _value = value),
    variant: widget.variant,
    leading: widget.leading,
    semanticLabel: widget.semanticLabel,
    child: widget.child,
  );
}
