import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SonnerUndoExample extends StatefulWidget {
  const SonnerUndoExample({super.key});

  @override
  State<SonnerUndoExample> createState() => _SonnerUndoExampleState();
}

class _SonnerUndoExampleState extends State<SonnerUndoExample> {
  final _toasts = ToastController();
  late final _toast = Sonner(_toasts);
  final _portal = OverlayPortalController();
  static const _maxWidth = 320.0;

  var _notes = ['Rain from six.', 'Tea, two cups.', 'Long letter to Ada.'];

  @override
  void initState() {
    super.initState();
    _portal.show();
  }

  @override
  void dispose() {
    _toasts.dispose();
    super.dispose();
  }

  void _remove(int index) {
    final gone = _notes[index];
    setState(() => _notes = [..._notes]..removeAt(index));
    _toast(
      'Note deleted',
      description: '"$gone"',
      duration: const Duration(seconds: 6),
      action: ToastButton(
        label: 'Undo',
        onPressed: () => setState(
          () =>
              _notes = [..._notes]
                ..insert(math.min(index, _notes.length), gone),
        ),
      ),
      cancel: ToastButton(label: 'Dismiss', onPressed: () {}),
    );
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _portal,
    overlayLocation: OverlayChildLocation.rootOverlay,
    overlayChildBuilder: (context) => Toaster(
      controller: _toasts,
      closeButton: true,
      child: const SizedBox.expand(),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d8,
        children: [
          for (final (index, note) in _notes.indexed) ...[
            Row(
              spacing: Spacing.d8,
              children: [
                Expanded(child: Text(note)),
                Button(
                  size: ButtonSize.xs,
                  variant: ButtonVariant.ghost,
                  semanticLabel: 'Delete "$note"',
                  onPressed: () => _remove(index),
                  child: const Text('Delete'),
                ),
              ],
            ),
            const Separator(variant: SeparatorVariant.dashed),
          ],
          if (_notes.isEmpty)
            Text(
              'Nothing left. Press Undo on the slip.',
              style: LooseleafTheme.of(context).typography.interface(
                cssSize: 14,
                color: LooseleafTheme.of(context).colors.inkMuted,
              ),
            ),
        ],
      ),
    ),
  );
}
