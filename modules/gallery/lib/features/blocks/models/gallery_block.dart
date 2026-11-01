import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A ported block: its widget, its source file and what lies on its desk.
class GalleryBlock {
  const GalleryBlock({
    required this.source,
    required this.builder,
    this.objects = const [],
  });

  /// The block's file, relative to `lib/features/blocks/`
  /// (`blocks/cta_01/cta_01_block.dart`); its code is shown on the page.
  final String source;

  /// A constructor tear-off such as `Cta01Block.new`.
  final Widget Function({Key? key}) builder;

  /// The desk objects of upstream's preview (`src/docs/content/blocks/<slug>.tsx`).
  final List<DeskObject> objects;
}
