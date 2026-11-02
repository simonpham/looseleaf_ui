import 'package:flutter/widgets.dart' hide RadioGroup;
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RadioGroupInAFormExample extends StatefulWidget {
  const RadioGroupInAFormExample({super.key});

  @override
  State<RadioGroupInAFormExample> createState() =>
      _RadioGroupInAFormExampleState();
}

class _RadioGroupInAFormExampleState extends State<RadioGroupInAFormExample> {
  String? _ink;
  bool _tried = false;
  String _sent = '';

  void _vote() {
    final ink = _ink;
    if (ink == null) {
      setState(() => _tried = true);
      return;
    }
    setState(() => _sent = 'Ink of the month: $ink');
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d12,
            children: [
              Text(
                'Ink of the month',
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              RadioGroup<String>(
                value: _ink,
                onChanged: (value) => setState(() => _ink = value),
                invalid: _tried && _ink == null,
                semanticLabel: 'Ink of the month',
                children: [
                  for (final ink in const ['Black', 'Blue', 'Sepia'])
                    RadioGroupItem(value: ink.toLowerCase(), label: Text(ink)),
                ],
              ),
            ],
          ),
          Row(
            spacing: Spacing.d12,
            children: [
              Button(onPressed: _vote, child: const Text('Vote')),
              Semantics(
                liveRegion: true,
                child: Text(
                  _sent,
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
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
