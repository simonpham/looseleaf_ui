import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Set<InkState> _states(WidgetTester tester) =>
    tester.widget<InkSurface>(find.byType(InkSurface)).states;

void main() {
  testWidgets('sinks while the pointer is down or when pressed', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const Kbd(child: Text('Esc'))));
    expect(_states(tester), isEmpty);
    final rest = tester.getTopLeft(find.byType(InkSurface));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(Kbd)),
    );
    await tester.pumpAndSettle();
    expect(_states(tester), {InkState.pressed});
    expect(
      tester.getTopLeft(find.byType(InkSurface)),
      rest + const Offset(0, 1.6),
    );
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_states(tester), isEmpty);

    await tester.pumpWidget(
      componentHost(const Kbd(pressed: true, child: Text('Esc'))),
    );
    expect(_states(tester), {InkState.pressed});
  });

  testWidgets('is 24 tall with room for the depth, 20 and flat in calm', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(const Kbd(child: SizedBox())));
    expect(tester.getSize(find.byType(InkSurface)), const Size(24, 24));
    await tester.pumpWidget(
      componentHost(
        const Kbd(child: SizedBox(width: Spacing.d40)),
      ),
    );
    expect(tester.getSize(find.byType(InkSurface)).width, 4 + 40 + 4 + 2.4);
    await tester.pumpWidget(
      componentHost(
        const Kbd(child: SizedBox(width: Spacing.d40)),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(tester.getSize(find.byType(InkSurface)), const Size(48, 20));
  });

  testWidgets('labels are muted graphite and read as text', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(const Kbd(child: Text('K'))));
    final style = DefaultTextStyle.of(tester.element(find.text('K'))).style;
    expect(style.color, const LooseleafColors().inkMuted);
    expect(tester.getSemantics(find.byType(Kbd)), matchesSemantics(label: 'K'));
    handle.dispose();
  });

  testWidgets('a group spaces its keys by 4', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const KbdGroup(
          children: [
            Kbd(child: SizedBox()),
            Kbd(child: SizedBox()),
          ],
        ),
      ),
    );
    final surfaces = find.byType(InkSurface);
    expect(
      tester.getTopLeft(surfaces.last).dx -
          tester.getTopRight(surfaces.first).dx,
      4,
    );
  });
}
