import 'dart:convert';
import 'dart:io';

/// One frame of `test/fixtures/frames.json`, exported from upstream by
/// `tools/parity/exporters/frames.ts`.
class FixtureFrame {
  FixtureFrame(Map<String, Object?> json)
    : name = json['name'] as String,
      width = (json['w'] as num).toDouble(),
      height = (json['h'] as num).toDouble(),
      pad = (json['pad'] as num).toDouble(),
      layers = (json['layers'] as List).cast<String>(),
      parts = (json['parts'] as Map).cast<String, String>();

  final String name;
  final double width;
  final double height;
  final double pad;
  final List<String> layers;
  final Map<String, String> parts;

  static List<FixtureFrame> load() {
    final json =
        jsonDecode(
              File('test/fixtures/frames.json').readAsStringSync(),
            )
            as Map<String, Object?>;
    return [
      for (final frame in json['frames'] as List)
        FixtureFrame((frame as Map).cast<String, Object?>()),
    ];
  }

  static FixtureFrame named(String name) =>
      load().firstWhere((frame) => frame.name == name);
}
