import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _item({
  ItemVariant variant = ItemVariant.regular,
  ItemSize size = ItemSize.regular,
  VoidCallback? onPressed,
  FocusNode? focusNode,
  bool description = true,
}) => SizedBox(
  width: 420,
  child: InkItem(
    variant: variant,
    size: size,
    seed: 'item',
    onPressed: onPressed,
    focusNode: focusNode,
    children: [
      const ItemMedia(
        variant: ItemMediaVariant.icon,
        child: SizedBox.square(dimension: Spacing.d16),
      ),
      ItemContent(
        children: [
          const ItemTitle(Text('Profile')),
          if (description) const ItemDescription(Text('Your pencil case.')),
        ],
      ),
      const ItemActions(children: [SizedBox(width: 40, height: 28)]),
    ],
  ),
);

void main() {
  testWidgets('padding and gaps follow the size and density', (tester) async {
    for (final (size, density, pad, gap) in [
      (ItemSize.regular, LooseleafDensity.comfortable, 16.0, 16.0),
      (ItemSize.regular, LooseleafDensity.compact, 12.0, 16.0),
      (ItemSize.regular, LooseleafDensity.calm, 10.0, 16.0),
      (ItemSize.sm, LooseleafDensity.comfortable, 16.0, 10.0),
      (ItemSize.sm, LooseleafDensity.compact, 12.0, 10.0),
    ]) {
      await tester.pumpWidget(
        componentHost(
          _item(size: size, description: false),
          theme: LooseleafThemeData(density: density),
        ),
      );
      final item = tester.getTopLeft(find.byType(InkItem));
      final media = tester.getTopLeft(find.byType(ItemMedia));
      expect(media.dx - item.dx, pad, reason: '${size.name} ${density.name}');
      expect(
        tester.getTopLeft(find.text('Profile')).dx -
            tester.getTopRight(find.byType(ItemMedia)).dx,
        gap,
      );
    }
  });

  testWidgets('content takes the room left; actions sit at the end', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_item()));
    expect(
      tester.getTopRight(find.byType(ItemActions)).dx,
      tester.getTopRight(find.byType(InkItem)).dx - 16,
    );
    expect(tester.getSize(find.byType(ItemMedia)), const Size(36, 38));
  });

  testWidgets('media moves to the top when there is a description', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_item()));
    final item = tester.getTopLeft(find.byType(InkItem));
    expect(tester.getTopLeft(find.byType(ItemMedia)).dy - item.dy, 16);
    final box = find.descendant(
      of: find.byType(ItemMedia),
      matching: find.byType(ColoredBox),
    );
    expect(tester.getTopLeft(box).dy - item.dy, 18);
    await tester.pumpWidget(componentHost(_item(description: false)));
    final row = tester.getCenter(find.byType(InkItem)).dy;
    expect(tester.getCenter(find.byType(ItemMedia)).dy, row);
  });

  testWidgets('a description is muted and clamped to two lines', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_item()));
    final paragraph = tester.renderObject<RenderParagraph>(
      find.text('Your pencil case.'),
    );
    expect(paragraph.maxLines, 2);
    expect(paragraph.text.style?.color, const LooseleafColors().inkMuted);
  });

  testWidgets('a link row activates on tap and keys, hovers into a swipe', (
    tester,
  ) async {
    var presses = 0;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      componentHost(_item(onPressed: () => presses++, focusNode: focus)),
    );
    await tester.tap(find.byType(InkItem));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(presses, 3);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: tester.getCenter(find.byType(InkItem)));
    await tester.pump();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            (widget.decoration as BoxDecoration).color ==
                const LooseleafColors().hiSelect,
      ),
      findsOneWidget,
    );
    await mouse.removePointer();
  });

  testWidgets('in a group, rows are list items and ruled rows get rules', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        SizedBox(
          width: 400,
          child: ItemGroup(
            ruled: true,
            children: [
              _item(),
              const ItemSeparator(seed: 's'),
              _item(),
            ],
          ),
        ),
      ),
    );
    final rules = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((paint) => paint.painter)
        .whereType<ItemPainter>()
        .map((painter) => painter.kind)
        .toList();
    expect(rules.where((kind) => kind == ItemPaint.rule), hasLength(2));
    expect(rules.where((kind) => kind == ItemPaint.separator), hasLength(1));
    expect(
      tester.getSemantics(find.byType(InkItem).first).role,
      SemanticsRole.listItem,
    );
    expect(tester.getSize(find.byType(ItemSeparator)).height, 1);
    handle.dispose();
  });

  testWidgets('other separator looks draw a Separator', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 200,
          child: ItemSeparator(variant: SeparatorVariant.dashed),
        ),
      ),
    );
    expect(find.byType(Separator), findsOneWidget);
  });

  test('frames are picked by seed', () {
    expect(ItemFrame.all, hasLength(3));
    expect(ItemFrame.of('a'), same(ItemFrame.of('a')));
  });
}
