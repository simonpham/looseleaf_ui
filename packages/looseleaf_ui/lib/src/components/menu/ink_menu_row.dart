import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The look of a menu row, shared by every kind of row: hand lettering
/// 32 px tall (28 compact and calm), the highlighter swipe while
/// [highlighted], a blue felt bar at the start edge while [focusVisible],
/// pencil-gray when [disabled]. A [destructive] row is red and hatches in
/// red pencil when highlighted. [inset] (or an [indicator]) starts the text
/// 36 px in, in line with ticked rows.
///
/// Icons in [leading] are 16 px, soft ink; [trailing] goes at the end
/// (a shortcut, a chevron).
///
/// Mirrors `MENU_ITEM`, `MENU_CHOICE_ITEM` and `MENU_SUB_TRIGGER` in
/// upstream `src/lib/menu-styles.ts`.
class InkMenuRow extends StatelessWidget {
  const InkMenuRow({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.indicator,
    this.highlighted = false,
    this.focusVisible = false,
    this.disabled = false,
    this.destructive = false,
    this.inset = false,
  });

  /// The row's text.
  final Widget child;

  /// An icon before the text.
  final Widget? leading;

  /// What sits at the end.
  final Widget? trailing;

  /// A tick box or radio ring in the start gutter.
  final Widget? indicator;

  /// Wears the highlighter (`data-highlighted`).
  final bool highlighted;

  /// Shows the keyboard focus bar.
  final bool focusVisible;

  /// Pencil-gray.
  final bool disabled;

  /// Red, with a red hatch when highlighted.
  final bool destructive;

  /// Starts the text in line with ticked rows.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final color = switch ((disabled, destructive, highlighted)) {
      (true, _, _) => colors.pencilText,
      (false, true, false) => colors.red,
      (false, _, true) => colors.selectionText,
      (false, false, false) => colors.ink,
    };
    final iconColor = switch (destructive) {
      true => colors.red,
      false => colors.inkSoft,
    };
    final start = switch (inset || indicator != null) {
      true => InkMenuMetrics.inset,
      false => InkMenuMetrics.rowInline,
    };
    final vertical = InkMenuMetrics.rowPadding.of(context);
    final mark = indicator;
    final row = CustomPaint(
      painter: _RowBackdrop(
        fill: switch ((highlighted, destructive)) {
          (false, _) => null,
          (true, false) => colors.hiSelect,
          (true, true) => colors.red.withValues(alpha: 0.12),
        },
        hatch: switch (highlighted && destructive) {
          true => colors.red.withValues(alpha: 0.55),
          false => null,
        },
        bar: switch (focusVisible) {
          true => colors.inkYou,
          false => null,
        },
        direction: Directionality.of(context),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: InkMenuMetrics.rowHeight.of(context),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: start,
            end: InkMenuMetrics.rowInline,
            top: vertical,
            bottom: vertical,
          ),
          child: InkContent(
            style: InkMenuMetrics.row(theme, color: color),
            iconSize: Spacing.d16,
            child: IconTheme.merge(
              data: IconThemeData(color: iconColor),
              child: Row(
                spacing: InkMenuMetrics.rowGap,
                children: [
                  ?leading,
                  Expanded(child: child),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (mark == null) return row;
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        row,
        PositionedDirectional(
          start: InkMenuMetrics.rowInline,
          width: InkMenuMetrics.indicator,
          height: InkMenuMetrics.indicator,
          child: mark,
        ),
      ],
    );
  }
}

/// `ll-swipe` (or the destructive hatch) and the focus bar, clipped to the
/// swipe's uneven corners.
class _RowBackdrop extends CustomPainter {
  _RowBackdrop({
    required this.fill,
    required this.hatch,
    required this.bar,
    required this.direction,
  });

  final Color? fill;
  final Color? hatch;
  final Color? bar;
  final TextDirection direction;

  /// The hatch's `118deg` stripes, 1 px every 5 px.
  static const double _angle = 118;
  static const double _period = 5;

  @override
  void paint(Canvas canvas, Size size) {
    if (fill == null && bar == null) return;
    final rect = Offset.zero & size;
    canvas
      ..save()
      ..clipRRect(InkMenuMetrics.swipe.toRRect(rect));
    if (fill case final color?) canvas.drawRect(rect, Paint()..color = color);
    if (hatch case final color?) _hatch(canvas, size, color);
    if (bar case final color?) {
      final left = switch (direction) {
        TextDirection.ltr => 0.0,
        TextDirection.rtl => size.width - InkMenuMetrics.focusBar,
      };
      canvas.drawRect(
        Rect.fromLTWH(left, 0, InkMenuMetrics.focusBar, size.height),
        Paint()..color = color,
      );
    }
    canvas.restore();
  }

  void _hatch(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final center = size.center(Offset.zero);
    final reach = size.longestSide;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate((_angle - 90) * 3.141592653589793 / 180);
    for (var x = -reach; x <= reach; x += _period) {
      canvas.drawLine(Offset(x, -reach), Offset(x, reach), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RowBackdrop oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.hatch != hatch ||
      oldDelegate.bar != bar ||
      oldDelegate.direction != direction;
}
