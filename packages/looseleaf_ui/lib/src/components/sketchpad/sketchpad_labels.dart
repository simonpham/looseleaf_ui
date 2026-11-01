import 'package:looseleaf_ink/looseleaf_ink.dart';

/// "1 stroke", "3 strokes".
String strokeCount(int count) => switch (count) {
  1 => '1 stroke',
  _ => '$count strokes',
};

/// The sketchpad's names for its tools, colors and widths, as upstream's
/// `TOOL_LABEL`, `COLOR_LABEL` and `SIZE_LABEL` in
/// `src/components/ui/sketchpad.tsx`.
extension SketchToolLabel on SketchTool {
  /// The button label and announcement: "Felt", "Eraser".
  String get label => switch (this) {
    SketchTool.felt => 'Felt',
    SketchTool.brush => 'Brush',
    SketchTool.pencil => 'Pencil',
    SketchTool.marker => 'Marker',
    SketchTool.highlighter => 'Highlighter',
    SketchTool.eraser => 'Eraser',
  };

  /// The letter key that picks the tool (upstream `KEY_TOOL`).
  String get key => switch (this) {
    SketchTool.felt => 'f',
    SketchTool.brush => 'b',
    SketchTool.pencil => 'p',
    SketchTool.marker => 'm',
    SketchTool.highlighter => 'h',
    SketchTool.eraser => 'e',
  };
}

/// Spoken names of the palette.
extension SketchColorLabel on SketchColor {
  /// The swatch's accessible name: "Ink", "Blue", "Terracotta".
  String get label => switch (this) {
    SketchColor.ink => 'Ink',
    SketchColor.inkYou => 'Blue',
    SketchColor.red => 'Red',
    SketchColor.green => 'Green',
    SketchColor.marker => 'Terracotta',
    SketchColor.tangerine => 'Orange',
    SketchColor.hi => 'Yellow',
    SketchColor.teal => 'Teal',
    SketchColor.grape => 'Purple',
    SketchColor.bubblegum => 'Pink',
  };
}

/// Spoken names and lookup of the stroke widths.
extension SketchSizeLabel on SketchSizeName {
  /// "Fine", "Medium", "Bold".
  String get label => switch (this) {
    SketchSizeName.fine => 'Fine',
    SketchSizeName.medium => 'Medium',
    SketchSizeName.bold => 'Bold',
  };

  /// The named width within 0.05 of [size], like upstream `sizeName`.
  static SketchSizeName? of(double size) {
    for (final name in SketchSizeName.values) {
      if ((name.size - size).abs() < 0.05) return name;
    }
    return null;
  }
}
