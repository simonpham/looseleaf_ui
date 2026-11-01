import 'dart:ui';

import 'package:looseleaf_ui/src/components/code_block/highlight/highlight.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The slip a code block is typed on: a dark slate (the default) or the
/// paper's own stock.
///
/// Mirrors `tone` in upstream `src/components/ui/code-block.tsx`.
enum CodeBlockTone {
  /// `#24272e` slate with light ink and no paper tooth.
  dark,

  /// The stock's paper with the page's ink.
  paper;

  /// The dark slate (`--ll-stock` of `[data-tone="dark"]`).
  static const Color slate = Color(0xFF24272E);

  /// The tokens text on this tone reads: the dark tone swaps the inks and
  /// pencils of `[data-slot="code-block"][data-tone="dark"]` in
  /// `src/styles/looseleaf.css`.
  LooseleafColors colors(LooseleafColors base) => switch (this) {
    CodeBlockTone.paper => base,
    CodeBlockTone.dark => base.copyWith(
      ink: const Color(0xFFECE6D9),
      inkSoft: const Color(0xFFD9D2C3),
      inkMuted: const Color(0xFFC9C3B6),
      pencilText: const Color(0xFFA3A6AD),
      pencilMark: const Color(0xFF6A6E78),
    ),
  };

  /// The colour of each token type (`--ll-code-*`); null keeps the line's.
  Color? token(CodeTokenType type, LooseleafColors colors) => switch (this) {
    CodeBlockTone.dark => _dark[type],
    CodeBlockTone.paper => _paper(type, colors),
  };

  static const Map<CodeTokenType, Color> _dark = {
    CodeTokenType.comment: Color(0xFF8F949D),
    CodeTokenType.keyword: Color(0xFFF6957D),
    CodeTokenType.literal: Color(0xFFF7C370),
    CodeTokenType.number: Color(0xFFF7C370),
    CodeTokenType.string: Color(0xFFABD98F),
    CodeTokenType.function: Color(0xFF8FC1F7),
    CodeTokenType.type: Color(0xFF80D6C6),
    CodeTokenType.tag: Color(0xFFF6957D),
    CodeTokenType.attr: Color(0xFFF1D27A),
    CodeTokenType.variable: Color(0xFFECE6D9),
    CodeTokenType.punct: Color(0xFFC2BCAF),
  };

  /// `--ll-syn-*`: red and green keep 14% ink, orange 10%.
  static Color? _paper(CodeTokenType type, LooseleafColors colors) {
    final keyword = Color.lerp(colors.red, colors.ink, 0.14);
    final number = Color.lerp(colors.orangeText, colors.ink, 0.1);
    return switch (type) {
      CodeTokenType.plain => null,
      CodeTokenType.comment => colors.pencilText,
      CodeTokenType.keyword || CodeTokenType.tag => keyword,
      CodeTokenType.literal ||
      CodeTokenType.number ||
      CodeTokenType.attr => number,
      CodeTokenType.string => Color.lerp(colors.green, colors.ink, 0.14),
      CodeTokenType.function || CodeTokenType.type => colors.inkYou,
      CodeTokenType.variable => colors.ink,
      CodeTokenType.punct => colors.inkMuted,
    };
  }
}
