import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The teams on the logo wall, each set in its own lettering.
///
/// Mirrors `LOGOS` in upstream `src/blocks/logos-01/components/logos-01-names.tsx`.
enum Logos01Logo {
  oatmeal('Oatmeal & Co.'),
  kiln('Kiln'),
  paperworkBros('paperwork bros'),
  northwind('Northwind Ink'),
  teaRoom('The Tea Room'),
  brindle('Brindle'),
  loomAndLantern('Loom & Lantern'),
  saltStudio('salt studio');

  const Logos01Logo(this.label);

  /// The team's name as it is written.
  final String label;

  /// The lettering this team's name is set in.
  TextStyle style(LooseleafThemeData theme) {
    final typography = theme.typography;
    return switch (this) {
      oatmeal => typography.face(
        KevinSansFace.script,
        cssSize: 30,
        cssLineHeight: 36 / 30,
        fontWeight: FontWeight.w700,
      ),
      kiln =>
        typography
            .face(KevinSansFace.type, cssSize: 20, cssLineHeight: 28 / 20)
            .copyWith(letterSpacing: 20 * KevinSansFace.type.sizeAdjust * 0.35),
      paperworkBros => typography.face(
        KevinSansFace.hand,
        cssSize: 20,
        cssLineHeight: 28 / 20,
        fontWeight: FontWeight.w700,
      ),
      northwind =>
        typography
            .face(
              KevinSansFace.script,
              cssSize: 30,
              cssLineHeight: 36 / 30,
              fontWeight: FontWeight.w700,
            )
            .copyWith(fontStyle: FontStyle.italic),
      teaRoom =>
        typography
            .face(KevinSansFace.type, cssSize: 18, cssLineHeight: 28 / 18)
            .copyWith(
              letterSpacing: 18 * KevinSansFace.type.sizeAdjust * 0.025,
            ),
      brindle => typography.face(
        KevinSansFace.script,
        cssSize: 30,
        cssLineHeight: 36 / 30,
      ),
      loomAndLantern =>
        typography
            .mono(
              cssSize: 14,
              cssLineHeight: 20 / 14,
              fontWeight: FontWeight.w600,
            )
            .copyWith(letterSpacing: 14 * 0.25),
      saltStudio => typography.face(
        KevinSansFace.hand,
        cssSize: 20,
        cssLineHeight: 28 / 20,
      ),
    };
  }
}
