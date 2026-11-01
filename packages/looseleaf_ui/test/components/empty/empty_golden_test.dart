import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _projects() => Empty(
  seed: 'no-projects',
  children: [
    const EmptyHeader(
      children: [
        EmptyMedia(
          variant: EmptyMediaVariant.icon,
          seed: 'tile',
          child: InkIcon('folder-plus'),
        ),
        EmptyTitle(child: Text('No projects yet')),
        EmptyDescription(
          child: Text(
            'You have not created any projects yet. Get started by creating '
            'your first project.',
          ),
        ),
      ],
    ),
    EmptyContent(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d8,
          children: [
            Button(
              seed: 'create',
              onPressed: () {},
              child: const Text('Create project'),
            ),
            Button(
              variant: ButtonVariant.outline,
              seed: 'import',
              onPressed: () {},
              child: const Text('Import project'),
            ),
          ],
        ),
      ],
    ),
  ],
);

Widget _stubby(String pose, String title, String text) => SizedBox(
  width: 260,
  child: Empty(
    framed: true,
    seed: pose,
    padding: const EdgeInsets.all(Spacing.d16),
    children: [
      EmptyHeader(
        children: [
          EmptyMedia(pose: pose, size: 112, seed: pose),
          EmptyTitle(child: Text(title)),
          EmptyDescription(child: Text(text)),
        ],
      ),
    ],
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('empty-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1800, 1500);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        RepaintBoundary(
          child: ColoredBox(
            color: const LooseleafThemeData().colors.paper,
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d16,
                children: [
                  _projects(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Spacing.d8,
                    children: [
                      _stubby(
                        'search',
                        'No results',
                        'Nothing matches “ghost pepper”. Try a shorter word.',
                      ),
                      _stubby(
                        'sleep',
                        'All quiet',
                        'Nothing is scheduled today.',
                      ),
                      _stubby(
                        'unplug',
                        'You are offline',
                        'Changes are sent when the line is back.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/empty-states.png'),
    );
  });
}
