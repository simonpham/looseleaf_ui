import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

void main() {
  test('a full match scores 1, a prefix a little less', () {
    expect(commandScore('hello', 'hello', const []), 1);
    expect(commandScore('hello', 'hel', const []), 0.99);
    expect(commandScore('hello', 'xyz', const []), 0);
  });

  test('another case costs a hair', () {
    expect(commandScore('Hello', 'hello', const []), 0.9999);
  });

  test('word starts beat letters inside words', () {
    expect(
      commandScore('go to settings', 'gs', const []),
      closeTo(0.99 * 0.9 * 0.999, 1e-12),
    );
    expect(
      commandScore('Calendar', 'ca', const []),
      greaterThan(commandScore('Search', 'ca', const [])),
    );
    expect(
      commandScore('src/main', 'm', const []),
      greaterThan(commandScore('lemon', 'm', const [])),
    );
  });

  test('keywords join the value', () {
    expect(commandScore('Search Emoji', 'smiley', const []), 0);
    expect(commandScore('Search Emoji', 'smiley', const ['smiley']), 0.9);
  });

  test('transposed letters still match, weakly', () {
    final swapped = commandScore('ouch', 'uoch', const []);
    expect(swapped, greaterThan(0));
    expect(swapped, lessThan(commandScore('ouch', 'ouch', const [])));
  });

  test('hyphens and spaces match each other', () {
    expect(commandScore('dark-mode', 'dark mode', const []), 0.9999);
  });
}
