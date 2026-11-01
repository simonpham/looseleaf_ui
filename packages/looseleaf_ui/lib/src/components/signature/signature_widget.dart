import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show
        MarkPen,
        MarkWeight,
        SignatureFlourish,
        SignatureParams,
        signatureRecipe;
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/signature/signature.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A name signed by hand: the words in the script face, in blue ink by
/// default, with a pen tail under them, a swoosh or an underline.
///
/// With [animate] the name is written on first, then the flourish follows.
///
/// ```dart
/// const Signature(child: Text('Ada Lovelace'))
/// ```
///
/// Mirrors upstream `src/components/ui/signature.tsx`.
class Signature extends StatefulWidget {
  const Signature({
    super.key,
    required this.child,
    this.flourish = SignatureFlourish.swoosh,
    this.size = SignatureSize.md,
    this.tone = MarkPen.blue,
    this.weight = MarkWeight.regular,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  /// The name, usually a [Text].
  final Widget child;

  final SignatureFlourish flourish;
  final SignatureSize size;

  /// The pen; `ink` also writes the name in ink, every other pen in blue.
  final MarkPen tone;
  final MarkWeight weight;

  /// Write the name on, then draw the flourish. Reduced motion just shows
  /// them.
  final bool animate;

  /// Show or hide the flourish.
  final bool show;

  /// The wait before the name is written on.
  final Duration delay;

  /// Pins the hand.
  final String? seed;

  /// How long the name takes to write on (`--ll-dur-draw` × 1.6).
  static const Duration nameDuration = Duration(milliseconds: 960);

  /// When the flourish starts after the name.
  static const Duration flourishLag = Duration(milliseconds: 700);

  @override
  State<Signature> createState() => _SignatureState();
}

class _SignatureState extends State<Signature> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final params = SignatureParams(
      flourish: widget.flourish,
      tone: widget.tone,
      weight: widget.weight,
      fs: widget.size.fontSize,
      animate: widget.animate,
    );
    final name = Padding(
      padding: const EdgeInsets.only(bottom: Spacing.d12),
      child: InkMarkWipe(
        animate: widget.animate,
        delay: widget.delay,
        duration: Signature.nameDuration,
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.script,
            cssSize: widget.size.fontSize,
            cssLineHeight: 1,
            color: switch (widget.tone) {
              MarkPen.ink => theme.colors.ink,
              _ => theme.colors.inkYou,
            },
          ),
          softWrap: false,
          child: widget.child,
        ),
      ),
    );
    if (!widget.show) return name;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: InkMarkSurface(
                source: RecipeInkSource(
                  signatureRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: inkSeed(widget.seed),
                animate: widget.animate,
                delay: widget.delay + Signature.flourishLag,
              ),
            ),
          ),
        ),
        name,
      ],
    );
  }
}
