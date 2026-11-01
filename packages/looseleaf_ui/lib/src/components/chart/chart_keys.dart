import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// How charts find their keys in the data and their names in the config.
///
/// Mirrors `labelText`, `inferSeries` and `inferXKey` in upstream
/// `src/components/ui/chart.tsx`.
abstract final class ChartKeys {
  /// The name of [key] in [config], or the key itself.
  static String label(ChartConfig config, String key) =>
      config[key]?.label ?? key;

  /// The numeric keys to draw: the config's, else the data's, in order.
  static List<String> series(
    List<ChartRow> rows,
    String xKey,
    ChartConfig? config,
  ) {
    final first = rows.take(12).toList();
    bool numeric(String key) => first.any((row) => isNum(toNum(row[key])));
    if (config != null) {
      final fromConfig = [
        for (final key in config.keys)
          if (key != xKey && numeric(key)) key,
      ];
      if (fromConfig.isNotEmpty) return fromConfig;
    }
    final keys = <String>[];
    for (final row in first) {
      for (final key in row.keys) {
        if (key != xKey && !keys.contains(key) && numeric(key)) keys.add(key);
      }
    }
    return keys;
  }

  /// The first key holding text, else the first key.
  static String xKey(List<ChartRow> rows) {
    final first = rows.firstOrNull ?? const <String, Object?>{};
    for (final MapEntry(:key, :value) in first.entries) {
      if (value is String && toNum(value) == null) return key;
    }
    return first.keys.firstOrNull ?? 'x';
  }

  /// The palette slot of [key]: its position in the config, else [fallback].
  static int slot(ChartConfig config, String key, int fallback) {
    final at = [...config.keys].indexOf(key);
    if (at >= 0) return at;
    return fallback;
  }

  /// A slice's pattern: solid without patterns or with one slice, else
  /// the slot's, or the config's when [fromConfig].
  static FillPattern slicePattern(
    ChartConfig config,
    ChartPatterns patterns,
    String key,
    int slot,
    int count, {
    bool fromConfig = false,
  }) {
    if (patterns == ChartPatterns.off || count < 2) {
      return FillPattern.solid;
    }
    if (config[key]?.pattern case final own? when fromConfig) return own;
    return defaultPattern(slot);
  }
}
