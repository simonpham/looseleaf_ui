import 'package:flutter/widgets.dart';

/// The Kevin Sans faces of `public/fonts/kevin-sans.css`.
///
/// Upstream registers one font three times with different `size-adjust`
/// values; Flutter has no size-adjust, so each face scales the font size.
enum KevinSansFace {
  /// `Kevin Sans Hand` (`--font-hand`): the interface text, at 88%.
  hand(0.88),

  /// `Kevin Sans Script` (`--font-script`): titles and handwritten voices, at 75%.
  script(0.75),

  /// `Kevin Sans Type` (`--font-type`): stamps, captions and small labels, at 82%.
  type(0.82);

  const KevinSansFace(this.sizeAdjust);

  /// The upstream `size-adjust`, applied to the CSS font size.
  final double sizeAdjust;

  /// The face named by a CSS `font-family` list such as
  /// `var(--font-script, cursive)`; [hand] when none is named.
  static KevinSansFace fromCss(String family) {
    if (family.contains('script') || family.contains('Script')) return script;
    if (family.contains('type') || family.contains('Type')) return type;
    return hand;
  }
}

/// Text styles for Looseleaf's Kevin Sans roles.
class LooseleafTypography {
  const LooseleafTypography({
    this.fontFamily = 'KevinSans',
    this.package = 'looseleaf_ui',
    this.bodySize = 17,
    this.lineHeight = 1.55,
  });

  /// The bundled family name.
  final String fontFamily;

  /// The package that bundles [fontFamily]; null when the app bundles it.
  final String? package;

  /// The CSS body font size, `1.0625rem`.
  final double bodySize;

  /// The body line height multiplier.
  final double lineHeight;

  /// Kevin Sans in [face] at the CSS size [cssSize] (before size-adjust),
  /// with the CSS unitless [cssLineHeight] (defaults to the body's).
  TextStyle face(
    KevinSansFace face, {
    double? cssSize,
    double? cssLineHeight,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) => TextStyle(
    fontFamily: fontFamily,
    package: package,
    fontSize: (cssSize ?? bodySize) * face.sizeAdjust,
    fontWeight: fontWeight,
    height: (cssLineHeight ?? lineHeight) / face.sizeAdjust,
    leadingDistribution: TextLeadingDistribution.even,
    color: color,
  );

  /// Interface text: labels, buttons, body copy (`--font-hand`).
  TextStyle interface({double? cssSize, Color? color}) =>
      face(KevinSansFace.hand, cssSize: cssSize, color: color);

  /// Form labels, upstream `<Label>`: `font-hand text-[15px] leading-none
  /// font-bold`.
  TextStyle label({Color? color}) => face(
    KevinSansFace.hand,
    cssSize: 15,
    cssLineHeight: 1,
    fontWeight: FontWeight.w700,
    color: color,
  );

  /// Titles and headings (`--font-script`, semibold upstream).
  TextStyle title({double? cssSize, Color? color}) => face(
    KevinSansFace.script,
    cssSize: cssSize ?? 27,
    fontWeight: FontWeight.w700,
    color: color,
  );

  /// Stamps, captions and small labels (`--font-type`).
  TextStyle stamp({double? cssSize, Color? color}) =>
      face(KevinSansFace.type, cssSize: cssSize ?? 12.5, color: color);

  @override
  bool operator ==(Object other) =>
      other is LooseleafTypography &&
      other.fontFamily == fontFamily &&
      other.package == package &&
      other.bodySize == bodySize &&
      other.lineHeight == lineHeight;

  @override
  int get hashCode => Object.hash(fontFamily, package, bodySize, lineHeight);
}
