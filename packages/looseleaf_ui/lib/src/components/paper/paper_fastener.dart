import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/art/art.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What holds a sheet: a paper clip, a push pin, a staple or a binder clip,
/// with a prop's drop shadow and a small seeded sideways jitter. Decorative.
///
/// [tone] colours a clip (steel when null) or a pin (tomato when null);
/// [size] is a clip's height, a pin's size, a staple's length or a binder
/// clip's width.
///
/// Mirrors `Fastener` in upstream `src/components/ui/paper.tsx`.
class PaperFastener extends StatefulWidget {
  const PaperFastener({
    super.key,
    this.kind = FastenerKind.clip,
    this.tone,
    this.size,
    this.seed,
  });

  /// The fastener.
  final FastenerKind kind;

  /// The plastic coat or pin head; steel or tomato when null.
  final Accent? tone;

  /// The prop's size in px; the kind's default when null.
  final double? size;

  /// Pins the drawing and the jitter.
  final String? seed;

  @override
  State<PaperFastener> createState() => _PaperFastenerState();
}

class _PaperFastenerState extends State<PaperFastener> with InkSeed {
  InkResult _draw(String seed, Tier tier, bool calm) {
    final s = '$seed|${widget.kind.id}';
    return switch (widget.kind) {
      FastenerKind.pin => pushPin(
        s,
        size: widget.size ?? 24,
        color: widget.tone ?? Accent.tomato,
        tier: tier,
        calm: calm,
      ),
      FastenerKind.staple => staple(
        s,
        length: widget.size ?? 20,
        tier: tier,
        calm: calm,
      ),
      FastenerKind.binderClip => binderClip(
        s,
        width: widget.size ?? 52,
        tier: tier,
        calm: calm,
      ),
      FastenerKind.clip => paperClip(
        s,
        height: widget.size ?? 62,
        tone: widget.tone,
        tier: tier,
        calm: calm,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final tier = PaperInk.tier(theme);
    final calm = PaperInk.calm(theme);
    final jitter = JsMath.round(tiltFor('$seed|at', 1) * 6);
    return Transform.translate(
      offset: Offset(jitter, 0),
      child: InkArt(
        cacheKey: [
          'fastener',
          seed,
          widget.kind.id,
          widget.tone?.name,
          widget.size,
          tier.name,
          calm,
        ].join('|'),
        draw: () => _draw(seed, tier, calm),
        drop: DropKind.prop,
      ),
    );
  }
}
