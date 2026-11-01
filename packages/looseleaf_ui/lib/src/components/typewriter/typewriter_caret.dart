import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show CaretParams, CaretShape, typewriterCaretRecipe;
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// The typewriter's inked caret, sized in ems of [fontSize], blinking
/// while [blinking] (`ll-caret`: on for the first half of each 1.1 s).
///
/// Mirrors `Caret` in upstream `src/components/ui/typewriter.tsx`.
class TypewriterCaret extends StatefulWidget {
  const TypewriterCaret({
    super.key,
    required this.shape,
    required this.seed,
    required this.fontSize,
    this.blinking = false,
  });

  final CaretShape shape;
  final String seed;
  final double fontSize;
  final bool blinking;

  /// `ll-caret`'s period.
  static const Duration blink = Duration(milliseconds: 1100);

  /// The caret's size in ems (`h-[1.15em] w-[0.16em]`, …).
  static Size emSize(CaretShape shape) => switch (shape) {
    CaretShape.block => const Size(0.6, 1.1),
    CaretShape.bar => const Size(0.16, 1.15),
    CaretShape.underscore => const Size(0.6, 1.15),
  };

  /// The room a reserved line keeps for the caret, in ems.
  static double reserveEms(CaretShape shape) => switch (shape) {
    CaretShape.bar => 0.22,
    _ => 0.6,
  };

  /// `ms-[0.06em]` before the bar.
  static double leadEms(CaretShape shape) => switch (shape) {
    CaretShape.bar => 0.06,
    _ => 0,
  };

  @override
  State<TypewriterCaret> createState() => _TypewriterCaretState();
}

class _TypewriterCaretState extends State<TypewriterCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: TypewriterCaret.blink,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(TypewriterCaret oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final blinking = widget.blinking && !InkMotion.reducedIn(context);
    if (!blinking) {
      _blink
        ..stop()
        ..value = 0;
      return;
    }
    if (!_blink.isAnimating) _blink.repeat();
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = CaretParams(shape: widget.shape);
    final em = TypewriterCaret.emSize(widget.shape);
    final caret = SizedBox(
      width: em.width * widget.fontSize,
      height: em.height * widget.fontSize,
      child: InkSurface(
        source: RecipeInkSource(
          typewriterCaretRecipe,
          params,
          json: params.toJson(),
        ),
        seed: widget.seed,
        still: true,
      ),
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: TypewriterCaret.leadEms(widget.shape) * widget.fontSize,
      ),
      child: AnimatedBuilder(
        animation: _blink,
        child: caret,
        builder: (context, child) => Opacity(
          opacity: switch (_blink.value < 0.5) {
            true => 1,
            false => 0,
          },
          child: child,
        ),
      ),
    );
  }
}
