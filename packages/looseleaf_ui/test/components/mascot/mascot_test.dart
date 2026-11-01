import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  test('every pose and flipbook frame draws', () {
    for (final MapEntry(key: name, value: def) in {
      ...mascot,
      ...mascotFrames,
    }.entries) {
      expect(drawMascot(def, 96, name).svg, isNotEmpty, reason: name);
    }
  });

  testWidgets('sizes to the die cut, with the sticker shadow', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const Mascot()));
    final size = tester.getSize(find.byType(InkArt));
    expect(size.width, lessThanOrEqualTo(96));
    expect(size.height, lessThanOrEqualTo(96));
    expect(tester.widget<InkArt>(find.byType(InkArt)).shadow, isTrue);
  });

  testWidgets('a frame picks the flipbook drawing', (tester) async {
    final frame = mascotFrames.keys.first;
    final dash = frame.lastIndexOf('-');
    final pose = frame.substring(0, dash);
    final index = int.parse(frame.substring(dash + 1));
    await tester.pumpWidget(componentHost(Mascot(pose: pose, frame: index)));
    expect(
      tester.widget<InkArt>(find.byType(InkArt)).cacheKey,
      startsWith('mascot|$pose|$index|'),
    );
    await tester.pumpWidget(componentHost(const Mascot(pose: 'nobody')));
    expect(find.byType(InkArt), findsNothing);
  });
}
