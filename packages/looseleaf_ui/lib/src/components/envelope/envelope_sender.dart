import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/envelope/envelope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The return address on an [EnvelopeFront]: small soft-ink text at the
/// start corner of the top, 5 % in and 7 % down, at most 40 % of the width.
/// Use it as a direct child of an [EnvelopeFront].
///
/// Mirrors `EnvelopeSender` in upstream `src/components/ui/envelope.tsx`.
class EnvelopeSender extends StatelessWidget {
  const EnvelopeSender({super.key, required this.child});

  /// The return address, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final size = EnvelopeFrontScope.maybeOf(context)?.size ?? Size.zero;
    return PositionedDirectional(
      start: size.width * 0.05,
      top: size.height * 0.07,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: size.width * 0.4),
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 12,
            cssLineHeight: 1.25,
            color: theme.colors.inkSoft,
          ),
          child: child,
        ),
      ),
    );
  }
}
