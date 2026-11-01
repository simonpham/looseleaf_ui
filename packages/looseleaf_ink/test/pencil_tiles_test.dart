import 'dart:convert';
import 'dart:io';

import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:test/test.dart';

void main() {
  final fixture =
      jsonDecode(File('test/fixtures/pencil_tiles.json').readAsStringSync())
          as Map<String, dynamic>;
  List<Map<String, dynamic>> cases(String key) =>
      (fixture[key] as List).cast<Map<String, dynamic>>();

  for (final c in cases('edge')) {
    test('edgeTile ${c['seed']} ${c['vertical']}', () {
      expect(edgeTile(c['seed'] as String, c['vertical'] == true), c['out']);
    });
  }
  for (final c in cases('hatch')) {
    test('hatchTile ${c['seed']}', () {
      expect(hatchTile(c['seed'] as String), c['out']);
    });
  }
  for (final c in cases('circle')) {
    test('circleTile ${c['seed']}', () {
      expect(circleTile(c['seed'] as String), c['out']);
    });
  }
}
