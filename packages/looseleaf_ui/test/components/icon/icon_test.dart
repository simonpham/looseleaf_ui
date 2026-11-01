import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Size _size(WidgetTester tester) =>
    tester.getSize(find.byType(CustomPaint).last);

InkArt _art(WidgetTester tester) => tester.widget<InkArt>(find.byType(InkArt));

void main() {
  test('Lucide names resolve to catalog ids', () {
    expect(const InkIcon('LucideArrowRight').id, 'arrow-right');
    expect(const InkIcon('ArrowRightIcon').id, 'arrow-right');
    expect(const InkIcon('alert-triangle').id, 'triangle-alert');
    expect(const InkIcon('alert-triangle').known, isTrue);
    expect(const InkIcon('no-such-icon').known, isFalse);
  });

  test('every catalog icon draws', () {
    for (final name in icons.keys) {
      final result = drawSkeleton(icons[name] ?? missingIcon, 16, name);
      expect(result.svg, isNotEmpty, reason: name);
    }
  });

  testWidgets('defaults to 16 px and takes the ambient icon size', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const InkIcon('check')));
    expect(_size(tester), const Size.square(16));
    await tester.pumpWidget(
      componentHost(
        const IconTheme(
          data: IconThemeData(size: 20),
          child: InkIcon('check'),
        ),
      ),
    );
    expect(_size(tester), const Size.square(20));
    await tester.pumpWidget(
      componentHost(const InkIcon('check', size: 4.2)),
    );
    expect(_size(tester), const Size.square(8));
  });

  testWidgets('small ui icons draw with the heavier nib', (tester) async {
    await tester.pumpWidget(componentHost(const InkIcon('check')));
    expect(_art(tester).cacheKey, endsWith('|1.12'));
    await tester.pumpWidget(componentHost(const InkIcon('check', size: 32)));
    expect(_art(tester).cacheKey, endsWith('|1'));
    await tester.pumpWidget(
      componentHost(const InkIcon('check', tone: ArtTone.doodle)),
    );
    expect(_art(tester).cacheKey, endsWith('|1'));
  });

  testWidgets('inks in the ambient icon color', (tester) async {
    const colors = LooseleafColors();
    await tester.pumpWidget(
      componentHost(
        IconTheme(
          data: IconThemeData(color: colors.red),
          child: const InkIcon('x'),
        ),
      ),
    );
    final painter =
        tester.widget<CustomPaint>(find.byType(CustomPaint).last).painter
            as InkArtPainter;
    expect(painter.currentColor, colors.red);
  });

  testWidgets('directional icons flip in right-to-left', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: InkIcon('arrow-right'),
        ),
      ),
    );
    expect(_art(tester).flipX, isTrue);
  });

  testWidgets('is decorative unless labelled', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const InkIcon('bell')));
    expect(find.bySemanticsLabel('Alerts'), findsNothing);
    await tester.pumpWidget(
      componentHost(const InkIcon('bell', semanticLabel: 'Alerts')),
    );
    expect(
      tester.getSemantics(find.byType(InkIcon)),
      matchesSemantics(label: 'Alerts', isImage: true),
    );
    handle.dispose();
  });
}
