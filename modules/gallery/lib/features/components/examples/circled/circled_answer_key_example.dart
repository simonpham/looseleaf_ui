import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CircledAnswerKeyExample extends StatefulWidget {
  const CircledAnswerKeyExample({super.key});

  @override
  State<CircledAnswerKeyExample> createState() =>
      _CircledAnswerKeyExampleState();
}

class _CircledAnswerKeyExampleState extends State<CircledAnswerKeyExample> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d16,
        children: [
          Text(
            'Which of these is a fine-liner?',
            style: theme.typography.face(KevinSansFace.script, cssSize: 24),
          ),
          DefaultTextStyle.merge(
            style: theme.typography.interface(cssSize: 17),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.d4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d10,
                children: [
                  const Text('a) A chisel-tip marker'),
                  Circled(
                    animate: true,
                    show: _show,
                    tone: MarkPen.red,
                    child: const Text('b) A 0.4 mm felt pen'),
                  ),
                  const Text('c) A stick of graphite'),
                ],
              ),
            ),
          ),
          Semantics(
            toggled: _show,
            child: Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.sm,
              onPressed: () => setState(() => _show = !_show),
              child: Text(switch (_show) {
                true => 'Hide the answer (b)',
                false => 'Show the answer',
              }),
            ),
          ),
        ],
      ),
    );
  }
}
