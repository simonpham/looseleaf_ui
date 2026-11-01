import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleSizesAndStatesExample extends StatefulWidget {
  const ToggleSizesAndStatesExample({super.key});

  @override
  State<ToggleSizesAndStatesExample> createState() =>
      _ToggleSizesAndStatesExampleState();
}

class _ToggleSizesAndStatesExampleState
    extends State<ToggleSizesAndStatesExample> {
  final Set<String> _on = {'list-sm', 'list', 'list-lg', 'draw'};

  ValueChanged<bool> _onChanged(String id) =>
      (value) => setState(() {
        if (value) {
          _on.add(id);
          return;
        }
        _on.remove(id);
      });

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
          Toggle(
            variant: ToggleVariant.outline,
            size: ToggleSize.sm,
            value: _on.contains('list-sm'),
            onChanged: _onChanged('list-sm'),
            semanticLabel: 'List, small',
            child: const InkIcon('list'),
          ),
          Toggle(
            variant: ToggleVariant.outline,
            value: _on.contains('list'),
            onChanged: _onChanged('list'),
            semanticLabel: 'List',
            child: const InkIcon('list'),
          ),
          Toggle(
            variant: ToggleVariant.outline,
            size: ToggleSize.lg,
            value: _on.contains('list-lg'),
            onChanged: _onChanged('list-lg'),
            semanticLabel: 'List, large',
            child: const InkIcon('list'),
          ),
          Toggle(
            variant: ToggleVariant.outline,
            size: ToggleSize.lg,
            tone: ToggleTone.marker,
            value: _on.contains('draw'),
            onChanged: _onChanged('draw'),
            leading: const InkIcon('pencil'),
            child: const Text('Draw'),
          ),
        ],
      ),
      const Wrap(
        spacing: Spacing.d16,
        runSpacing: Spacing.d16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Toggle(
            value: false,
            disabled: true,
            leading: InkIcon('eye-off'),
            child: Text('Hidden'),
          ),
          Toggle(
            value: true,
            disabled: true,
            leading: InkIcon('eye-off'),
            child: Text('Hidden'),
          ),
          Toggle(
            variant: ToggleVariant.outline,
            value: false,
            disabled: true,
            child: Text('Locked'),
          ),
          Toggle(
            variant: ToggleVariant.outline,
            value: true,
            disabled: true,
            child: Text('Locked'),
          ),
        ],
      ),
    ],
  );
}
