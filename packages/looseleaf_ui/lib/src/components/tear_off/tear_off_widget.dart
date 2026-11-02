import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/tear_off/tear_off_body.dart';
import 'package:looseleaf_ui/src/components/tear_off/tear_off_scope.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A ticket with a perforated stub you tear off: a coupon, a raffle half,
/// the free coffee on a punch card.
///
/// Put a [TearOffBody] and a [TearOffStub] in [children]. The stub tears
/// on a tap, on Enter or Space, or when pulled at least half way along the
/// perforation; it swings off, falls and leaves the layout. [orientation]
/// [Axis.vertical] hangs the stub under the body. Side by side, the body
/// gives way to a narrow parent (upstream `min-w-0 flex-1`). Uncontrolled it keeps its
/// own state ([defaultTorn]); pass [torn] and [onTornChange] to control it,
/// and set `torn: false` to put the stub back (it drops in). A screen
/// reader hears [tornMessage] once it comes off.
///
/// ```dart
/// TearOff(
///   onTear: redeem,
///   children: const [
///     TearOffBody(width: 256, child: Text('Studio night')),
///     TearOffStub(width: 128, children: [Text('10% off')]),
///   ],
/// )
/// ```
///
/// Mirrors `TearOff` in upstream `src/components/ui/tear-off.tsx`.
class TearOff extends StatefulWidget {
  const TearOff({
    super.key,
    required this.children,
    this.torn,
    this.defaultTorn = false,
    this.onTornChange,
    this.onTear,
    this.orientation = Axis.horizontal,
    this.disabled = false,
    this.tornMessage = 'Torn off.',
  });

  /// How long the stub falls before it leaves the layout.
  static const Duration fall = Duration(milliseconds: 420);

  /// How long a put-back stub counts as just restored.
  static const Duration restore = Duration(milliseconds: 500);

  /// The [TearOffBody] then the [TearOffStub].
  final List<Widget> children;

  /// Whether the stub is off; null leaves it uncontrolled.
  final bool? torn;

  /// The first state of an uncontrolled tear-off.
  final bool defaultTorn;

  /// Called with `true` when the stub tears.
  final ValueChanged<bool>? onTornChange;

  /// Called when the stub tears.
  final VoidCallback? onTear;

  /// Stub after the body ([Axis.horizontal]) or under it.
  final Axis orientation;

  /// Keeps the stub on.
  final bool disabled;

  /// What a screen reader hears when the stub comes off.
  final String tornMessage;

  @override
  State<TearOff> createState() => _TearOffState();
}

class _TearOffState extends State<TearOff> {
  late bool _inner = widget.defaultTorn;
  late bool _gone;
  late bool _wasTorn;
  bool _restored = false;
  bool _holdFocus = false;
  Timer? _timer;
  final FocusNode _root = FocusNode(
    debugLabel: 'TearOff',
    skipTraversal: true,
  );

  bool get _torn => widget.torn ?? _inner;

  @override
  void initState() {
    super.initState();
    _wasTorn = _torn;
    _gone = _torn;
  }

  @override
  void didUpdateWidget(TearOff oldWidget) {
    super.didUpdateWidget(oldWidget);
    _follow();
  }

  void _follow() {
    if (_torn == _wasTorn) return;
    _wasTorn = _torn;
    _timer?.cancel();
    if (_torn) {
      if (_holdFocus) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _root.requestFocus();
        });
      }
      _holdFocus = false;
      final delay = InkMotion.of(context, TearOff.fall);
      _timer = Timer(delay, () {
        if (!mounted) return;
        setState(() => _gone = true);
      });
      return;
    }
    _gone = false;
    _restored = true;
    _timer = Timer(TearOff.restore, () {
      if (!mounted) return;
      setState(() => _restored = false);
    });
  }

  void _tear() {
    if (_torn || widget.disabled) return;
    _holdFocus = _root.hasFocus;
    if (widget.torn == null) setState(() => _inner = true);
    widget.onTornChange?.call(true);
    widget.onTear?.call();
    _follow();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _root.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vertical = widget.orientation == Axis.vertical;
    final flex = switch (vertical) {
      true => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      ),
      false => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in widget.children)
            switch (child) {
              TearOffBody() => Flexible(child: child),
              _ => child,
            },
        ],
      ),
    };
    return TearOffScope(
      torn: _torn,
      gone: _gone,
      restored: _restored,
      orientation: widget.orientation,
      disabled: widget.disabled,
      tear: _tear,
      child: Focus(
        focusNode: _root,
        canRequestFocus: _torn,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            switch (vertical) {
              true => IntrinsicWidth(child: flex),
              false => IntrinsicHeight(child: flex),
            },
            Semantics(
              container: true,
              liveRegion: true,
              label: switch (_torn) {
                true => widget.tornMessage,
                false => '',
              },
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
