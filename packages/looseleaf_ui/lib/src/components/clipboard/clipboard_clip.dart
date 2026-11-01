import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A clipboard's chrome spring clip, [width] px wide: a wire arch, a graded
/// plate and two rivets, casting a prop's shadow. Decorative.
///
/// Mirrors the `clipboard-clip` prop in upstream
/// `src/components/ui/clipboard.tsx`.
class ClipboardClip extends StatelessWidget {
  const ClipboardClip({super.key, required this.seed, this.width = 104});

  /// Pins the clip's hand.
  final String seed;

  /// The clip's width.
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final tier = PaperInk.tier(theme);
    final calm = PaperInk.calm(theme);
    return IgnorePointer(
      child: InkArt(
        cacheKey: ['clipboard-clip', seed, width, tier.name, calm].join('|'),
        draw: () => clipboardClip(seed, width: width, tier: tier, calm: calm),
        drop: DropKind.prop,
      ),
    );
  }
}
