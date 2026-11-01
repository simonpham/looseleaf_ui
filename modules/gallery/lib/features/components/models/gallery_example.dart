import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/models/example_layout.dart';

/// Builds an example widget; a constructor tear-off such as `MyExample.new`.
typedef ExampleBuilder = Widget Function({Key? key});

/// One live example on a component page, upstream `ExampleMeta` plus its module.
class GalleryExample {
  const GalleryExample({
    required this.title,
    this.description,
    this.layout = ExampleLayout.center,
    this.stage = ExampleStage.paper,
    this.height,
    required this.source,
    required this.builder,
  });

  final String title;
  final String? description;
  final ExampleLayout layout;
  final ExampleStage stage;

  /// The stage's minimum height, upstream `meta.height`.
  final double? height;

  /// The example's file, relative to `lib/features/components/examples/`
  /// (`button/button_variants_example.dart`); its code tab shows this file.
  final String source;
  final ExampleBuilder builder;
}
