import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RevealFeatureListExample extends StatefulWidget {
  const RevealFeatureListExample({super.key});

  @override
  State<RevealFeatureListExample> createState() =>
      _RevealFeatureListExampleState();
}

class _RevealFeatureListExampleState extends State<RevealFeatureListExample> {
  static const _features = [
    'Hand-drawn, every pixel',
    'Accessible, every state',
    'Keyboard first',
    'Works without a mouse',
    'Reduced motion respected',
  ];
  static const _maxWidth = Spacing.d384;

  final _checked = {..._features};

  void _toggle(String feature) => setState(() {
    if (_checked.remove(feature)) return;
    _checked.add(feature);
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Reveal.stagger(
        effect: RevealEffect.soak,
        stagger: const Duration(milliseconds: 140),
        spacing: Spacing.d12,
        children: [
          for (final feature in _features)
            Row(
              spacing: Spacing.d8,
              children: [
                Checkbox(
                  value: _checked.contains(feature),
                  onChanged: (_) => _toggle(feature),
                  semanticLabel: feature,
                ),
                Label(
                  onPressed: () => _toggle(feature),
                  child: Text(
                    feature,
                    style: theme.typography.interface(cssSize: 16),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
