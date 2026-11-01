import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/stamp_button/stamp_impression.dart';
import 'package:looseleaf_ui/src/components/stamp_button/stamp_impression_mark.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// The page [StampButton]s stamp on: [child] with the impressions laid over
/// it, each centered at its fraction of the surface and turned by the hand.
///
/// The impressions are [value] with [onValueChanged] (controlled), or kept
/// here starting from [initialValue]. A strike gives the page a 2 px thump
/// and announces "Approved stamped." politely; only impressions struck now
/// land with the animation. [max] keeps the newest impressions only.
///
/// ```dart
/// StampSurface(
///   value: marks,
///   onValueChanged: (next) => setState(() => marks = next),
///   child: Column(children: [
///     const Text('Expense report 118'),
///     StampButton(stamp: 'stamp-approved', impressionId: 'decision'),
///   ]),
/// )
/// ```
///
/// Mirrors `StampSurface` in upstream `src/components/ui/stamp-button.tsx`.
class StampSurface extends StatefulWidget {
  const StampSurface({
    super.key,
    required this.child,
    this.value,
    this.initialValue = const [],
    this.onValueChanged,
    this.max,
  });

  final Widget child;

  /// The impressions, when the parent owns them.
  final List<StampImpression>? value;

  /// The first impressions when [value] is null.
  final List<StampImpression> initialValue;

  /// Called with the impressions after each strike.
  final ValueChanged<List<StampImpression>>? onValueChanged;

  /// Keeps at most this many impressions, dropping the oldest.
  final int? max;

  /// The nearest surface, or null.
  static StampSurfaceState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_StampSurfaceScope>()?.state;

  @override
  State<StampSurface> createState() => StampSurfaceState();
}

/// The state of a [StampSurface]: [strike] stamps on it.
class StampSurfaceState extends State<StampSurface>
    with SingleTickerProviderStateMixin {
  static const Duration _recoil = Duration(milliseconds: 190);
  static const double _recoilDepth = 2;

  late List<StampImpression> _inner = widget.initialValue;
  late List<StampImpression> _latest = _current;
  final Set<String> _struck = {};
  String _status = '';
  late final AnimationController _thump = AnimationController(
    vsync: this,
    duration: _recoil,
  );

  List<StampImpression> get _current => widget.value ?? _inner;

  /// The impressions on the page now.
  List<StampImpression> get impressions => _current;

  @override
  void didUpdateWidget(StampSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    _latest = _current;
  }

  /// Stamps [aim] (its id, place and stamp), replacing any impression in
  /// the same slot with a fresh, slightly wandering strike, and announces
  /// "[say] stamped.".
  StampImpression strike(StampImpression aim, {required String say}) {
    final before = _latest.where((i) => i.id == aim.id).firstOrNull;
    final press = (before?.press ?? 0) + 1;
    final h = hashSeed('${aim.id}|$press');
    double wander(int bits) => (((h >> bits) % 1000) / 1000 - 0.5) * 0.06;
    double clamp01(double v) => math.min(0.96, math.max(0.04, v));
    final impression = aim.struck(
      press: press,
      x: clamp01(aim.x + wander(0)),
      y: clamp01(aim.y + wander(10)),
      ghost:
          aim.ghost ??
          switch (h % 5 == 0) {
            true => true,
            false => null,
          },
      turn: ((h % 700) - 350) / 100,
      seed: '${aim.id}#$press',
    );
    var next = [..._latest.where((i) => i.id != aim.id), impression];
    if (widget.max case final max? when max > 0 && next.length > max) {
      next = next.sublist(next.length - max);
    }
    _latest = next;
    _struck
      ..add(impression.key)
      ..removeWhere((key) => !next.any((i) => i.key == key));
    setState(() {
      if (widget.value == null) _inner = next;
      _status = '$say stamped.';
    });
    widget.onValueChanged?.call(next);
    if (InkMotion.of(context, _recoil) != Duration.zero) {
      _thump.forward(from: 0);
    }
    return impression;
  }

  @override
  void dispose() {
    _thump.dispose();
    super.dispose();
  }

  double _recoilAt(double t) {
    const peak = 0.35;
    if (t <= peak) return _recoilDepth * Curves.easeOut.transform(t / peak);
    return _recoilDepth *
        (1 - Curves.easeOut.transform((t - peak) / (1 - peak)));
  }

  @override
  Widget build(BuildContext context) {
    final impressions = _current;
    return _StampSurfaceScope(
      state: this,
      child: AnimatedBuilder(
        animation: _thump,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, switch (_thump.isAnimating) {
            true => _recoilAt(_thump.value),
            false => 0,
          }),
          child: child,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final i in impressions)
                        Positioned(
                          key: ValueKey(i.key),
                          left: i.x * constraints.maxWidth,
                          top: i.y * constraints.maxHeight,
                          child: FractionalTranslation(
                            translation: const Offset(-0.5, -0.5),
                            child: Transform.rotate(
                              angle: i.turn * math.pi / 180,
                              child: StampImpressionMark(
                                impression: i,
                                thump: _struck.contains(i.key),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (_status.isNotEmpty) Semantics(liveRegion: true, label: _status),
          ],
        ),
      ),
    );
  }
}

class _StampSurfaceScope extends InheritedWidget {
  const _StampSurfaceScope({required this.state, required super.child});

  final StampSurfaceState state;

  @override
  bool updateShouldNotify(_StampSurfaceScope oldWidget) =>
      oldWidget.state != state;
}
