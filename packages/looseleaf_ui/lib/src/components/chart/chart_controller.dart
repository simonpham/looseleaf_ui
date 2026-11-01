import 'package:flutter/foundation.dart';

/// What moved the chart cursor.
enum ChartActiveSource { pointer, keyboard }

/// The chart's cursor: a target [index], the [series] the keys narrowed
/// to, and what put it there.
@immutable
class ChartActive {
  const ChartActive({
    required this.index,
    required this.source,
    this.series,
  });

  /// The target.
  final int index;

  /// The series the up and down keys picked; null is all of them.
  final int? series;

  /// Pointer or keyboard.
  final ChartActiveSource source;

  @override
  bool operator ==(Object other) =>
      other is ChartActive &&
      other.index == index &&
      other.series == series &&
      other.source == source;

  @override
  int get hashCode => Object.hash(index, series, source);
}

/// The state a chart shares with its tooltip, cursors, center label and
/// live region: the [active] point and the last [announce]d line.
///
/// Mirrors the store of upstream `src/components/ui/chart.tsx`.
class ChartController extends ChangeNotifier {
  ChartActive? _active;
  String _announce = '';

  /// The point under the pointer or the keyboard cursor.
  ChartActive? get active => _active;

  /// The live region's text.
  String get announce => _announce;

  /// Moves the cursor; [announce] replaces the live-region text when given.
  void activate(ChartActive? active, {String? announce}) {
    final text = announce ?? _announce;
    if (active == _active && text == _announce) return;
    _active = active;
    _announce = text;
    notifyListeners();
  }
}
