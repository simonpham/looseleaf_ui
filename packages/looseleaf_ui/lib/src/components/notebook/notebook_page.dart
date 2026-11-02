import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/notebook/notebook_scope.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// One page of writing in a notebook: [children] down the lines. With a
/// [value], only the notebook's current page is shown; a page turned to
/// unfolds from the dog-ear in the bottom-right corner (not the page open
/// at load, and not with reduced motion). A page without a value is always
/// shown.
///
/// Mirrors `NotebookPage` in upstream `src/components/ui/notebook.tsx`.
class NotebookPage extends StatefulWidget {
  const NotebookPage({super.key, this.value, this.children = const []});

  /// `--ll-dur-soak`: how long a turned page takes to unfold.
  static const Duration unfold = Duration(milliseconds: 520);

  /// This page's name.
  final String? value;

  /// What is written on it.
  final List<Widget> children;

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wipe;
  late final CurvedAnimation _unfold;
  bool? _wasActive;

  bool _active(NotebookScope? scope) {
    final value = widget.value;
    final current = scope?.value;
    if (value == null || current == null) return true;
    return current == value;
  }

  @override
  void initState() {
    super.initState();
    _wipe = AnimationController(
      vsync: this,
      duration: NotebookPage.unfold,
      value: 1,
    );
    _unfold = CurvedAnimation(parent: _wipe, curve: InkMotion.easeOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(NotebookPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final active = _active(NotebookScope.maybeOf(context));
    final turnedTo = _wasActive == false && active;
    _wasActive = active;
    if (!turnedTo) return;
    _wipe.duration = InkMotion.of(context, NotebookPage.unfold);
    _wipe.forward(from: 0);
  }

  @override
  void dispose() {
    _unfold.dispose();
    _wipe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_active(NotebookScope.maybeOf(context))) {
      return const SizedBox.shrink();
    }
    return ClipPath(
      clipper: _UnfoldClipper(_unfold),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.children,
      ),
    );
  }
}

/// Upstream's clip-path wipe: a quad growing from the bottom-right corner
/// to the whole page.
class _UnfoldClipper extends CustomClipper<Path> {
  _UnfoldClipper(this.progress) : super(reclip: progress);

  final Animation<double> progress;

  @override
  Path getClip(Size size) {
    final t = progress.value;
    final corner = size.bottomRight(Offset.zero);
    Offset toward(Offset point) => Offset.lerp(corner, point, t) ?? point;
    return Path()..addPolygon([
      toward(Offset.zero),
      toward(size.topRight(Offset.zero)),
      corner,
      toward(size.bottomLeft(Offset.zero)),
    ], true);
  }

  @override
  bool shouldReclip(_UnfoldClipper oldClipper) =>
      oldClipper.progress != progress;
}
