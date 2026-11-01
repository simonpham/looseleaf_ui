import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import '../../support/paper_panel.dart';

ToastData _toast(int id, ToastType type, String title, String? description) =>
    ToastData(
      id: 'golden-$id',
      type: type,
      title: title,
      description: description,
    );

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('sonner-types in the light theme', (tester) async {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
        paperPanel(
          SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d24,
              children: [
                for (final (index, (type, title, description)) in [
                  (ToastType.normal, 'Event created', 'Saturday, 10:00 am'),
                  (
                    ToastType.success,
                    'Notebook saved',
                    'All 48 pages are safe.',
                  ),
                  (ToastType.error, 'Could not sync', 'You are offline.'),
                  (
                    ToastType.warning,
                    'Storage almost full',
                    '92% of 1 GB used.',
                  ),
                  (ToastType.info, 'A new version is ready', null),
                  (ToastType.loading, 'Uploading photo…', 'IMG_2043.jpg'),
                ].indexed)
                  ToastCard(
                    toast: _toast(index, type, title, description),
                    onClose: () {},
                    closeButton: index == 0,
                  ),
                ToastCard(
                  toast: ToastData(
                    id: 'undo',
                    title: 'Note deleted',
                    description: '"Tea, two cups."',
                    action: ToastButton(label: 'Undo', onPressed: () {}),
                    cancel: ToastButton(label: 'Dismiss', onPressed: () {}),
                  ),
                  onClose: () {},
                  decoration: ToastDecoration.tape,
                ),
                ToastCard(
                  toast: _toast(
                    9,
                    ToastType.info,
                    'Pinned up',
                    'With a red pin.',
                  ),
                  onClose: () {},
                  decoration: ToastDecoration.pin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../goldens/sonner-types.png'),
    );
  });
}
