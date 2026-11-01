import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = 384.0;

class UnderlineWrappingExample extends StatefulWidget {
  const UnderlineWrappingExample({super.key});

  @override
  State<UnderlineWrappingExample> createState() =>
      _UnderlineWrappingExampleState();
}

class _UnderlineWrappingExampleState extends State<UnderlineWrappingExample> {
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
                      'A book is a conversation with someone who cannot '
                      'answer back, so ',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Underline(
                    animate: true,
                    show: _on,
                    kind: UnderlineMarkKind.wavy,
                    tone: MarkPen.blue,
                    child: const Text(
                      'talk back in the margin, argue with the author, and '
                      'write down where you stopped believing them',
                    ),
                  ),
                ),
                const TextSpan(text: ', then close it.'),
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
