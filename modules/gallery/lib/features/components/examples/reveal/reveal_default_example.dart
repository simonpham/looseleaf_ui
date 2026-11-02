import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RevealDefaultExample extends StatefulWidget {
  const RevealDefaultExample({super.key});

  @override
  State<RevealDefaultExample> createState() => _RevealDefaultExampleState();
}

class _RevealDefaultExampleState extends State<RevealDefaultExample> {
  static const _maxWidth = 576.0;

  var _run = 0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [
          Reveal(
            key: ValueKey(_run),
            nib: true,
            child: Text(
              'Drawn by hand, on the way in.',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 48,
                cssLineHeight: 1,
              ),
            ),
          ),
          Text(
            'Nothing is hidden from screen readers while it waits.',
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
          Button(
            size: ButtonSize.sm,
            variant: ButtonVariant.outline,
            onPressed: () => setState(() => _run++),
            child: const Text('Replay'),
          ),
        ],
      ),
    );
  }
}
