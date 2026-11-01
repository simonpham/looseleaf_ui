import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/code_block/code_block.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A typed slip taped to the page: the file name in a typewriter face, the
/// code coloured by a small lexer (tsx, ts, jsx, js, css, json, bash), line
/// numbers in the margin, and a diff mode where removed lines are struck
/// through in red pencil and added ones ticked in green.
///
/// With [code] and no [child] it lays out a header (the title, the `+/-`
/// counts, the copy button) over [CodeBlockContent]; with a [child] you
/// compose the parts yourself.
///
/// ```dart
/// CodeBlock(
///   filename: 'src/notes/filter.ts',
///   lineNumbers: true,
///   code: 'export const shown = notes.filter(isPicked)',
/// )
/// CodeBlock(diff: true, filename: 'filter.ts', code: patch)
/// ```
///
/// Mirrors upstream `src/components/ui/code-block.tsx`.
class CodeBlock extends StatefulWidget {
  const CodeBlock({
    super.key,
    this.code = '',
    this.language,
    this.filename,
    this.lineNumbers = false,
    this.diff,
    this.wrap = false,
    this.startLine = 1,
    this.copyable = true,
    this.tone = CodeBlockTone.dark,
    this.stock = StockName.slip,
    this.tape = PaperTape.top,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.fastener,
    this.shadow = PaperShadow.stock,
    this.seed,
    this.child,
  });

  /// The source; for a diff, unified diff lines (`+added`, `-removed`,
  /// ` context`).
  final String code;

  /// `tsx`, `ts`, `jsx`, `js`, `css`, `json`, `bash`, `diff` or `text`, or
  /// an alias (`typescript`, `sh`, …); from [filename] when null, else
  /// plain text.
  final String? language;

  /// Typed at the top of the slip, and the block's accessible name.
  final String? filename;

  /// Numbers the lines in the margin.
  final bool lineNumbers;

  /// Reads [code] as a diff; on by default for the `diff` language.
  final bool? diff;

  /// Wraps long lines instead of scrolling sideways.
  final bool wrap;

  /// The number of the first line.
  final int startLine;

  /// Shows the default header's copy button.
  final bool copyable;

  /// A dark slate (the default) or the stock's paper.
  final CodeBlockTone tone;

  /// The paper the code is typed on.
  final StockName stock;

  /// Tape across the top by default.
  final PaperTape? tape;

  /// The sheet's edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the slip flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded when null.
  final double? tiltDegrees;

  /// A clip, pin, staple or binder clip.
  final FastenerKind? fastener;

  /// The slip's shadow.
  final PaperShadow shadow;

  /// Pins the slip, the rule, the strikes and the ticks.
  final String? seed;

  /// The parts, replacing the default header and content.
  final Widget? child;

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> with InkSeed {
  CodeBlockModel? _model;
  (String, CodeLang, bool, int)? _modelKey;

  CodeLang get _language => switch ((widget.language, widget.filename)) {
    (final String name, _) => CodeLang.parse(name),
    (null, final String file) => CodeLang.fromFileName(file),
    (null, null) => CodeLang.text,
  };

  CodeBlockModel _build(CodeLang language, bool diff) {
    final key = (widget.code, language, diff, widget.startLine);
    if (_model case final model? when _modelKey == key) return model;
    final model = CodeBlockModel.build(
      widget.code,
      language,
      diff: diff,
      startLine: widget.startLine,
    );
    _model = model;
    _modelKey = key;
    return model;
  }

  double _tiltAngle(BuildContext context, String seed) {
    if (!widget.tilt) return 0;
    final degrees =
        widget.tiltDegrees ??
        PaperBackground.restingTilt(
          seed,
          widget.stock,
          stockOf(widget.stock).rules,
        );
    return PaperInk.tilt(context, degrees);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final language = _language;
    final model = _build(language, widget.diff ?? language == CodeLang.diff);
    final tone = widget.tone;
    final name =
        widget.filename ??
        switch (language) {
          CodeLang.text => 'Code',
          _ => '${language.name} code',
        };
    return Semantics(
      container: true,
      label: name,
      child: CodeBlockScope(
        model: model,
        filename: widget.filename,
        lineNumbers: widget.lineNumbers,
        wrap: widget.wrap,
        seed: seed,
        tone: tone,
        child: Paper(
          stock: widget.stock,
          tape: widget.tape,
          edge: widget.edge,
          tilt: widget.tilt,
          tiltDegrees: widget.tiltDegrees,
          fastener: widget.fastener,
          shadow: widget.shadow,
          seed: seed,
          decor: switch (tone) {
            CodeBlockTone.dark => CodeBlockSlate(
              angle: _tiltAngle(context, seed),
            ),
            CodeBlockTone.paper => null,
          },
          child: LooseleafTheme(
            data: theme.copyWith(colors: tone.colors(theme.colors)),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: tone.colors(theme.colors).ink),
              child: widget.child ?? _parts(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _parts() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      CodeBlockHeader(
        children: [
          const CodeBlockTitle(),
          const CodeBlockStats(),
          if (widget.copyable)
            const CodeBlockActions(children: [CodeBlockCopy()]),
        ],
      ),
      const CodeBlockContent(),
    ],
  );
}
