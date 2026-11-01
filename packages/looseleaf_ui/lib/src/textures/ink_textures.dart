import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:looseleaf_ui/src/textures/texture_data.dart';
import 'package:looseleaf_ui/src/textures/texture_tile.dart';

/// Decoded texture bitmaps: the grain mask tiles, the paper tiles, and any
/// `data:` image ink markup embeds. Each is decoded once, on first use, and
/// listeners are notified when a bitmap becomes available.
class InkTextures extends ChangeNotifier {
  InkTextures._();

  /// The shared instance every painter reads.
  static final InkTextures instance = InkTextures._();

  final Map<String, ui.Image> _images = {};
  final Set<String> _pending = {};

  /// The grain kinds with a mask tile: felt, marker, graphite, waxy, stamp.
  static Iterable<String> get grainKinds => grainTiles.keys;

  /// The tile of grain [kind], or null.
  static TextureTile? grainTile(String kind) => grainTiles[kind];

  /// The tile of paper texture [name], or null.
  static TextureTile? paperTile(String name) => paperTiles[name];

  /// Decodes every grain and paper tile. Painting works before this
  /// completes; grain shows up once its tile is ready.
  Future<void> load() => Future.wait([
    for (final kind in grainTiles.keys) _decode('grain:$kind'),
    for (final name in paperTiles.keys) _decode('paper:$name'),
  ]);

  /// The grain tile bitmap of [kind], starting its decode if needed.
  ui.Image? grain(String kind) => _image('grain:$kind');

  /// The paper tile bitmap [name], starting its decode if needed.
  ui.Image? paper(String name) => _image('paper:$name');

  /// The bitmap of a `data:image/...;base64,` URI.
  ui.Image? dataImage(String uri) => _image(uri);

  ui.Image? _image(String key) {
    final image = _images[key];
    if (image != null) return image;
    unawaited(_decode(key));
    return null;
  }

  Future<void> _decode(String key) async {
    if (_images.containsKey(key) || !_pending.add(key)) return;
    final bytes = _bytes(key);
    if (bytes == null) {
      _pending.remove(key);
      return;
    }
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    _images[key] = frame.image;
    _pending.remove(key);
    notifyListeners();
  }

  static Uint8List? _bytes(String key) {
    if (key.startsWith('grain:')) {
      return _base64(grainTiles[key.substring(6)]?.base64);
    }
    if (key.startsWith('paper:')) {
      return _base64(paperTiles[key.substring(6)]?.base64);
    }
    final comma = key.indexOf(',');
    if (!key.startsWith('data:') || comma < 0) return null;
    final header = key.substring(0, comma);
    final body = key.substring(comma + 1);
    if (header.endsWith(';base64')) return base64Decode(body);
    return Uint8List.fromList(utf8.encode(Uri.decodeComponent(body)));
  }

  static Uint8List? _base64(String? data) => switch (data) {
    null => null,
    final text => base64Decode(text),
  };
}
