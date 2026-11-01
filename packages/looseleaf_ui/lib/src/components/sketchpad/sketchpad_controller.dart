import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The state of a [Sketchpad]: its strokes, the undo history, the tool,
/// color and width in hand, and the last screen-reader announcement.
///
/// Upstream keeps these in `Sketchpad`'s props and its `apiRef` handle
/// (`undo`, `redo`, `clear`, `replay`, `strokes`, `toSVG`, `toPNG`); here
/// they live on a controller you can hold, listen to and drive.
///
/// ```dart
/// final sketch = SketchpadController(color: SketchColor.inkYou);
/// Sketchpad(controller: sketch);
/// sketch.undo();
/// final svg = sketch.toSvg(width: 640, height: 400);
/// ```
///
/// Mirrors the state of upstream `src/components/ui/sketchpad.tsx`.
class SketchpadController extends ChangeNotifier {
  SketchpadController({
    List<SketchStroke> strokes = const [],
    SketchTool tool = SketchTool.felt,
    SketchColor color = SketchColor.ink,
    double? size,
  }) : _strokes = List.unmodifiable(strokes),
       _tool = tool,
       _color = color,
       _size = size ?? SketchSizeName.medium.size;

  /// How many steps undo remembers.
  static const int historyLimit = 100;

  List<SketchStroke> _strokes;
  SketchTool _tool;
  SketchColor _color;
  double _size;
  String _announcement = '';
  int _replayKey = 0;
  int _counter = 0;
  final List<List<SketchStroke>> _past = [];
  final List<List<SketchStroke>> _future = [];

  /// The strokes, oldest first.
  List<SketchStroke> get strokes => _strokes;

  /// Replaces the strokes from outside (a controlled value): the undo
  /// history is forgotten, as upstream does when `value` changes.
  set strokes(List<SketchStroke> next) {
    if (identical(next, _strokes)) return;
    _strokes = List.unmodifiable(next);
    _past.clear();
    _future.clear();
    notifyListeners();
  }

  /// The tool in hand.
  SketchTool get tool => _tool;

  /// The ink color.
  SketchColor get color => _color;

  /// The width multiplier (see [SketchSizeName]).
  double get size => _size;

  /// The last change, worded for screen readers.
  String get announcement => _announcement;

  /// Bumped by [replay]; the canvas redraws the strokes in order.
  int get replayKey => _replayKey;

  /// Whether [undo] has a step to go back to.
  bool get canUndo => _past.isNotEmpty;

  /// Whether [redo] has a step to go forward to.
  bool get canRedo => _future.isNotEmpty;

  /// Sets the strokes to [next] as one undoable step and announces
  /// [message] with the new stroke count.
  void commit(List<SketchStroke> next, String message) {
    _past.add(_strokes);
    if (_past.length > historyLimit) _past.removeAt(0);
    _future.clear();
    _strokes = List.unmodifiable(next);
    _announcement = '$message ${strokeCount(next.length)}.';
    notifyListeners();
  }

  /// Goes back one step.
  void undo() {
    if (_past.isEmpty) return;
    _future.add(_strokes);
    _strokes = _past.removeLast();
    _announcement = 'Undone. ${strokeCount(_strokes.length)}.';
    notifyListeners();
  }

  /// Goes forward one step.
  void redo() {
    if (_future.isEmpty) return;
    _past.add(_strokes);
    _strokes = _future.removeLast();
    _announcement = 'Redone. ${strokeCount(_strokes.length)}.';
    notifyListeners();
  }

  /// Removes every stroke as one undoable step.
  void clear() {
    if (_strokes.isEmpty) return;
    commit(const [], 'Cleared.');
  }

  /// Draws the strokes again, one after another.
  void replay() {
    _replayKey++;
    notifyListeners();
  }

  /// Picks [next]. The highlighter swaps a dark ink for its yellow, and
  /// leaving it swaps the yellow back to ink.
  void selectTool(SketchTool next) {
    final previous = _tool;
    _tool = next;
    if (next == SketchTool.highlighter && _color.dark) {
      _color = SketchColor.hi;
    }
    final leftHighlighter =
        previous == SketchTool.highlighter &&
        next != SketchTool.highlighter &&
        _color == SketchColor.hi;
    if (leftHighlighter) _color = SketchColor.ink;
    notifyListeners();
  }

  set color(SketchColor next) {
    if (next == _color) return;
    _color = next;
    notifyListeners();
  }

  set size(double next) {
    if (next == _size) return;
    _size = next;
    notifyListeners();
  }

  /// Announces [message] to screen readers.
  void say(String message) {
    _announcement = message;
    notifyListeners();
  }

  /// A stroke id not used by any stroke yet.
  String nextId() {
    final used = {for (final stroke in _strokes) stroke.id};
    var id = '';
    do {
      id = 's${(_counter++).toRadixString(36)}';
    } while (used.contains(id));
    return id;
  }

  /// The strokes as a standalone SVG document of [width] × [height],
  /// upstream `toSVG`; see [SketchpadExport.svg].
  String toSvg({
    required double width,
    required double height,
    LooseleafColors colors = const LooseleafColors(),
    bool background = true,
    double? margin,
    String? title,
  }) => SketchpadExport.svg(
    _strokes,
    width: width,
    height: height,
    colors: colors,
    background: background,
    margin: margin,
    title: title,
  );

  /// The strokes as PNG bytes, upstream `toPNG`; see [SketchpadExport.png].
  Future<Uint8List?> toPng({
    required double width,
    required double height,
    LooseleafThemeData theme = const LooseleafThemeData(),
    bool background = true,
    double margin = 0,
    double scale = 2,
  }) => SketchpadExport.png(
    _strokes,
    width: width,
    height: height,
    theme: theme,
    background: background,
    margin: margin,
    scale: scale,
  );
}
