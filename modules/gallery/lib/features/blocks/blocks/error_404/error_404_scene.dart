import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A stained napkin pinned up with "404" on it, and Stubby shrugging beside
/// it (under it below 576 px).
///
/// Mirrors upstream `src/blocks/error-404/components/error-404-scene.tsx`.
class Error404Scene extends StatelessWidget {
  const Error404Scene({super.key, required this.wide});

  final bool wide;

  static const double _stubbySize = 184;
  static const double _overlap = Spacing.d40;

  @override
  Widget build(BuildContext context) {
    const napkin = Napkin(
      stain: true,
      fastener: FastenerKind.pin,
      fastenerTone: Accent.tomato,
      minHeight: 0,
      padding: EdgeInsets.all(Spacing.d28),
      seed: 'error-404-napkin',
      children: [
        NapkinContent(
          Lettering(
            '404',
            size: LetteringSize.hero,
            tone: LetteringTone.tomato,
            seed: 'error-404-digits',
            header: false,
          ),
          alignment: Alignment.center,
        ),
      ],
    );
    const stubby = Padding(
      padding: EdgeInsets.only(bottom: Spacing.d4),
      child: Mascot(pose: 'shrug', size: _stubbySize),
    );
    if (!wide) {
      return const ExcludeSemantics(
        child: Column(spacing: Spacing.d24, children: [napkin, stubby]),
      );
    }
    final shift = switch (Directionality.of(context)) {
      TextDirection.ltr => _overlap / 2,
      TextDirection.rtl => -_overlap / 2,
    };
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: Spacing.d8,
        children: [
          Transform.translate(offset: Offset(shift, 0), child: napkin),
          Transform.translate(offset: Offset(-shift, 0), child: stubby),
        ],
      ),
    );
  }
}
