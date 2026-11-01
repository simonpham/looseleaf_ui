import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  test('every catalog doodle draws', () {
    for (final MapEntry(key: name, value: def) in doodles.entries) {
      expect(drawSkeleton(def, 96, name).svg, isNotEmpty, reason: name);
    }
  });

  testWidgets('sizes to at least 24 px; unknown names show nothing', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const Doodle('sun')));
    expect(tester.getSize(find.byType(InkArt)), const Size.square(96));
    await tester.pumpWidget(componentHost(const Doodle('sun', size: 10)));
    expect(tester.getSize(find.byType(InkArt)), const Size.square(24));
    await tester.pumpWidget(componentHost(const Doodle('no-such-doodle')));
    expect(find.byType(InkArt), findsNothing);
  });

  testWidgets('rotate and flip reach the art', (tester) async {
    await tester.pumpWidget(
      componentHost(const Doodle('star', rotate: 90, flip: true)),
    );
    final art = tester.widget<InkArt>(find.byType(InkArt));
    expect(art.rotation, closeTo(1.5708, 1e-4));
    expect(art.flipX, isTrue);
  });

  testWidgets('a label makes it an image', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(const Doodle('sun', semanticLabel: 'Sunny')),
    );
    expect(
      tester.getSemantics(find.byType(Doodle)),
      matchesSemantics(label: 'Sunny', isImage: true),
    );
    handle.dispose();
  });
}
