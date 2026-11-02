import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TypewriterReceiptExample extends StatefulWidget {
  const TypewriterReceiptExample({super.key});

  @override
  State<TypewriterReceiptExample> createState() =>
      _TypewriterReceiptExampleState();
}

class _TypewriterReceiptExampleState extends State<TypewriterReceiptExample> {
  static const _width = 288.0;

  int _run = 0;
  bool _done = false;

  void _printAnother() => setState(() {
    _done = false;
    _run += 1;
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d16,
      children: [
        SizedBox(
          width: _width,
          child: Paper(
            stock: StockName.receipt,
            tilt: false,
            padding: const EdgeInsets.all(Spacing.d24),
            child: Typewriter.phrases(
              const [
                'ORDER 0042',
                'one croissant',
                'one coffee, black',
                'one apology',
                '',
                'TOTAL  a smile',
              ],
              key: ValueKey(_run),
              speed: 26,
              pause: const Duration(milliseconds: 500),
              reserve: true,
              cursor: CaretShape.underscore,
              style: theme.typography.face(
                KevinSansFace.type,
                cssSize: 16,
                cssLineHeight: 1.75,
              ),
              onDone: () => setState(() => _done = true),
            ),
          ),
        ),
        SizedBox(
          height: Spacing.d36,
          child: switch (_done) {
            true => Button(
              size: ButtonSize.sm,
              variant: ButtonVariant.outline,
              onPressed: _printAnother,
              child: const Text('Print another'),
            ),
            false => null,
          },
        ),
      ],
    );
  }
}
