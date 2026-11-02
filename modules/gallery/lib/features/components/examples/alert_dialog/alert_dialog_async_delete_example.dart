import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AlertDialogAsyncDeleteExample extends StatefulWidget {
  const AlertDialogAsyncDeleteExample({super.key});

  @override
  State<AlertDialogAsyncDeleteExample> createState() =>
      _AlertDialogAsyncDeleteExampleState();
}

class _AlertDialogAsyncDeleteExampleState
    extends State<AlertDialogAsyncDeleteExample> {
  bool _open = false;
  bool _busy = false;
  bool _gone = false;
  Timer? _timer;

  void _remove() {
    setState(() => _busy = true);
    _timer = Timer(
      const Duration(milliseconds: 900),
      () => setState(() {
        _busy = false;
        _gone = true;
        _open = false;
      }),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d12,
      children: [
        AlertDialog(
          open: _open,
          onOpenChange: (open) {
            if (_busy) return;
            setState(() => _open = open);
          },
          content: AlertDialogContent(
            tone: AlertDialogTone.danger,
            seed: 'async',
            children: [
              const AlertDialogHeader(
                children: [
                  AlertDialogTitle(Text('Delete the project?')),
                  AlertDialogDescription(
                    Text('Its notebooks, drawings and comments go with it.'),
                  ),
                ],
              ),
              AlertDialogFooter(
                children: [
                  AlertDialogCancel(
                    disabled: _busy,
                    child: const Text('Cancel'),
                  ),
                  AlertDialogAction(
                    variant: ButtonVariant.destructive,
                    disabled: _busy,
                    closeOnPress: false,
                    onPressed: _remove,
                    child: Text(switch (_busy) {
                      true => 'Deleting…',
                      false => 'Yes, delete it',
                    }),
                  ),
                ],
              ),
            ],
          ),
          child: AlertDialogTrigger.builder(
            builder: (context, dialog) => Button(
              variant: ButtonVariant.destructive,
              disabled: _gone,
              onPressed: dialog.show,
              child: Text(switch (_gone) {
                true => 'Deleted',
                false => 'Delete project',
              }),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Spacing.d24),
          child: Semantics(
            liveRegion: true,
            child: Text(
              switch (_gone) {
                true => 'The project was deleted.',
                false => 'Nothing deleted yet.',
              },
              textAlign: TextAlign.center,
              style: theme.typography.interface(
                cssSize: 14,
                color: theme.colors.inkMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
