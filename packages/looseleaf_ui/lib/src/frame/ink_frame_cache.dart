import 'dart:collection';

import 'package:looseleaf_ui/src/frame/ink_frame.dart';
import 'package:looseleaf_ui/src/frame/ink_frame_request.dart';
import 'package:looseleaf_ui/src/frame/ink_layers.dart';
import 'package:looseleaf_ui/src/frame/ink_sheet.dart';
import 'package:looseleaf_ui/src/frame/ink_source.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';

/// An LRU cache of parsed frames, like upstream `inkCache`
/// (`src/lib/ink/react/cache.ts`): bounded by entry count and markup size,
/// keyed like `frameKey`, with lazy layers drawn on demand and kept.
class InkFrameCache {
  InkFrameCache({this.maxEntries = 600, this.maxChars = 6000000});

  /// The cache every [InkSurface] uses by default.
  static final InkFrameCache shared = InkFrameCache();

  int maxEntries;
  int maxChars;
  int hits = 0;
  int misses = 0;
  int _chars = 0;
  final LinkedHashMap<String, _Entry> _entries = LinkedHashMap();

  int get length => _entries.length;
  int get chars => _chars;

  /// The cache key of [request] for [source], like upstream `frameKey`.
  static String keyOf(InkSource source, InkFrameRequest request) {
    final box = InkFrameRequest.bucketBox(request.box);
    return [
      source.id,
      '${_js(box.width)}x${_js(box.height)}',
      request.seed,
      request.effectiveTier.name,
      request.density.name,
      request.textDirection.name,
      switch (request.pad) {
        null => '',
        final pad => _js(pad),
      },
      source.paramsKey,
      request.knobs.key,
    ].join('|');
  }

  static String _js(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  /// The frame for [request], drawing and parsing it on a miss. Lazy layers
  /// in [InkFrameRequest.lazy] the source declares are drawn once and kept.
  InkFrame frame(InkSource source, InkFrameRequest request) {
    final key = keyOf(source, request);
    final box = InkFrameRequest.bucketBox(request.box);
    final wanted = request.lazy.intersection(source.lazyLayers);
    var entry = _entries.remove(key);
    if (entry != null) {
      hits++;
      _entries[key] = entry;
    }
    if (entry == null) {
      misses++;
      final markup = source.draw(
        InkFrameRequest(
          box: box,
          seed: request.seed,
          tier: request.effectiveTier,
          density: request.density,
          textDirection: request.textDirection,
          knobs: request.knobs,
          pad: request.pad,
          lazy: wanted,
        ),
      );
      final created = _Entry(key, box.width, box.height, markup.pad);
      final eager = <String, String>{};
      for (final MapEntry(key: layer, value: part) in markup.parts.entries) {
        if (part.isEmpty) continue;
        if (wanted.contains(layer)) {
          created.addLazy(layer, part);
          continue;
        }
        eager[layer] = part;
      }
      created.addEager(eager);
      for (final layer in wanted) {
        created.drawnLazy.add(layer);
      }
      entry = created;
      _entries[key] = created;
      _chars += created.chars;
    }
    final missing = wanted.difference(entry.drawnLazy);
    if (missing.isNotEmpty) {
      final markup = source.draw(
        request.withLazy(missing, lazyOnly: true),
      );
      final before = entry.chars;
      for (final layer in missing) {
        entry.drawnLazy.add(layer);
        final part = markup.parts[layer] ?? '';
        if (part.isNotEmpty) entry.addLazy(layer, part);
      }
      _chars += entry.chars - before;
    }
    _evict();
    return entry.frame;
  }

  void _evict() {
    while (_entries.length > 1 &&
        (_entries.length > maxEntries || _chars > maxChars)) {
      final oldest = _entries.keys.first;
      final removed = _entries.remove(oldest);
      _chars -= removed?.chars ?? 0;
    }
  }

  void clear() {
    _entries.clear();
    _chars = 0;
  }
}

class _Entry {
  _Entry(this.key, this.width, this.height, this.pad);

  final String key;
  final double width;
  final double height;
  final double pad;
  final Map<String, InkDocument> documents = {};
  final Set<String> drawnLazy = {};
  int chars = 0;
  InkSheet? _sheet;
  InkFrame? _frame;

  void addEager(Map<String, String> parts) {
    if (parts.isEmpty) return;
    final sheet = InkSheet.of(InkLayers.sorted(parts.keys), parts);
    _sheet = sheet;
    final document = sheet?.document ?? InkDocument.parseLayers(parts);
    for (final layer in parts.keys) {
      documents[layer] = document;
    }
    chars += document.chars;
    _frame = null;
  }

  void addLazy(String layer, String part) {
    final document = InkDocument.parseLayers({layer: part});
    documents[layer] = document;
    chars += document.chars;
    _frame = null;
  }

  InkFrame get frame => _frame ??= InkFrame(
    key: key,
    width: width,
    height: height,
    pad: pad,
    layers: InkLayers.sorted(documents.keys),
    documents: Map.unmodifiable(documents),
    sheet: _sheet,
  );
}
