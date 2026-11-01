import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Clips a [ButtonGroup] member's drawing at the seams it shares, so the
/// edge between two members is drawn once: the member before draws it, this
/// one's own edge there is cut away. A focused member is left whole.
///
/// The Flutter side of upstream's `[--cl-s:15px]` / `[--cl-e:15px]`
/// `clip-path` on `>svg.absolute` in `src/components/ui/button-group.tsx`.
class ButtonGroupSeam extends StatefulWidget {
  const ButtonGroupSeam({
    super.key,
    required this.axis,
    required this.clipStart,
    required this.clipEnd,
    required this.child,
  });

  /// The group's direction.
  final Axis axis;

  /// Whether the edge shared with the member before is cut.
  final bool clipStart;

  /// Whether the edge before a separator is cut.
  final bool clipEnd;

  final Widget child;

  @override
  State<ButtonGroupSeam> createState() => _ButtonGroupSeamState();
}

class _ButtonGroupSeamState extends State<ButtonGroupSeam> {
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final clip = !_focused && (widget.clipStart || widget.clipEnd);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: ClipRect(
        clipBehavior: switch (clip) {
          true => Clip.hardEdge,
          false => Clip.none,
        },
        clipper: _SeamClipper(
          axis: widget.axis,
          rtl: Directionality.of(context) == TextDirection.rtl,
          clipStart: widget.clipStart,
          clipEnd: widget.clipEnd,
        ),
        child: widget.child,
      ),
    );
  }
}

class _SeamClipper extends CustomClipper<Rect> {
  const _SeamClipper({
    required this.axis,
    required this.rtl,
    required this.clipStart,
    required this.clipEnd,
  });

  /// How far the drawing may reach past an open side: the frame's pad plus
  /// upstream's `-14px` inset.
  static const _open = Spacing.d26;

  /// Upstream's `15px` inset from the frame's 12 px pad: 3 px inside the
  /// member's own edge.
  static const _seam = -Spacing.d3;

  final Axis axis;
  final bool rtl;
  final bool clipStart;
  final bool clipEnd;

  double _reach(bool cut) => switch (cut) {
    true => _seam,
    false => _open,
  };

  @override
  Rect getClip(Size size) {
    final start = _reach(clipStart);
    final end = _reach(clipEnd);
    if (axis == Axis.vertical) {
      return Rect.fromLTRB(
        -_open,
        -start,
        size.width + _open,
        size.height + end,
      );
    }
    final (left, right) = switch (rtl) {
      true => (end, start),
      false => (start, end),
    };
    return Rect.fromLTRB(
      -left,
      -_open,
      size.width + right,
      size.height + _open,
    );
  }

  @override
  bool shouldReclip(_SeamClipper oldClipper) =>
      oldClipper.axis != axis ||
      oldClipper.rtl != rtl ||
      oldClipper.clipStart != clipStart ||
      oldClipper.clipEnd != clipEnd;
}
