import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  testWidgets('sets the layout and the ink direction together', (
    tester,
  ) async {
    late BuildContext inner;
    await tester.pumpWidget(
      componentHost(
        DirectionProvider(
          direction: TextDirection.rtl,
          child: Builder(
            builder: (context) {
              inner = context;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(Directionality.of(inner), TextDirection.rtl);
    expect(LooseleafTheme.of(inner).textDirection, TextDirection.rtl);
    expect(DirectionProvider.of(inner), TextDirection.rtl);
    expect(DirectionProvider.of(inner, TextDirection.ltr), TextDirection.ltr);
  });

  testWidgets('without a direction it hands the ambient one to the ink', (
    tester,
  ) async {
    late BuildContext inner;
    await tester.pumpWidget(
      componentHost(
        Directionality(
          textDirection: TextDirection.rtl,
          child: DirectionProvider(
            child: Builder(
              builder: (context) {
                inner = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    expect(LooseleafTheme.of(inner).textDirection, TextDirection.rtl);
  });

  testWidgets('drawings below draw right to left', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const DirectionProvider(
          direction: TextDirection.rtl,
          child: Badge(child: Text('RTL')),
        ),
      ),
    );
    final surface = tester.element(find.byType(InkSurface));
    expect(LooseleafTheme.of(surface).textDirection, TextDirection.rtl);
  });
}
