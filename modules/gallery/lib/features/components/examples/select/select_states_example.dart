import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SelectStatesExample extends StatelessWidget {
  const SelectStatesExample({super.key});

  static const double _twoColumnsFrom = Spacing.d160 * 2;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final fields = [
      const _Field(
        label: 'Default',
        child: _Pens(semanticLabel: 'Default'),
      ),
      const _Field(
        label: 'Small',
        child: _Pens(size: SelectSize.sm, semanticLabel: 'Small'),
      ),
      _Field(
        label: 'Invalid',
        help: Text(
          'Choose a pen to continue.',
          style: theme.typography.interface(
            cssSize: 14,
            color: theme.colors.red,
          ),
        ),
        child: const _Pens(invalid: true, semanticLabel: 'Invalid'),
      ),
      const _Field(
        label: 'Disabled',
        child: _Pens(disabled: true, semanticLabel: 'Disabled'),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _twoColumnsFrom) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d20,
            children: fields,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d20,
          children: [
            for (var row = 0; row < fields.length; row += 2)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d32,
                children: [fields[row], fields[row + 1]],
              ),
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.help});

  final String label;
  final Widget child;
  final Widget? help;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d8,
    children: [
      Label(child: Text(label)),
      child,
      ?help,
    ],
  );
}

class _Pens extends StatelessWidget {
  const _Pens({
    required this.semanticLabel,
    this.size = SelectSize.regular,
    this.invalid = false,
    this.disabled = false,
  });

  final String semanticLabel;
  final SelectSize size;
  final bool invalid;
  final bool disabled;

  @override
  Widget build(BuildContext context) => Select(
    defaultValue: switch (disabled) {
      true => 'felt',
      false => null,
    },
    disabled: disabled,
    content: const SelectContent(
      position: SelectPosition.popper,
      children: [
        SelectItem(value: 'felt', child: Text('Felt tip')),
        SelectItem(value: 'pencil', child: Text('Pencil')),
        SelectItem(value: 'marker', child: Text('Marker')),
        SelectItem(
          value: 'quill',
          disabled: true,
          child: Text('Quill (out of ink)'),
        ),
      ],
    ),
    child: SizedBox(
      width: Spacing.d176 + Spacing.d14,
      child: SelectTrigger(
        size: size,
        invalid: invalid,
        disabled: disabled,
        semanticLabel: semanticLabel,
        child: const SelectValue(placeholder: 'Pick a pen'),
      ),
    ),
  );
}
