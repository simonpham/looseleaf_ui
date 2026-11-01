import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The text roles of upstream `src/components/ui/typography.tsx`, each with
/// its face, size, line height, weight, tracking and color.
enum TypographyStyle {
  /// `H1`: `font-script text-5xl leading-[1.02] font-bold tracking-tight`.
  h1(KevinSansFace.script, 48, 1.02, bold: true, tight: true),

  /// `H2`: `font-script text-4xl leading-[1.08] font-bold tracking-tight`.
  h2(KevinSansFace.script, 36, 1.08, bold: true, tight: true),

  /// `H3`: `font-script text-3xl leading-tight font-bold tracking-tight`.
  h3(KevinSansFace.script, 30, 1.25, bold: true, tight: true),

  /// `H4`: `font-hand text-xl leading-snug font-bold tracking-tight`.
  h4(KevinSansFace.hand, 20, 1.375, bold: true, tight: true),

  /// `P`: `text-[17px] leading-[1.7]`.
  p(KevinSansFace.hand, 17, 1.7),

  /// `Lead`: `text-xl leading-[1.55] text-muted-foreground`.
  lead(KevinSansFace.hand, 20, 1.55, dim: true),

  /// `Large`: `text-lg font-bold`.
  large(KevinSansFace.hand, 18, 28 / 18, bold: true),

  /// `Small`: `text-sm leading-none font-bold`.
  small(KevinSansFace.hand, 14, 1, bold: true),

  /// `Muted`: `text-sm text-muted-foreground`.
  muted(KevinSansFace.hand, 14, 20 / 14, dim: true),

  /// `Blockquote`: `font-script text-2xl leading-[1.35] text-ink-soft`.
  blockquote(KevinSansFace.script, 24, 1.35, soft: true),

  /// `List`: `text-[17px] leading-[1.6]`.
  list(KevinSansFace.hand, 17, 1.6);

  const TypographyStyle(
    this.face,
    this.cssSize,
    this.cssLineHeight, {
    this.bold = false,
    this.tight = false,
    this.dim = false,
    this.soft = false,
  });

  final KevinSansFace face;
  final double cssSize;
  final double cssLineHeight;
  final bool bold;

  /// `tracking-tight`: -0.025em.
  final bool tight;

  /// `text-muted-foreground`.
  final bool dim;

  /// `text-ink-soft`.
  final bool soft;

  /// The style in [theme]; headings are always `text-ink`, the rest inherit
  /// the ambient color unless muted or soft.
  TextStyle resolve(LooseleafThemeData theme) {
    final colors = theme.colors;
    final color = switch (this) {
      _ when dim => colors.inkMuted,
      _ when soft => colors.inkSoft,
      h1 || h2 || h3 || h4 => colors.ink,
      _ => null,
    };
    return theme.typography
        .face(
          face,
          cssSize: cssSize,
          cssLineHeight: cssLineHeight,
          fontWeight: switch (bold) {
            true => FontWeight.w700,
            false => FontWeight.w400,
          },
          color: color,
        )
        .copyWith(
          letterSpacing: switch (tight) {
            true => -0.025 * cssSize,
            false => null,
          },
        );
  }
}
