import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleDemoExample extends StatefulWidget {
  const ToggleDemoExample({super.key});

  @override
  State<ToggleDemoExample> createState() => _ToggleDemoExampleState();
}

class _ToggleDemoExampleState extends State<ToggleDemoExample> {
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Toggle(
      value: _bookmarked,
      onChanged: (value) => setState(() => _bookmarked = value),
      size: ToggleSize.sm,
      variant: ToggleVariant.outline,
      semanticLabel: 'Toggle bookmark',
      leading: InkIcon(
        'bookmark',
        color: switch (_bookmarked) {
          true => theme.colors.inkYou,
          false => null,
        },
      ),
      child: const Text('Bookmark'),
    );
  }
}
