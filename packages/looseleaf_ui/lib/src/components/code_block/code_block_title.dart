import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/code_block/code_block.dart';

/// The file name in a [CodeBlockHeader], or the language when there is
/// none; takes the header's free width and truncates.
///
/// Mirrors `CodeBlockTitle` in upstream `src/components/ui/code-block.tsx`.
class CodeBlockTitle extends StatelessWidget {
  const CodeBlockTitle({super.key, this.child});

  /// Replaces the file name.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scope = CodeBlockScope.of(context);
    return Expanded(
      child:
          child ??
          Text(
            scope.filename ?? scope.model.language.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
    );
  }
}
