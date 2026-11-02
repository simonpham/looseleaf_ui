import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row of controls that scrolls sideways once it is wider than its
/// parent, instead of overflowing: what a browser does with an
/// `overflow-x-auto` strip of tabs or toggles. While it fits it lays out
/// and paints exactly like [child]; while it scrolls it clips only along
/// the row, so drawn edges still bleed [bleed] above and below, and keeps
/// the focused item in view as the arrow keys walk it.
class InkOverflowScroll extends StatefulWidget {
  const InkOverflowScroll({
    super.key,
    required this.child,
    this.bleed = Spacing.d12,
  });

  final Widget child;

  /// How far ink may reach above and below the row while it scrolls.
  final double bleed;

  @override
  State<InkOverflowScroll> createState() => _InkOverflowScrollState();
}

class _InkOverflowScrollState extends State<InkOverflowScroll> {
  final ScrollController _controller = ScrollController();
  bool _overflowing = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocus);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocus);
    _controller.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!_overflowing || !_controller.hasClients) return;
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused == null || !focused.mounted) return;
    final position = _controller.position;
    if (Scrollable.maybeOf(focused)?.position != position) return;
    final target = focused.findRenderObject();
    if (target == null) return;
    position.ensureVisible(
      target,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
    position.ensureVisible(
      target,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    );
  }

  bool _onMetrics(ScrollMetricsNotification notification) {
    final overflowing = notification.metrics.maxScrollExtent > 0;
    if (overflowing != _overflowing) {
      setState(() => _overflowing = overflowing);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final scroll = NotificationListener<ScrollMetricsNotification>(
      onNotification: _onMetrics,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: widget.child,
        ),
      ),
    );
    if (!_overflowing) return scroll;
    return ClipRect(clipper: _RowClipper(widget.bleed), child: scroll);
  }
}

class _RowClipper extends CustomClipper<Rect> {
  const _RowClipper(this.bleed);

  final double bleed;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, -bleed, size.width, size.height + bleed);

  @override
  bool shouldReclip(_RowClipper oldClipper) => oldClipper.bleed != bleed;
}
