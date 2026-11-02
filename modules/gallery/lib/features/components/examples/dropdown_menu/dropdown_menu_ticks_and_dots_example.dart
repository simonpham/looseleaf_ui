import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DropdownMenuTicksAndDotsExample extends StatefulWidget {
  const DropdownMenuTicksAndDotsExample({super.key});

  @override
  State<DropdownMenuTicksAndDotsExample> createState() =>
      _DropdownMenuTicksAndDotsExampleState();
}

class _DropdownMenuTicksAndDotsExampleState
    extends State<DropdownMenuTicksAndDotsExample> {
  static const _width = Spacing.d224;

  bool _status = true;
  bool _activity = false;
  bool _panel = true;
  String _position = 'bottom';

  String get _summary {
    final shown = [if (_status) 'status bar', if (_panel) 'panel'];
    final what = switch (shown) {
      [] => 'nothing',
      _ => shown.join(' + '),
    };
    return '$what · panel $_position';
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d12,
      children: [
        DropdownMenu(
          content: DropdownMenuContent(
            minWidth: _width,
            seed: 'view',
            children: [
              const DropdownMenuLabel(child: Text('Appearance')),
              DropdownMenuCheckboxItem(
                value: _status,
                onChanged: (value) => setState(() => _status = value),
                closeOnSelect: false,
                child: const Text('Status bar'),
              ),
              DropdownMenuCheckboxItem(
                value: _activity,
                onChanged: (value) => setState(() => _activity = value),
                closeOnSelect: false,
                disabled: true,
                child: const Text('Activity bar'),
              ),
              DropdownMenuCheckboxItem(
                value: _panel,
                onChanged: (value) => setState(() => _panel = value),
                closeOnSelect: false,
                child: const Text('Panel'),
              ),
              const DropdownMenuSeparator(),
              const DropdownMenuLabel(child: Text('Panel position')),
              DropdownMenuRadioGroup(
                value: _position,
                onChanged: (value) => setState(() => _position = value),
                children: const [
                  DropdownMenuRadioItem(value: 'top', child: Text('Top')),
                  DropdownMenuRadioItem(value: 'bottom', child: Text('Bottom')),
                  DropdownMenuRadioItem(value: 'right', child: Text('Right')),
                ],
              ),
            ],
          ),
          child: DropdownMenuTrigger.builder(
            builder: (context, menu) => Button(
              variant: ButtonVariant.outline,
              leading: const InkIcon('sliders-horizontal'),
              onPressed: menu.toggle,
              child: const Text('View'),
            ),
          ),
        ),
        Text(
          _summary,
          style: theme.typography.interface(
            cssSize: 14,
            color: theme.colors.inkMuted,
          ),
        ),
      ],
    );
  }
}
