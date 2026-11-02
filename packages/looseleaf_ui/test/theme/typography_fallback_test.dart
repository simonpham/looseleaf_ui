import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../support/kevin_sans.dart';

double _advance(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style.copyWith(fontSize: 100)),
    textDirection: TextDirection.ltr,
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

void main() {
  const typography = LooseleafTypography();

  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(
      loadKevinSans,
    );
  });

  test('Kevin Sans falls back to the bundled IBM Plex Mono', () {
    final style = typography.interface();
    expect(style.fontFamily, 'packages/looseleaf_ui/KevinSans');
    expect(style.fontFamilyFallback, [
      LooseleafTypography.bundledMonoFamily,
    ]);
    expect(typography.mono().fontFamily, 'packages/looseleaf_ui/IBMPlexMono');
  });

  test('an app-bundled family keeps its own name and the fallback', () {
    const own = LooseleafTypography(fontFamily: 'Hand', package: null);
    expect(own.interface().fontFamily, 'Hand');
    expect(own.interface().fontFamilyFallback, [
      'packages/looseleaf_ui/IBMPlexMono',
    ]);
  });

  test('€ and £, missing from Kevin Sans, draw from IBM Plex Mono', () {
    final style = typography.interface();
    expect(_advance('€', style), closeTo(60, 0.5));
    expect(_advance('£', style), closeTo(60, 0.5));
  });

  test('the password dot is Kevin Sans’s own bullet', () {
    expect(_advance('•', typography.interface()), closeTo(38.5, 0.5));
  });
}
