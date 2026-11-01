import 'package:looseleaf_ui/looseleaf_ui.dart';

import 'fixture_frames.dart';

/// An [InkSource] serving a fixture frame's markup, recording each request.
class FixtureSource extends InkSource {
  FixtureSource(this.frame, {this.lazyLayers = const {}});

  final FixtureFrame frame;
  final List<InkFrameRequest> requests = [];

  @override
  final Set<String> lazyLayers;

  @override
  String get id => 'fixture-${frame.name}@1';

  @override
  String get paramsKey => '{}';

  @override
  InkMarkup draw(InkFrameRequest request) {
    requests.add(request);
    final parts = <String, String>{};
    for (final MapEntry(key: layer, value: part) in frame.parts.entries) {
      final lazy = lazyLayers.contains(layer);
      if (request.lazyOnly && !request.lazy.contains(layer)) continue;
      if (lazy && !request.lazy.contains(layer)) continue;
      parts[layer] = part;
    }
    return InkMarkup(parts: parts, pad: frame.pad);
  }
}
