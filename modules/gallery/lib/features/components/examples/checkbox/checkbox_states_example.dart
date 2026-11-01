import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CheckboxStatesExample extends StatelessWidget {
  const CheckboxStatesExample({super.key});

  static const _sizes = [
    (Spacing.d16, '16 px'),
    (Spacing.d20, '20 px'),
    (Spacing.d28, '28 px'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d20,
      children: [
        for (final (size, name) in _sizes)
          Wrap(
            spacing: Spacing.d24,
            runSpacing: Spacing.d12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: Spacing.d56,
                child: Text(
                  name,
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ),
              _LooseCheckbox(size: size, name: '$name off'),
              _LooseCheckbox(size: size, name: '$name on', initial: true),
              Checkbox(
                value: null,
                onChanged: (_) {},
                size: size,
                semanticLabel: '$name partly',
              ),
              _LooseCheckbox(size: size, name: '$name invalid', invalid: true),
              Checkbox(
                value: false,
                disabled: true,
                size: size,
                semanticLabel: '$name disabled',
              ),
              Checkbox(
                value: true,
                disabled: true,
                size: size,
                semanticLabel: '$name disabled on',
              ),
            ],
          ),
        const Checkbox(
          value: true,
          disabled: true,
          label: Text('Locked by your admin'),
        ),
      ],
    );
  }
}

class _LooseCheckbox extends StatefulWidget {
  const _LooseCheckbox({
    required this.size,
    required this.name,
    this.initial = false,
    this.invalid = false,
  });

  final double size;
  final String name;
  final bool initial;
  final bool invalid;

  @override
  State<_LooseCheckbox> createState() => _LooseCheckboxState();
}

class _LooseCheckboxState extends State<_LooseCheckbox> {
  late bool _checked = widget.initial;

  @override
  Widget build(BuildContext context) => Checkbox(
    value: _checked,
    onChanged: (value) => setState(() => _checked = value),
    size: widget.size,
    invalid: widget.invalid,
    semanticLabel: widget.name,
  );
}
