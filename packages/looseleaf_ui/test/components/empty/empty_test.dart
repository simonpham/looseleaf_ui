import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

void main() {
  const colors = LooseleafColors();

  testWidgets('stacks its parts centered with the upstream gaps', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const Empty(
          children: [
            EmptyHeader(
              children: [
                EmptyTitle(child: Text('No projects yet')),
                EmptyDescription(child: Text('Create your first one.')),
              ],
            ),
            EmptyContent(children: [SizedBox(width: 40, height: 20)]),
          ],
        ),
      ),
    );
    final title = tester.getRect(find.text('No projects yet'));
    final description = tester.getRect(find.text('Create your first one.'));
    expect(description.top - title.bottom, closeTo(8, 0.01));
    expect(title.center.dx, closeTo(400, 0.01));
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('No projects yet'))
          .textAlign,
      TextAlign.center,
    );
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('Create your first one.'))
          .text
          .style
          ?.color,
      colors.inkMuted,
    );
  });

  testWidgets('pads 24, and 48 from the md breakpoint', (tester) async {
    tester.view.physicalSize = const Size(600, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(const Empty(children: [SizedBox(width: 10, height: 10)])),
    );
    expect(tester.getSize(find.byType(Empty)), const Size(58, 58));
    tester.view.physicalSize = const Size(900, 600);
    await tester.pumpWidget(
      componentHost(const Empty(children: [SizedBox(width: 10, height: 10)])),
    );
    expect(tester.getSize(find.byType(Empty)), const Size(106, 106));
  });

  testWidgets('framed draws the pencil frame', (tester) async {
    await tester.pumpWidget(
      componentHost(const Empty(children: [Text('x')])),
    );
    expect(find.byType(InkSurface), findsNothing);
    await tester.pumpWidget(
      componentHost(const Empty(framed: true, children: [Text('x')])),
    );
    expect(
      tester.widget<InkSurface>(find.byType(InkSurface)).source.id,
      startsWith('empty-frame'),
    );
  });

  testWidgets('the icon media is a 44 slip with 24 icons', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const EmptyMedia(
          variant: EmptyMediaVariant.icon,
          child: InkIcon('folder-plus'),
        ),
      ),
    );
    expect(tester.getSize(find.byType(InkSurface)), const Size(44, 44));
    expect(tester.getSize(find.byType(InkIcon)), const Size(24, 24));
  });

  testWidgets('the title is a header; media is decorative', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyMedia(doodle: 'cloud'),
            EmptyTitle(child: Text('All quiet')),
          ],
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('All quiet')),
      matchesSemantics(label: 'All quiet', isHeader: true),
    );
    handle.dispose();
  });
}
