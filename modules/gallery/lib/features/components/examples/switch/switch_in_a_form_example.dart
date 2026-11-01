import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SwitchInAFormExample extends StatefulWidget {
  const SwitchInAFormExample({super.key});

  @override
  State<SwitchInAFormExample> createState() => _SwitchInAFormExampleState();
}

class _SwitchInAFormExampleState extends State<SwitchInAFormExample> {
  static const _maxWidth = 384.0;

  bool _digest = true;
  bool _marketing = false;
  String _sent = '';

  void _save() {
    final digest = switch (_digest) {
      true => 'weekly',
      false => 'off',
    };
    final marketing = switch (_marketing) {
      true => 'on',
      false => 'off',
    };
    setState(() => _sent = 'Saved: digest $digest, marketing $marketing');
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: Spacing.d16,
            children: [
              Label(
                onPressed: () => setState(() => _digest = !_digest),
                child: const Text('Weekly digest'),
              ),
              Switch(
                value: _digest,
                onChanged: (value) => setState(() => _digest = value),
                semanticLabel: 'Weekly digest',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: Spacing.d16,
            children: [
              Label(
                onPressed: () => setState(() => _marketing = !_marketing),
                child: const Text('Product news'),
              ),
              Switch(
                value: _marketing,
                onChanged: (value) => setState(() => _marketing = value),
                semanticLabel: 'Product news',
              ),
            ],
          ),
          Row(
            spacing: Spacing.d12,
            children: [
              Button(onPressed: _save, child: const Text('Save')),
              Flexible(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _sent,
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
