import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DropdownMenuSlipsExample extends StatelessWidget {
  const DropdownMenuSlipsExample({super.key});

  static const _width = Spacing.d224;

  @override
  Widget build(BuildContext context) => DropdownMenu(
    content: DropdownMenuContent(
      minWidth: _width,
      stock: StockName.stickyYellow,
      tape: PaperTape.corner,
      seed: 'quick',
      align: OverlayAlign.start,
      children: [
        DropdownMenuItem(
          leading: const InkIcon('pencil'),
          trailing: const DropdownMenuShortcut('F2'),
          onSelect: () {},
          child: const Text('Rename'),
        ),
        DropdownMenuItem(
          leading: const InkIcon('copy'),
          trailing: const DropdownMenuShortcut('⌘D'),
          onSelect: () {},
          child: const Text('Duplicate'),
        ),
        DropdownMenuItem(
          leading: const InkIcon('share'),
          onSelect: () {},
          child: const Text('Share'),
        ),
        const DropdownMenuSeparator(),
        DropdownMenuItem(
          variant: InkMenuItemVariant.destructive,
          leading: const InkIcon('trash'),
          trailing: const DropdownMenuShortcut('⌫'),
          onSelect: () {},
          child: const Text('Delete'),
        ),
      ],
    ),
    child: DropdownMenuTrigger.builder(
      builder: (context, menu) => Button(
        variant: ButtonVariant.secondary,
        leading: const InkIcon('sparkles'),
        onPressed: menu.toggle,
        child: const Text('Quick actions'),
      ),
    ),
  );
}
