import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputSearchWithIconExample extends StatelessWidget {
  const InputSearchWithIconExample({super.key});

  static const _maxWidth = Spacing.d384;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Input(
      prefix: InkIcon('search'),
      placeholder: 'Search the notebook',
      semanticLabel: 'Search the notebook',
    ),
  );
}
