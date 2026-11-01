import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/code_block/code_block.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One line of a [CodeBlockContent]: the coloured tokens, the number in the
/// margin, a green tick before an added line and a red pencil strike
/// through a removed one. Every 7th line from the 3rd and every 11th from
/// the 6th is typed a little lighter, like a worn ribbon.
///
/// Mirrors the `code-line` rows of upstream
/// `src/components/ui/code-block.tsx`.
class CodeBlockLineView extends StatelessWidget {
  const CodeBlockLineView({
    super.key,
    required this.line,
    required this.index,
    required this.diff,
  });

  final CodeBlockLine line;

  /// The line's place in the block, from 0.
  final int index;

  /// Whether the block is a diff, which indents every line for the ticks.
  final bool diff;

  static const double _numberWidth = Spacing.d32;
  static const double _tick = Spacing.d14;

  double _inset(bool numbered) => switch ((numbered, diff)) {
    (true, true) => Spacing.d56,
    (true, false) => Spacing.d44,
    (false, true) => Spacing.d28,
    (false, false) => 0,
  };

  double get _opacity {
    if (index % 11 == 5) return 0.9;
    if (index % 7 == 2) return 0.94;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final scope = CodeBlockScope.of(context);
    final colors = theme.colors;
    final kind = line.kind;
    final removed = kind == DiffKind.del;
    final added = kind == DiffKind.add;
    final base = switch (kind) {
      DiffKind.meta => colors.pencilText,
      DiffKind.del => colors.inkMuted,
      _ => colors.ink,
    };
    final Widget body = Text.rich(
      TextSpan(
        children: [
          for (final token in line.tokens)
            TextSpan(
              text: token.text,
              style: TextStyle(color: scope.tone.token(token.type, colors)),
            ),
        ],
      ),
      style: TextStyle(color: base),
      softWrap: scope.wrap,
    );
    final number = switch (scope.lineNumbers) {
      true => line.number,
      false => null,
    };
    final semantic = switch (kind) {
      DiffKind.add => 'Added: ${line.text}',
      DiffKind.del => 'Removed: ${line.text}',
      _ => line.text,
    };
    return Opacity(
      opacity: _opacity,
      child: Semantics(
        label: semantic,
        excludeSemantics: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: _inset(scope.lineNumbers),
              ),
              child: switch (removed) {
                true => _struck(body, '${scope.seed}|s$index', colors.red),
                false => body,
              },
            ),
            if (number case final value?)
              PositionedDirectional(
                start: switch (diff) {
                  true => Spacing.d20,
                  false => 0,
                },
                top: 0,
                width: _numberWidth,
                child: Text(
                  '$value',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: colors.pencilText),
                ),
              ),
            if (diff && added)
              PositionedDirectional(
                start: Spacing.d6,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CustomPaint(
                    size: const Size.square(_tick),
                    painter: CodeTickPainter(
                      seed: '${scope.seed}|t$index',
                      color: colors.green,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _struck(Widget body, String seed, Color color) => Stack(
    clipBehavior: Clip.none,
    children: [
      body,
      Positioned(
        left: -Spacing.d2,
        right: -Spacing.d2,
        top: 0,
        bottom: 0,
        child: CustomPaint(
          painter: CodeStrikePainter(seed: seed, color: color),
        ),
      ),
    ],
  );
}
