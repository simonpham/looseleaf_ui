import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';

Widget _page(Widget child) => RepaintBoundary(
  child: Paper(
    stock: StockName.dotGrid,
    tilt: false,
    shadow: PaperShadow.none,
    seed: 'page',
    padding: const EdgeInsets.all(Spacing.d40),
    child: child,
  ),
);

Widget _slip(
  AttachmentState state,
  String icon,
  String title,
  String description, {
  double? progress,
  bool progressBar = false,
  String? action,
  AttachmentSize size = AttachmentSize.regular,
}) => Attachment(
  state: state,
  size: size,
  seed: '${state.name}-${size.id}',
  children: [
    AttachmentMedia(child: InkIcon(icon)),
    AttachmentContent(
      children: [
        AttachmentTitle(child: Text(title)),
        AttachmentDescription(child: Text(description)),
        if (progressBar) AttachmentProgress(value: progress),
      ],
    ),
    if (action case final name?)
      AttachmentActions(
        children: [
          AttachmentAction(
            semanticLabel: name,
            onPressed: () {},
            seed: '${state.name}-action',
            child: InkIcon(name),
          ),
        ],
      ),
  ],
);

Widget _states() => SizedBox(
  width: 300,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d24,
    children: [
      _slip(
        AttachmentState.done,
        'file-text',
        'field-notes.pdf',
        '2.4 MB · pdf',
        action: 'x',
      ),
      _slip(
        AttachmentState.uploading,
        'file-code',
        'tags-list.tsx',
        'Uploading 42 %',
        progress: 42,
        progressBar: true,
        action: 'x',
      ),
      _slip(
        AttachmentState.processing,
        'file',
        'recipes.csv',
        'Reading the rows',
        progressBar: true,
      ),
      _slip(
        AttachmentState.error,
        'archive',
        'holiday-photos.zip',
        'Too large. Max 25 MB',
        action: 'rotate-cw',
      ),
      _slip(AttachmentState.idle, 'upload', 'Add a file', 'or drop it here'),
    ],
  ),
);

Widget _sizes() => Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: Spacing.d24,
  children: [
    for (final size in AttachmentSize.values)
      _slip(
        AttachmentState.done,
        'file-text',
        'notes-${size.id}.md',
        '12 KB',
        size: size,
      ),
    Attachment(
      seed: 'hover',
      forcedStates: const {InkState.hovered},
      children: [
        const AttachmentMedia(child: InkIcon('file-text')),
        const AttachmentContent(
          children: [
            AttachmentTitle(child: Text('hovered.pdf')),
            AttachmentDescription(child: Text('pressable')),
          ],
        ),
        AttachmentTrigger(onPressed: () {}),
      ],
    ),
  ],
);

const _prints = [
  ('harbour.jpg', '1.8 MB', 'sun'),
  ('sketch-04.png', '620 KB', 'flower'),
  ('mushrooms.jpg', '2.1 MB', 'mushroom'),
];

Widget _printsRow() => Builder(
  builder: (context) {
    final colors = LooseleafTheme.of(context).colors;
    final tints = [
      colors.sky.withValues(alpha: 0.45),
      colors.lemon.withValues(alpha: 0.5),
      colors.bubblegum.withValues(alpha: 0.4),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: [
        for (final (i, (name, size, doodle)) in _prints.indexed)
          Attachment(
            orientation: AttachmentOrientation.vertical,
            seed: name,
            children: [
              AttachmentMedia(
                variant: AttachmentMediaVariant.image,
                color: tints[i],
                child: Doodle(doodle, size: 64, seed: name),
              ),
              AttachmentContent(
                children: [
                  AttachmentTitle(child: Text(name)),
                  AttachmentDescription(child: Text(size)),
                ],
              ),
              AttachmentTrigger(onPressed: () {}),
              AttachmentActions(
                children: [
                  AttachmentAction(
                    onPressed: () {},
                    seed: '$name-x',
                    child: const InkIcon('x'),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  },
);

Future<void> _golden(WidgetTester tester, Widget child, String name) async {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(componentHost(_page(child)));
  await tester.pump();
  await expectLater(
    find.byType(RepaintBoundary).first,
    matchesGoldenFile('../goldens/attachment-$name.png'),
  );
}

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets(
    'attachment states',
    (tester) => _golden(tester, _states(), 'states'),
  );
  testWidgets(
    'attachment sizes',
    (tester) => _golden(tester, _sizes(), 'sizes'),
  );
  testWidgets(
    'attachment prints',
    (tester) => _golden(tester, _printsRow(), 'prints'),
  );
}
