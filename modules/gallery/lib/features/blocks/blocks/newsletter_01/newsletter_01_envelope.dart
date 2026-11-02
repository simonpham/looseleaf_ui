import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A kraft envelope addressed to "You", with the Sunday letter inside. Once
/// [stamped], a green "Subscribed" stamp lands on it.
///
/// Mirrors upstream
/// `src/blocks/newsletter-01/components/newsletter-01-envelope.tsx`.
class Newsletter01Envelope extends StatelessWidget {
  const Newsletter01Envelope({
    super.key,
    required this.open,
    required this.onOpenChange,
    required this.stamped,
  });

  /// Whether the letter is out.
  final bool open;

  /// Called when the envelope is opened or shut.
  final ValueChanged<bool> onOpenChange;

  /// Whether the "Subscribed" stamp is on.
  final bool stamped;

  static const double _maxWidth = 384;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: AspectRatio(
          aspectRatio: 40 / 39,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Envelope(
                  open: open,
                  onOpenChange: onOpenChange,
                  seed: 'newsletter-envelope',
                  tiltDegrees: 1,
                  children: [
                    const EnvelopeFront(
                      children: [
                        EnvelopeSender(child: Text('Penmark\nLisbon')),
                        EnvelopeAddress(
                          cssFontSize: 18.4,
                          children: [
                            Text('You'),
                            Text('Your inbox'),
                            Text('Sunday morning'),
                          ],
                        ),
                        EnvelopeTrigger(label: 'Peek inside the Sunday letter'),
                      ],
                    ),
                    EnvelopeLetter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d4,
                        children: [
                          Text(
                            'Sunday letter, no. 41',
                            style: theme.typography.face(
                              KevinSansFace.script,
                              cssSize: 24,
                              cssLineHeight: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'On buying too many pens, and one very good link.',
                            style: theme.typography.face(
                              KevinSansFace.hand,
                              cssSize: 14,
                              cssLineHeight: 20 / 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (stamped)
                PositionedDirectional(
                  end: Spacing.d12,
                  bottom: Spacing.d20,
                  child: IgnorePointer(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: InkMotion.of(context, InkMotion.pop),
                      builder: (context, t, child) => Opacity(
                        opacity: t,
                        child: Transform.scale(
                          scale: 1.7 - 0.7 * t,
                          child: child,
                        ),
                      ),
                      child: const Stamp(
                        text: 'Subscribed',
                        ink: StampPadInk.green,
                        w: 150,
                        h: 50,
                        tilt: -8,
                        ghost: true,
                        seed: 'newsletter-stamp',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
