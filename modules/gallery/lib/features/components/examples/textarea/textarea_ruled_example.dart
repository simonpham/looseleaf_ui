import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TextareaRuledExample extends StatefulWidget {
  const TextareaRuledExample({super.key});

  @override
  State<TextareaRuledExample> createState() => _TextareaRuledExampleState();
}

class _TextareaRuledExampleState extends State<TextareaRuledExample> {
  final _diary = TextEditingController(
    text: 'Dear diary,\ntoday I drew a box\nand it was mine.',
  );

  @override
  void dispose() {
    _diary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d112 * 4),
    child: Textarea(controller: _diary, ruled: true, semanticLabel: 'Diary'),
  );
}
