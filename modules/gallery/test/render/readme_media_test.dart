import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/gallery.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../support/gallery_host.dart';

const _frame = Duration(milliseconds: 40);

/// Renders the README media from the gallery home: a still, and the frames
/// of a short walk over the desk with the pointer path in `cursor.txt`.
/// `README_MEDIA_DIR=/some/dir flutter test test/render/readme_media_test.dart`,
/// then `tools/readme/make_media.sh /some/dir`.
void main() {
  final out = Platform.environment['README_MEDIA_DIR'];

  setUpAll(() async {
    await loadKevinSans();
  });

  testWidgets('readme media', skip: out == null, (tester) async {
    if (out == null) return;
    await tester.runAsync(InkTextures.instance.load);
    await pumpGallery(
      tester,
      const HomeRoute(),
      size: const ui.Size(1440, 1800),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(seconds: 1));
    await _capture(tester, '$out/still.png');

    final walk = _Walk(tester, out);
    await walk.start(const Offset(700, 520));
    await walk.press(find.text('Get started'), tap: false);
    await walk.press(find.text('Airplane mode'));
    await walk.press(find.text('Fix the focus ring'));
    await walk.press(find.text('Water the plant'));
    await walk.press(find.text('Sprint'));
    await walk.press(find.text('Saved'), hold: 40);
    await walk.finish();
  });
}

final class _Walk {
  _Walk(this.tester, this.out);

  final WidgetTester tester;
  final String out;
  final List<String> _cursor = [];
  late TestGesture _mouse;
  Offset _at = Offset.zero;
  var _index = 0;

  Future<void> start(Offset at) async {
    _at = at;
    _mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await _mouse.addPointer(location: at);
    await _record(6);
  }

  Future<void> press(Finder target, {bool tap = true, int hold = 18}) async {
    final to = tester.getCenter(target.first);
    final from = _at;
    const steps = 12;
    for (var step = 1; step <= steps; step++) {
      final t = Curves.easeInOut.transform(step / steps);
      _at = Offset.lerp(from, to, t) ?? to;
      await _mouse.moveTo(_at);
      await _record(1);
    }
    await _record(6);
    if (tap) {
      await _mouse.down(_at);
      await _record(3);
      await _mouse.up();
    }
    await _record(hold);
  }

  Future<void> finish() async {
    await _mouse.removePointer();
    File('$out/cursor.txt').writeAsStringSync(_cursor.join('\n'));
  }

  Future<void> _record(int frames) async {
    for (var frame = 0; frame < frames; frame++) {
      await tester.pump(_frame);
      final name = '$_index'.padLeft(4, '0');
      await _capture(tester, '$out/frame_$name.png');
      _cursor.add('$name ${_at.dx.round()} ${_at.dy.round()}');
      _index++;
    }
  }
}

Future<void> _capture(WidgetTester tester, String path) async {
  final view = tester.binding.renderViews.first;
  if (view.debugLayer case final OffsetLayer layer) {
    final image = await tester.runAsync(
      () => layer.toImage(Offset.zero & view.size),
    );
    final bytes = await tester.runAsync(
      () async => image?.toByteData(format: ui.ImageByteFormat.png),
    );
    if (bytes == null) return;
    File(path).writeAsBytesSync(bytes.buffer.asUint8List());
  }
}
