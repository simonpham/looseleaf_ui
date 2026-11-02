import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A slip of code on a docs page: the file name, a copy button and the
/// highlighted lines, flat on the page.
///
/// Mirrors `CodeBlock` in upstream `src/docs/kit/CodeBlock.tsx`.
class DocCodeBlock extends StatelessWidget {
  const DocCodeBlock({super.key, required this.code, this.title = 'dart'});

  final String code;

  /// The file name in the header; its extension picks the grammar.
  final String title;

  String get _language => switch (title.split('.').last) {
    'dart' => 'dart',
    'yaml' || 'yml' => 'yaml',
    'json' => 'json',
    'sh' || 'Terminal' => 'bash',
    _ => 'text',
  };

  @override
  Widget build(BuildContext context) => CodeBlock(
    code: code.trimRight(),
    language: _language,
    filename: title,
    tilt: false,
    seed: 'code:$title',
  );
}
