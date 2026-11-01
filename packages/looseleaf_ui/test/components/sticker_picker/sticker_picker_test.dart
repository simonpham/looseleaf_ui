import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

const _small = [
  StickerPickerInput('rocket'),
  StickerPickerInput('done', label: 'All done', tags: ['finished']),
  StickerPickerInput('sun-shades'),
  StickerPickerInput('cloud-smile', category: 'skies'),
  StickerPickerInput('not-a-sticker'),
];

Widget _picker({
  required List<StickerPickerItem> chosen,
  List<StickerPickerInput>? stickers = _small,
  List<String> recent = const [],
  bool closeOnSelect = true,
  ValueChanged<bool>? onOpenChange,
}) => overlayHost(
  Align(
    alignment: Alignment.topLeft,
    child: StickerPicker(
      stickers: stickers,
      recent: recent,
      closeOnSelect: closeOnSelect,
      onSelect: chosen.add,
      onOpenChange: onOpenChange,
      value: 'rocket',
      content: const StickerPickerContent(columns: 2),
      child: const StickerPickerTrigger(child: Text('Add sticker')),
    ),
  ),
);

String? _footer(WidgetTester tester) {
  final texts = tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(StickerPickerContent),
          matching: find.byType(Text),
        ),
      )
      .map((t) => t.data)
      .toList();
  return texts[texts.length - 2];
}

void main() {
  test('catalogFrom keeps known stickers and applies overrides', () {
    final items = StickerPickerInput.catalogFrom(_small);
    expect(
      [for (final e in items) e.name],
      [
        'rocket',
        'done',
        'sun-shades',
        'cloud-smile',
      ],
    );
    expect(items[1].label, 'All done');
    expect(items[1].tags, contains('finished'));
    expect(items[3].category, 'skies');
    expect(items[3].categoryLabel, 'Skies');
  });

  test('neighbour walks the grid across sections', () {
    final a = StickerPickerSection(
      key: 'a',
      label: 'A',
      items: StickerPickerInput.catalogFrom(_small).take(3).toList(),
    );
    final b = StickerPickerSection(
      key: 'b',
      label: 'B',
      items: StickerPickerInput.catalogFrom(_small).take(2).toList(),
    );
    final sections = [a, b];
    expect(
      StickerPickerSection.neighbour(
        sections,
        (0, 1),
        LogicalKeyboardKey.arrowDown,
        2,
      ),
      (1, 1),
    );
    expect(
      StickerPickerSection.neighbour(
        sections,
        (1, 0),
        LogicalKeyboardKey.arrowUp,
        2,
      ),
      (0, 2),
    );
    expect(
      StickerPickerSection.neighbour(
        sections,
        (0, 2),
        LogicalKeyboardKey.arrowRight,
        2,
      ),
      (1, 0),
    );
    expect(
      StickerPickerSection.neighbour(
        sections,
        (1, 1),
        LogicalKeyboardKey.arrowRight,
        2,
      ),
      isNull,
    );
  });

  testWidgets('opens from the trigger with the field focused', (tester) async {
    await tester.pumpWidget(_picker(chosen: []));
    expect(find.byType(StickerPickerContent), findsNothing);
    await tester.tap(find.text('Add sticker'));
    await tester.pumpAndSettle();
    expect(find.byType(StickerPickerContent), findsOneWidget);
    expect(find.byType(StickerPickerOption), findsNWidgets(4));
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.focusNode.hasFocus, isTrue);
    expect(_footer(tester), 'Rocket');
  });

  testWidgets('arrows move the active sticker and Enter chooses it', (
    tester,
  ) async {
    final chosen = <StickerPickerItem>[];
    final opens = <bool>[];
    await tester.pumpWidget(_picker(chosen: chosen, onOpenChange: opens.add));
    await tester.tap(find.text('Add sticker'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_footer(tester), 'Sun shades');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_footer(tester), 'All done');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(_footer(tester), 'Cloud smile');
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(_footer(tester), 'Rocket');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(chosen.single.name, 'rocket');
    expect(opens.last, isFalse);
    expect(find.byType(StickerPickerContent), findsNothing);
  });

  testWidgets('typing filters by label and tags', (tester) async {
    await tester.pumpWidget(_picker(chosen: []));
    await tester.tap(find.text('Add sticker'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'finished');
    await tester.pumpAndSettle();
    expect(find.byType(StickerPickerOption), findsOneWidget);
    expect(find.text('1 found'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), 'nothing here');
    await tester.pumpAndSettle();
    expect(find.byType(StickerPickerOption), findsNothing);
    expect(find.text('Nothing looks like “nothing here”.'), findsOneWidget);
  });

  testWidgets('a batch filter narrows the list', (tester) async {
    await tester.pumpWidget(_picker(chosen: []));
    await tester.tap(find.text('Add sticker'));
    await tester.pumpAndSettle();
    final skies = find.widgetWithText(StickerPickerCategory, 'Skies');
    await tester.ensureVisible(skies);
    await tester.pumpAndSettle();
    await tester.tap(skies);
    await tester.pumpAndSettle();
    expect(find.byType(StickerPickerOption), findsOneWidget);
  });

  testWidgets('recent stickers come first; a click chooses and can stay open', (
    tester,
  ) async {
    final chosen = <StickerPickerItem>[];
    await tester.pumpWidget(
      _picker(
        chosen: chosen,
        recent: const ['sun-shades'],
        closeOnSelect: false,
      ),
    );
    await tester.tap(find.text('Add sticker'));
    await tester.pumpAndSettle();
    expect(find.text('Recent'), findsOneWidget);
    expect(_footer(tester), 'Sun shades');
    await tester.tap(find.byKey(const ValueKey('statusPointers:done')));
    await tester.pumpAndSettle();
    expect(chosen.single.label, 'All done');
    expect(find.byType(StickerPickerContent), findsOneWidget);
  });

  testWidgets('options say their name and whether they are chosen', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_picker(chosen: []));
    await tester.tap(find.text('Add sticker'));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byKey(const ValueKey('spaceWeather:rocket'))),
      matchesSemantics(
        label: 'Rocket',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
