import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/code_block/code_block.dart';

/// What a [CodeBlock] hands its parts: the model, the options and the seed.
///
/// Mirrors `CodeBlockContext` in upstream `src/components/ui/code-block.tsx`.
class CodeBlockScope extends InheritedWidget {
  const CodeBlockScope({
    super.key,
    required this.model,
    required this.filename,
    required this.lineNumbers,
    required this.wrap,
    required this.seed,
    required this.tone,
    required super.child,
  });

  final CodeBlockModel model;
  final String? filename;
  final bool lineNumbers;
  final bool wrap;
  final String seed;
  final CodeBlockTone tone;

  /// The nearest code block; throws outside one, like upstream `useCode`.
  static CodeBlockScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CodeBlockScope>();
    if (scope == null) {
      throw FlutterError('CodeBlock parts must be used inside a CodeBlock.');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(CodeBlockScope oldWidget) =>
      oldWidget.model != model ||
      oldWidget.filename != filename ||
      oldWidget.lineNumbers != lineNumbers ||
      oldWidget.wrap != wrap ||
      oldWidget.seed != seed ||
      oldWidget.tone != tone;
}
