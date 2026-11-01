import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Color? _color(WidgetTester tester, String text) =>
    tester.renderObject<RenderParagraph>(find.text(text)).text.style?.color;

Widget _alert(AlertTone tone, {Widget? icon}) => SizedBox(
  width: 400,
  child: Alert(
    variant: tone,
    icon: icon,
    seed: 'alert',
    children: const [
      AlertTitle(Text('Title')),
      AlertDescription(Text('Body')),
    ],
  ),
);

void main() {
  const colors = LooseleafColors();

  testWidgets('is a live region with its text', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(componentHost(_alert(AlertTone.neutral)));
    expect(
      tester.getSemantics(find.byType(Alert)),
      matchesSemantics(label: 'Title\nBody', isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('description and title take the tone colors', (tester) async {
    for (final (tone, title, body) in [
      (AlertTone.neutral, colors.ink, colors.inkMuted),
      (AlertTone.destructive, colors.red, colors.red),
      (AlertTone.note, colors.ink, colors.inkSoft),
    ]) {
      await tester.pumpWidget(componentHost(_alert(tone)));
      expect(_color(tester, 'Title'), title, reason: tone.id);
      expect(_color(tester, 'Body'), body, reason: tone.id);
    }
  });

  testWidgets('the icon is 16 px, tinted by the tone, 12 px from the text', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        _alert(AlertTone.info, icon: const InkIcon('info', seed: 'i')),
      ),
    );
    expect(tester.getSize(find.byType(InkIcon)), const Size(16, 16));
    final icon = tester.getTopLeft(find.byType(InkIcon));
    final alert = tester.getTopLeft(find.byType(Alert));
    expect(icon - alert, const Offset(16, 14));
    expect(
      tester.getTopLeft(find.text('Title')).dx - alert.dx,
      16 + 16 + 12,
    );
    final theme = tester.widget<IconTheme>(
      find
          .ancestor(of: find.byType(InkIcon), matching: find.byType(IconTheme))
          .first,
    );
    expect(theme.data.color, colors.inkYou);
  });

  testWidgets('the icon mark is drawn only with an icon', (tester) async {
    await tester.pumpWidget(componentHost(_alert(AlertTone.success)));
    final bare = tester.widget<InkSurface>(find.byType(InkSurface).first);
    expect((bare.source as AlertInkSource).withIcon, isFalse);
    final markup = bare.source.draw(
      const InkFrameRequest(box: Size(400, 64), seed: 'a'),
    );
    expect(markup.parts['rest'], isNot(contains('icon-mark')));
    final full = AlertInkSource(tone: AlertTone.success, withIcon: true).draw(
      const InkFrameRequest(box: Size(400, 64), seed: 'a'),
    );
    expect(full.parts['rest'], contains('data-part="icon-mark"'));
  });

  testWidgets('padding follows density', (tester) async {
    for (final (density, dx, dy) in [
      (LooseleafDensity.comfortable, 16.0, 12.0),
      (LooseleafDensity.compact, 16.0, 10.0),
      (LooseleafDensity.calm, 12.0, 8.0),
    ]) {
      await tester.pumpWidget(
        componentHost(
          _alert(AlertTone.neutral),
          theme: LooseleafThemeData(density: density),
        ),
      );
      expect(
        tester.getTopLeft(find.text('Title')) -
            tester.getTopLeft(find.byType(Alert)),
        Offset(dx, dy),
        reason: density.name,
      );
    }
  });

  testWidgets('a note is a taped sticky note', (tester) async {
    await tester.pumpWidget(componentHost(_alert(AlertTone.note)));
    final paper = tester.widget<Paper>(find.byType(Paper));
    expect(paper.stock, StockName.stickyYellow);
    expect(paper.tape, PaperTape.corner);
  });

  test('withoutPart drops nested groups', () {
    expect(
      AlertInkSource.withoutPart(
        '<g a="1"><g data-part="icon-mark"><g><path/></g></g><path/></g>',
        'icon-mark',
      ),
      '<g a="1"><path/></g>',
    );
  });
}
