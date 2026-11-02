import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupVariantsSpacingExample extends StatefulWidget {
  const ToggleGroupVariantsSpacingExample({super.key});

  @override
  State<ToggleGroupVariantsSpacingExample> createState() =>
      _ToggleGroupVariantsSpacingExampleState();
}

class _ToggleGroupVariantsSpacingExampleState
    extends State<ToggleGroupVariantsSpacingExample> {
  static const _items = [
    ToggleGroupItem(
      value: 'list',
      semanticLabel: 'List',
      child: InkIcon('list'),
    ),
    ToggleGroupItem(
      value: 'menu',
      semanticLabel: 'Menu',
      child: InkIcon('menu'),
    ),
    ToggleGroupItem(
      value: 'search',
      semanticLabel: 'Search',
      child: InkIcon('search'),
    ),
  ];

  final _values = <String, Set<String>>{};

  Widget _case(
    String label, {
    ToggleVariant variant = ToggleVariant.outline,
    double spacing = 0,
    ToggleTone? tone,
    ToggleSize size = ToggleSize.regular,
    Axis direction = Axis.horizontal,
    bool disabled = false,
  }) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d8,
      children: [
        ToggleGroup<String>(
          variant: variant,
          spacing: spacing,
          tone: tone,
          size: size,
          direction: direction,
          disabled: disabled,
          value: _values[label] ?? const {'menu'},
          onChanged: (value) => setState(() => _values[label] = value),
          semanticLabel: label,
          children: _items,
        ),
        Text(
          label,
          style: theme.typography.interface(
            cssSize: 14,
            color: theme.colors.inkMuted,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.d40,
    runSpacing: Spacing.d24,
    children: [
      _case('joined'),
      _case('spacing 2', spacing: Spacing.d8),
      _case('borderless', variant: ToggleVariant.primary),
      _case('marker, sm', tone: ToggleTone.marker, size: ToggleSize.sm),
      _case('vertical', direction: Axis.vertical),
      _case('disabled', disabled: true),
    ],
  );
}
