import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

void main() {
  test('cssColor writes hex, or rgba when translucent', () {
    expect(InkExport.cssColor(const Color(0xFF1A2B3C)), '#1a2b3c');
    expect(
      InkExport.cssColor(const Color(0x801A2B3C)),
      'rgba(26, 43, 60, 0.502)',
    );
  });

  test('tileUri is empty for an unknown tile', () {
    expect(InkExport.tileUri('no-such-tile'), isEmpty);
  });
}
