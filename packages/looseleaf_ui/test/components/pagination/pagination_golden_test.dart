import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('pagination-default in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1400, 240);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Pagination(
            child: PaginationContent(
              children: [
                PaginationPrevious(onPressed: () {}, seed: 'prev'),
                for (final number in [1, 2, 3])
                  PaginationLink(
                    isActive: number == 2,
                    seed: 'p$number',
                    onPressed: () {},
                    child: Text('$number'),
                  ),
                const PaginationEllipsis(),
                PaginationNext(onPressed: () {}, seed: 'next'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/pagination-default.png'),
    );
  });
}
