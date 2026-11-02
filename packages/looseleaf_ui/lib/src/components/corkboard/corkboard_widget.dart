import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/corkboard/corkboard.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A cork pinboard in a kraft frame with notes you pick up and move: each
/// [CorkboardNote] is pinned (or taped) where its position says, kept on
/// the cork, and the last one dropped sits on top.
///
/// The layout is yours with [value] and [onValueChange], or the board's own
/// starting at [defaultValue]. Notes not in the layout sit at their own
/// `x`, `y` and `rotate`. A note moves by dragging, or with the arrow keys
/// once focused (Shift for bigger steps); R turns it, Shift R back, Enter
/// brings it to the front. Moves are announced. [disabled] keeps every note
/// where it is.
///
/// The board fills its width; its height is [height], else the parent's
/// bounded height, else 256 px.
///
/// ```dart
/// Corkboard(
///   height: 360,
///   children: const [
///     CorkboardNote(id: 'mum', x: 20, y: 26, child: Text('Call mum')),
///     CorkboardNote(id: 'ink', x: 250, y: 40, stock: StockName.stickyPink,
///         child: Text('Buy more ink!!')),
///   ],
/// )
/// ```
///
/// Mirrors `Corkboard` in upstream `src/components/ui/corkboard.tsx`.
class Corkboard extends StatefulWidget {
  const Corkboard({
    super.key,
    required this.children,
    this.value,
    this.defaultValue = const {},
    this.onValueChange,
    this.label = 'Corkboard',
    this.disabled = false,
    this.height,
    this.seed,
  });

  /// Upstream's `min-h-64`.
  static const double minHeight = Spacing.d256;

  /// The notes.
  final List<CorkboardNote> children;

  /// The layout; the board keeps its own when null.
  final CorkboardValue? value;

  /// The starting layout, when [value] is null.
  final CorkboardValue defaultValue;

  /// Called with the whole layout after each move, turn or raise.
  final ValueChanged<CorkboardValue>? onValueChange;

  /// The board's accessible name.
  final String label;

  /// Notes cannot be moved or focused.
  final bool disabled;

  /// The board's height, at least [minHeight].
  final double? height;

  /// Pins the hand: the same seed draws the same cork.
  final String? seed;

  /// Read to screen readers with the board.
  static const String help =
      'Notes can be moved with a pointer, or focus one and use the arrow '
      'keys (Shift for bigger steps). R turns it clockwise, Shift R back. '
      'Enter brings it to the front.';

  @override
  State<Corkboard> createState() => _CorkboardState();
}

class _CorkboardState extends State<Corkboard> with InkSeed {
  late CorkboardValue _inner = widget.defaultValue;
  late CorkboardValue _latest = _positions;
  String? _lifted;
  Timer? _said;

  CorkboardValue get _positions => widget.value ?? _inner;

  int get _topZ => _latest.values.fold(0, (top, p) => math.max(top, p.z ?? 0));

  void _update(String id, NotePosition patch, String? message) {
    final next = {
      ..._latest,
      id: (_latest[id] ?? const NotePosition()).merge(patch),
    };
    _latest = next;
    if (widget.value == null) setState(() => _inner = next);
    widget.onValueChange?.call(next);
    if (message != null) _say(message);
  }

  void _say(String message) {
    _said?.cancel();
    _said = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      unawaited(inkAnnounce(context, message));
    });
  }

  void _lift(String? id) {
    if (_lifted == id) return;
    setState(() => _lifted = id);
  }

  @override
  void dispose() {
    _said?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _latest = _positions;
    final theme = LooseleafTheme.of(context);
    const params = CorkBoardParams(frame: corkFrame);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      hint: Corkboard.help,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = math.max(
            Corkboard.minHeight,
            widget.height ??
                switch (constraints.hasBoundedHeight) {
                  true => constraints.maxHeight,
                  false => Corkboard.minHeight,
                },
          );
          final width = switch (constraints.hasBoundedWidth) {
            true => constraints.maxWidth,
            false => Spacing.d256 * 2,
          };
          final surface = Size(
            math.max(0, width - 2 * corkFrame),
            math.max(0, height - 2 * corkFrame),
          );
          return ColoredBox(
            color:
                Color.lerp(theme.colors.kraft, theme.colors.marker, 0.22) ??
                theme.colors.kraft,
            child: InkSurface(
              source: RecipeInkSource(
                corkBoardRecipe,
                params,
                json: params.toJson(),
              ),
              seed: inkSeed(widget.seed),
              child: SizedBox(
                width: width,
                height: height,
                child: Padding(
                  padding: const EdgeInsets.all(corkFrame),
                  child: CorkboardScope(
                    positions: _positions,
                    update: _update,
                    topZ: _topZ,
                    surface: surface,
                    disabled: widget.disabled,
                    lift: _lift,
                    lifted: _lifted,
                    child: _notes(theme),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  int _liftRank(String id) => switch (id == _lifted) {
    true => 1,
    false => 0,
  };

  Widget _notes(LooseleafThemeData theme) {
    final calm = theme.density == LooseleafDensity.calm;
    final placed = [
      for (final note in widget.children)
        (note: note, at: note.positionIn(_positions, calm: calm)),
    ];
    final stacked = [...placed]
      ..sort((a, b) {
        final lift = _liftRank(a.note.id).compareTo(_liftRank(b.note.id));
        if (lift != 0) return lift;
        return (a.at.z ?? 0).compareTo(b.at.z ?? 0);
      });
    return CustomMultiChildLayout(
      delegate: _CorkboardLayout({
        for (final entry in placed)
          entry.note.id: Offset(entry.at.x ?? 0, entry.at.y ?? 0),
      }),
      children: [
        for (final entry in stacked)
          LayoutId(id: entry.note.id, child: entry.note),
      ],
    );
  }
}

class _CorkboardLayout extends MultiChildLayoutDelegate {
  _CorkboardLayout(this.at);

  final Map<String, Offset> at;

  @override
  void performLayout(Size size) {
    for (final MapEntry(key: id, value: offset) in at.entries) {
      if (!hasChild(id)) continue;
      final note = layoutChild(id, BoxConstraints.loose(size));
      positionChild(
        id,
        Offset(
          offset.dx.clamp(0, math.max(0, size.width - note.width)),
          offset.dy.clamp(0, math.max(0, size.height - note.height)),
        ),
      );
    }
  }

  @override
  bool shouldRelayout(_CorkboardLayout oldDelegate) =>
      !_sameOffsets(oldDelegate.at, at);

  static bool _sameOffsets(Map<String, Offset> a, Map<String, Offset> b) {
    if (a.length != b.length) return false;
    for (final MapEntry(:key, :value) in a.entries) {
      if (b[key] != value) return false;
    }
    return true;
  }
}
