import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

SeparatorParams _params(WidgetTester tester, Finder finder) {
  final surface = tester.widget<InkSurface>(
    find.descendant(of: finder, matching: find.byType(InkSurface)),
  );
  return (surface.source as RecipeInkSource<SeparatorParams>).params;
}

void main() {
  testWidgets('a horizontal rule is a pixel tall and fills the width', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(const SizedBox(width: 200, child: Separator(seed: 's'))),
    );
    expect(tester.getSize(find.byType(SeparatorRule)), const Size(200, 1));
    final params = _params(tester, find.byType(Separator));
    expect(params.variant, SeparatorVariant.pencil);
    expect(params.orientation, SeparatorOrientation.horizontal);
  });

  testWidgets('a vertical rule is a pixel wide and fills the height', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          height: 40,
          child: Separator(
            orientation: SeparatorOrientation.vertical,
            variant: SeparatorVariant.wavy,
            seed: 's',
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(SeparatorRule)), const Size(1, 40));
    expect(
      _params(tester, find.byType(Separator)).orientation,
      SeparatorOrientation.vertical,
    );
  });

  testWidgets('a label sits between two rules seeded a and b', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: Separator(seed: 'x', child: Text('or')),
        ),
      ),
    );
    final rules = tester
        .widgetList<SeparatorRule>(find.byType(SeparatorRule))
        .toList();
    expect(rules.map((rule) => rule.seed), ['x:a', 'x:b']);
    final left = tester.getRect(find.byType(SeparatorRule).first);
    final label = tester.getRect(find.text('or'));
    expect(label.left - left.right, Spacing.d12);
  });

  testWidgets('decorative rules are hidden; the label is read', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 300,
          child: Separator(seed: 'x', child: Text('or')),
        ),
      ),
    );
    expect(find.bySemanticsLabel('or'), findsOneWidget);
    handle.dispose();
  });
}
