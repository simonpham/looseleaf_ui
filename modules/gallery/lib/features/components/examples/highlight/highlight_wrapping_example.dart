import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = 384.0;

class HighlightWrappingExample extends StatefulWidget {
  const HighlightWrappingExample({super.key});

  @override
  State<HighlightWrappingExample> createState() =>
      _HighlightWrappingExampleState();
}

class _HighlightWrappingExampleState extends State<HighlightWrappingExample> {
  bool _on = true;
  Timer? _timer;

  void _replay() {
    setState(() => _on = false);
    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 60),
      () => setState(() => _on = true),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [
          Text.rich(
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 17,
              cssLineHeight: 1.55,
            ),
            TextSpan(
              children: [
                const TextSpan(
                  text:
                      'If you only remember one thing from this page, '
                      'remember ',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Highlight(
                    animate: true,
                    show: _on,
                    tone: HighlightTone.pink,
                    child: const Text(
                      'that the margin is where the reading happens, and '
                      'the page is only where it starts',
                    ),
                  ),
                ),
                const TextSpan(text: '. Everything else is decoration.'),
              ],
            ),
          ),
          Button(
            variant: ButtonVariant.outline,
            size: ButtonSize.sm,
            onPressed: _replay,
            child: const Text('Replay'),
          ),
        ],
      ),
    );
  }
}
