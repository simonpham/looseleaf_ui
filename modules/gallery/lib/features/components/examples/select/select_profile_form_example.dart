import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SelectProfileFormExample extends StatefulWidget {
  const SelectProfileFormExample({super.key});

  @override
  State<SelectProfileFormExample> createState() =>
      _SelectProfileFormExampleState();
}

class _SelectProfileFormExampleState extends State<SelectProfileFormExample> {
  static const _roles = ['Author', 'Editor', 'Proofreader', 'Illustrator'];

  String _role = 'Editor';
  String? _shift;
  bool _missing = false;
  String _sent = '';

  void _file() => setState(() {
    final shift = _shift;
    _missing = shift == null;
    if (shift == null) return;
    _sent = 'Filed: $_role on the $shift shift';
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d96 * 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d8,
            children: [
              const Label(child: Text('Your role')),
              Select(
                value: _role,
                onChanged: (role) => setState(() => _role = role),
                content: SelectContent(
                  position: SelectPosition.popper,
                  children: [
                    for (final role in _roles)
                      SelectItem(value: role, child: Text(role)),
                  ],
                ),
                child: const SelectTrigger(semanticLabel: 'Your role'),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d8,
            children: [
              const Label(required: true, child: Text('Shift')),
              Select(
                value: _shift,
                onChanged: (shift) => setState(() {
                  _shift = shift;
                  _missing = false;
                }),
                content: const SelectContent(
                  position: SelectPosition.popper,
                  children: [
                    SelectItem(value: 'morning', child: Text('Morning')),
                    SelectItem(value: 'evening', child: Text('Evening')),
                    SelectItem(value: 'night', child: Text('Night')),
                  ],
                ),
                child: SelectTrigger(
                  invalid: _missing,
                  semanticLabel: 'Shift',
                  child: const SelectValue(
                    placeholder: 'Morning, evening or night',
                  ),
                ),
              ),
            ],
          ),
          Row(
            spacing: Spacing.d12,
            children: [
              Button(onPressed: _file, child: const Text('File it')),
              Expanded(
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
