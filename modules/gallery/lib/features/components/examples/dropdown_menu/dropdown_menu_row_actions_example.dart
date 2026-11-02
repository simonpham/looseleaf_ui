import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DropdownMenuRowActionsExample extends StatefulWidget {
  const DropdownMenuRowActionsExample({super.key});

  @override
  State<DropdownMenuRowActionsExample> createState() =>
      _DropdownMenuRowActionsExampleState();
}

class _DropdownMenuRowActionsExampleState
    extends State<DropdownMenuRowActionsExample> {
  static const _maxWidth = Spacing.d384;
  static const _menuWidth = Spacing.d192;

  var _names = ['Field notes', 'Garden log', 'Recipes', 'Trip to Lisbon'];
  String _last = '';

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Card(
      seed: 'rows',
      children: [
        CardHeader(
          children: [
            const CardTitle(Text('Notebooks')),
            CardDescription(
              Text(switch (_last) {
                '' => "Open a row's menu with its ellipsis.",
                _ => _last,
              }),
            ),
          ],
        ),
        CardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d4,
            children: [
              for (final name in _names)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.d2),
                  child: Row(
                    spacing: Spacing.d8,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _RowMenu(
                        name: name,
                        width: _menuWidth,
                        onOpen: () => setState(() => _last = 'Opened $name'),
                        onRename: () => setState(
                          () => _names = [
                            for (final other in _names)
                              switch (other == name) {
                                true => '$other (copy)',
                                false => other,
                              },
                          ],
                        ),
                        onTrash: () => setState(
                          () => _names = [
                            for (final other in _names)
                              if (other != name) other,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RowMenu extends StatelessWidget {
  const _RowMenu({
    required this.name,
    required this.width,
    required this.onOpen,
    required this.onRename,
    required this.onTrash,
  });

  final String name;
  final double width;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onTrash;

  @override
  Widget build(BuildContext context) => DropdownMenu(
    content: DropdownMenuContent(
      align: OverlayAlign.end,
      minWidth: width,
      children: [
        DropdownMenuLabel(child: Text(name)),
        DropdownMenuItem(
          leading: const InkIcon('folder-open'),
          onSelect: onOpen,
          child: const Text('Open'),
        ),
        DropdownMenuItem(
          leading: const InkIcon('pencil'),
          onSelect: onRename,
          child: const Text('Rename'),
        ),
        const DropdownMenuSeparator(),
        DropdownMenuItem(
          variant: InkMenuItemVariant.destructive,
          leading: const InkIcon('trash'),
          onSelect: onTrash,
          child: const Text('Move to trash'),
        ),
      ],
    ),
    child: DropdownMenuTrigger.builder(
      builder: (context, menu) => Button(
        variant: ButtonVariant.ghost,
        size: ButtonSize.iconSm,
        semanticLabel: 'Actions for $name',
        onPressed: menu.toggle,
        child: const InkIcon('ellipsis'),
      ),
    ),
  );
}
