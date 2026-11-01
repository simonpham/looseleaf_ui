import 'package:flutter/widgets.dart';
import 'package:gallery/features/foundations/models/models.dart';
import 'package:gallery/features/foundations/ui/widgets/art_samples.dart';
import 'package:gallery/features/foundations/ui/widgets/density_samples.dart';
import 'package:gallery/features/foundations/ui/widgets/font_samples.dart';
import 'package:gallery/features/foundations/ui/widgets/icon_samples.dart';
import 'package:gallery/features/foundations/ui/widgets/motion_samples.dart';
import 'package:gallery/features/foundations/ui/widgets/paper_stocks.dart';
import 'package:gallery/features/foundations/ui/widgets/pen_samples.dart';
import 'package:gallery/features/foundations/ui/widgets/swatch_grid.dart';

/// The live demo of a foundations [topic]; null when it has none.
class TopicDemo extends StatelessWidget {
  const TopicDemo({super.key, required this.topic});

  final FoundationTopic topic;

  /// Whether [topic] has a demo.
  static bool has(FoundationTopic topic) =>
      topic.swatches.isNotEmpty ||
      topic.fonts.isNotEmpty ||
      const {
        'pens',
        'paper',
        'icons',
        'stickers-doodles',
        'motion',
        'density',
      }.contains(topic.slug);

  @override
  Widget build(BuildContext context) => switch (topic) {
    FoundationTopic(:final swatches) when swatches.isNotEmpty => SwatchGrid(
      swatches: swatches,
    ),
    FoundationTopic(:final fonts) when fonts.isNotEmpty => FontSamples(
      fonts: fonts,
    ),
    FoundationTopic(slug: 'pens') => const PenSamples(),
    FoundationTopic(slug: 'paper') => const PaperStocks(),
    FoundationTopic(slug: 'icons') => const IconSamples(),
    FoundationTopic(slug: 'stickers-doodles') => const ArtSamples(),
    FoundationTopic(slug: 'motion') => const MotionSamples(),
    FoundationTopic(slug: 'density') => const DensitySamples(),
    _ => const SizedBox.shrink(),
  };
}
