import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

Widget _slip({
  AttachmentState state = AttachmentState.done,
  AttachmentSize size = AttachmentSize.regular,
  List<Widget> extra = const [],
  List<Widget> content = const [],
}) => Attachment(
  state: state,
  size: size,
  seed: 's',
  children: [
    const AttachmentMedia(child: SizedBox.square(dimension: 16)),
    AttachmentContent(
      children: [
        const AttachmentTitle(child: Text('notes.pdf')),
        const AttachmentDescription(child: Text('2 MB')),
        ...content,
      ],
    ),
    ...extra,
  ],
);

RecipeInkSource _source(WidgetTester tester) => tester
    .widgetList<InkSurface>(find.byType(InkSurface))
    .map((surface) => surface.source)
    .whereType<RecipeInkSource>()
    .firstWhere((source) => source.params is AttachmentParams);

void main() {
  testWidgets('a done slip is clipped and on paper', (tester) async {
    await tester.pumpWidget(componentHost(_slip()));
    final params = _source(tester).params as AttachmentParams;
    expect(params.state, AttachmentState.done);
    expect(find.byType(PaperBackground), findsOneWidget);
    expect(
      tester.widget<PaperFastener>(find.byType(PaperFastener)).kind,
      FastenerKind.clip,
    );
  });

  testWidgets('an idle slot has no sheet, small sizes no clip', (
    tester,
  ) async {
    await tester.pumpWidget(componentHost(_slip(state: AttachmentState.idle)));
    expect(find.byType(PaperBackground), findsNothing);
    expect(find.byType(PaperFastener), findsNothing);
    await tester.pumpWidget(componentHost(_slip(size: AttachmentSize.sm)));
    expect(find.byType(PaperFastener), findsNothing);
  });

  testWidgets('calm density hides the clip', (tester) async {
    await tester.pumpWidget(
      componentHost(
        _slip(),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    expect(find.byType(PaperFastener), findsNothing);
  });

  testWidgets('sizes set the padding and the media', (tester) async {
    for (final (size, media, padding) in const [
      (AttachmentSize.regular, 40.0, (10.0, 8.0)),
      (AttachmentSize.sm, 32.0, (8.0, 6.0)),
      (AttachmentSize.xs, 28.0, (6.0, 4.0)),
    ]) {
      await tester.pumpWidget(componentHost(_slip(size: size)));
      expect(tester.getSize(find.byType(AttachmentMedia)), Size.square(media));
      final card = tester.getTopLeft(find.byType(InkSurface).first);
      final offset = tester.getTopLeft(find.byType(AttachmentMedia)) - card;
      expect(offset.dx, padding.$1);
    }
  });

  testWidgets('is at least 160 px wide and fits its content', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Attachment(
          children: [AttachmentMedia(child: SizedBox.square(dimension: 16))],
        ),
      ),
    );
    expect(tester.getSize(find.byType(Attachment)).width, 160);
  });

  testWidgets('long names are cut to one line', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const SizedBox(
          width: 200,
          child: Attachment(
            children: [
              AttachmentContent(
                children: [
                  AttachmentTitle(
                    child: Text('a-very-long-file-name-for-a-small-slip.pdf'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final text = tester.widget<DefaultTextStyle>(
      find
          .ancestor(
            of: find.textContaining('a-very-long'),
            matching: find.byType(DefaultTextStyle),
          )
          .first,
    );
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
  });

  testWidgets('a trigger makes the slip a button', (tester) async {
    var opened = 0;
    var removed = 0;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      componentHost(
        _slip(
          extra: [
            AttachmentTrigger(
              semanticLabel: 'Open notes.pdf',
              focusNode: focus,
              onPressed: () => opened++,
            ),
            AttachmentActions(
              children: [
                AttachmentAction(
                  semanticLabel: 'Remove',
                  onPressed: () => removed++,
                  child: const SizedBox.square(dimension: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('notes.pdf'));
    expect(opened, 1);
    await tester.tap(find.byType(AttachmentAction));
    expect((opened, removed), (1, 1));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(opened, 2);
    final surface = tester.widget<InkSurface>(
      find.byWidgetPredicate(
        (widget) =>
            widget is InkSurface &&
            widget.source is RecipeInkSource &&
            (widget.source as RecipeInkSource).params is AttachmentParams,
      ),
    );
    expect(surface.states, contains(InkState.focused));
    expect(
      find.bySemanticsLabel('Open notes.pdf'),
      findsOneWidget,
    );
  });

  testWidgets('progress clips the drawn bar and reports its value', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        _slip(
          state: AttachmentState.uploading,
          content: const [
            AttachmentProgress(value: 42, semanticLabel: 'Upload progress'),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Upload progress')),
      matchesSemantics(
        label: 'Upload progress',
        value: '42',
        maxValue: '100',
        minValue: '0',
      ),
    );
    final bar = tester.getRect(find.byType(AttachmentProgress));
    expect(bar.height, 6 + 10);
    final clip = tester
        .renderObject<RenderClipRect>(
          find.descendant(
            of: find.byType(AttachmentProgress),
            matching: find.byType(ClipRect),
          ),
        )
        .clipper
        ?.getClip(Size(bar.width, 10));
    expect(clip?.right, closeTo(bar.width * 0.42, 0.01));
  });

  testWidgets('the title breathes while uploading', (tester) async {
    await tester.pumpWidget(
      componentHost(_slip(state: AttachmentState.uploading)),
    );
    await tester.pump(const Duration(milliseconds: 500));
    final fade = tester.widget<FadeTransition>(
      find.ancestor(
        of: find.text('notes.pdf'),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fade.opacity.value, lessThan(1));
    await tester.pumpWidget(componentHost(_slip()));
    final still = tester.widget<FadeTransition>(
      find.ancestor(
        of: find.text('notes.pdf'),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(still.opacity.value, 1);
  });

  testWidgets('errors color the description red', (tester) async {
    await tester.pumpWidget(componentHost(_slip(state: AttachmentState.error)));
    final style = tester.widget<RichText>(find.byType(RichText).last);
    expect(style.text.style?.color, const LooseleafThemeData().colors.red);
  });

  testWidgets('a print is 128 px wide with tape and its actions on top', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        Attachment(
          orientation: AttachmentOrientation.vertical,
          children: [
            const AttachmentMedia(
              variant: AttachmentMediaVariant.image,
              child: SizedBox.square(dimension: 64),
            ),
            const AttachmentContent(
              children: [AttachmentTitle(child: Text('harbour.jpg'))],
            ),
            AttachmentActions(
              children: [
                AttachmentAction(
                  onPressed: () {},
                  child: const SizedBox.square(dimension: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    expect(tester.getSize(find.byType(Attachment)).width, 128);
    expect(find.byType(Tape), findsOneWidget);
    final card = tester.getRect(find.byType(Attachment));
    final actions = tester.getRect(find.byType(AttachmentActions));
    expect(actions.top - card.top, 8);
    expect(card.right - actions.right, 8);
    expect(tester.getSize(find.byType(AttachmentMedia)).width, 128 - 20);
  });
}
