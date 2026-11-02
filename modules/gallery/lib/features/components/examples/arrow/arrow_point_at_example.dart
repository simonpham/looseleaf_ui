import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ArrowPointAtExample extends StatefulWidget {
  const ArrowPointAtExample({super.key});

  @override
  State<ArrowPointAtExample> createState() => _ArrowPointAtExampleState();
}

class _ArrowPointAtExampleState extends State<ArrowPointAtExample> {
  static const _maxWidth = 576.0;
  static const _minHeight = 208.0;

  final _target = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: _maxWidth,
        minHeight: _minHeight,
      ),
      child: Row(
        spacing: Spacing.d32,
        children: [
          Expanded(
            child: Row(
              spacing: Spacing.d8,
              children: [
                Flexible(
                  child: Text(
                    'the important one',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 24,
                      color: theme.colors.inkYou,
                    ),
                  ),
                ),
                Arrow(
                  pointAt: _target,
                  curve: ArrowCurve.curved,
                  tone: MarkPen.blue,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: Spacing.d96),
            child: Button(
              key: _target,
              onPressed: () {},
              child: const Text('Publish'),
            ),
          ),
        ],
      ),
    );
  }
}
