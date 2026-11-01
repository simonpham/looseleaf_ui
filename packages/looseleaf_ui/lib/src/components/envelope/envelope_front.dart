import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/envelope/envelope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An envelope's front panel, in front of the letter: the paper, the seams
/// of the bottom flap, the stamp and its postmark, and the airmail border,
/// all from the [Envelope]. [children] sit at the foot, 13 % in from the
/// start, 8 % from the end and the bottom; an [EnvelopeSender] goes to the
/// top corner and an [EnvelopeTrigger] covers everything.
///
/// Mirrors `EnvelopeFront` in upstream `src/components/ui/envelope.tsx`.
class EnvelopeFront extends StatelessWidget {
  const EnvelopeFront({super.key, this.children = const []});

  /// An [EnvelopeAddress], an [EnvelopeSender] and an [EnvelopeTrigger].
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final envelope = EnvelopeScope.maybeOf(context);
    final params = EnvelopeFrontParams(
      stock: envelope?.stock ?? StockName.paper,
      stamp: envelope?.stamp,
      postmark: envelope?.postmark ?? false,
      airmail: envelope?.airmail ?? false,
    );
    final placed = [
      for (final child in children)
        if (child is EnvelopeSender) child,
      for (final child in children)
        if (child is EnvelopeTrigger) child,
    ];
    final flowing = [
      for (final child in children)
        if (child is! EnvelopeSender && child is! EnvelopeTrigger) child,
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return EnvelopeFrontScope(
          size: size,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: theme.colors.ink),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ExcludeSemantics(
                  child: Transform.rotate(
                    angle: envelope?.tilt ?? 0,
                    child: InkSurface(
                      source: RecipeInkSource(
                        envelopeFrontRecipe,
                        params,
                        json: params.toJson(),
                      ),
                      seed: '${envelope?.seed ?? 'envelope'}|front',
                      still: true,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: size.width * 0.13,
                    end: size.width * 0.08,
                    bottom: size.width * 0.08,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: flowing,
                  ),
                ),
                ...placed,
              ],
            ),
          ),
        );
      },
    );
  }
}
