import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A chart's text: axis ticks, categories, values, notes and center text
/// placed by its layout, in the script hand (the hand in calm density).
///
/// Mirrors `ChartLabels` in upstream `src/components/ui/chart.tsx`.
class ChartLabels extends StatelessWidget {
  const ChartLabels({super.key, required this.labels});

  /// The labels, in the layout's pixels.
  final List<ChartLabel> labels;

  /// `--ll-ink-room`: the 0.2 em a clipped label may run past its room
  /// so the last stroke is not cut.
  static const double _inkRoom = 0.2;

  /// The widest of [texts] set as labels in [theme]'s face, in ems: what
  /// [XYSpec.catEm] wants, since the engine's estimate runs narrow for
  /// Kevin Sans and would cut a sideways chart's categories.
  static double widestEm(LooseleafThemeData theme, Iterable<String> texts) {
    const size = 100.0;
    final style = theme.typography.face(_face(theme), cssSize: size);
    var widest = 0.0;
    for (final text in texts) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      widest = math.max(widest, painter.width);
      painter.dispose();
    }
    return widest / size;
  }

  static KevinSansFace _face(LooseleafThemeData theme) =>
      switch (theme.density == LooseleafDensity.calm) {
        true => KevinSansFace.hand,
        false => KevinSansFace.script,
      };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final label in labels)
              Positioned(
                key: ValueKey(label.id),
                left: label.x,
                top: label.y,
                child: FractionalTranslation(
                  translation: Offset(
                    switch (label.anchor) {
                      LabelAnchor.start => 0,
                      LabelAnchor.middle => -0.5,
                      LabelAnchor.end => -1,
                    },
                    switch (label.valign) {
                      LabelValign.top => 0,
                      LabelValign.middle => -0.5,
                      LabelValign.bottom => -1,
                    },
                  ),
                  child: _text(theme, label),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _text(LooseleafThemeData theme, ChartLabel label) {
    final colors = theme.colors;
    final size = label.size ?? 12;
    final halo = switch (label.role) {
      LabelRole.note => [
        Shadow(color: colors.slip, blurRadius: Spacing.d2),
        Shadow(color: colors.slip, blurRadius: Spacing.d6),
      ],
      LabelRole.value => [
        Shadow(color: colors.slip, blurRadius: Spacing.d2),
        Shadow(color: colors.slip, blurRadius: Spacing.d4),
      ],
      _ => const <Shadow>[],
    };
    final style = theme.typography
        .face(
          _face(theme),
          cssSize: size,
          cssLineHeight: 1,
          fontWeight: switch (label.role) {
            LabelRole.note || LabelRole.center => FontWeight.w700,
            _ => FontWeight.w400,
          },
          color: switch (label.tone ?? LabelTone.ink) {
            LabelTone.ink => colors.ink,
            LabelTone.muted => colors.inkMuted,
            LabelTone.red => colors.red,
            LabelTone.blue => colors.inkYou,
            LabelTone.green => colors.green,
          },
        )
        .copyWith(shadows: halo);
    final text = Text(
      label.text,
      style: style,
      maxLines: 1,
      softWrap: false,
      overflow: switch (label.maxW) {
        null => TextOverflow.visible,
        _ => TextOverflow.ellipsis,
      },
    );
    if (label.maxW case final maxWidth?) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth + _inkRoom * size),
        child: text,
      );
    }
    return text;
  }
}
