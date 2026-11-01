import 'package:flutter/widgets.dart';

/// A ported block: its widget and its source file.
class GalleryBlock {
  const GalleryBlock({required this.source, required this.builder});

  /// The block's file, relative to `lib/features/blocks/`
  /// (`blocks/login_01/login_01_block.dart`).
  final String source;

  /// A constructor tear-off such as `Login01Block.new`.
  final Widget Function({Key? key}) builder;
}
