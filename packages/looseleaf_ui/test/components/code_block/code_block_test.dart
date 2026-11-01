import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

const _patch = '''-const shown = notes;
+const shown = picked.size
+  : notes;
 export const count = shown.length;
''';

Widget _host(Widget child) =>
    componentHost(SizedBox(width: Spacing.d256 + Spacing.d128, child: child));

List<String> _clipboard(WidgetTester tester, {bool fail = false}) {
  final copied = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method != 'Clipboard.setData') return null;
      if (fail) throw PlatformException(code: 'denied');
      final args = call.arguments as Map<Object?, Object?>;
      copied.add(args['text'] as String);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return copied;
}

void main() {
  test(
    'a plain model drops one trailing newline and numbers from startLine',
    () {
      final model = CodeBlockModel.build(
        'a\nb\n',
        CodeLang.text,
        diff: false,
        startLine: 7,
      );
      expect(model.text, 'a\nb');
      expect(model.lines.map((line) => line.number), [7, 8]);
      expect(model.stats, isNull);
    },
  );

  test(
    'a diff model skips removed lines when numbering and copies the result',
    () {
      final model = CodeBlockModel.build(_patch, CodeLang.ts, diff: true);
      expect(model.lines.map((line) => line.kind), [
        DiffKind.del,
        DiffKind.add,
        DiffKind.add,
        DiffKind.ctx,
      ]);
      expect(model.lines.map((line) => line.number), [null, 1, 2, 3]);
      expect(
        model.text,
        'const shown = picked.size\n  : notes;\nexport const count = shown.length;',
      );
      expect(model.stats, (added: 2, removed: 1));
      expect(
        model.lines[1].tokens.first,
        const CodeToken(CodeTokenType.keyword, 'const'),
      );
    },
  );

  testWidgets('the title is the file name, else the language', (tester) async {
    await tester.pumpWidget(
      _host(const CodeBlock(code: 'x', filename: 'notes/a.ts')),
    );
    expect(find.text('notes/a.ts'), findsOneWidget);
    await tester.pumpWidget(_host(const CodeBlock(code: 'x', language: 'sh')));
    expect(find.text('bash'), findsOneWidget);
  });

  testWidgets('the block is named by its file, else its language', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(const CodeBlock(code: '{}', language: 'json')),
    );
    expect(find.bySemanticsLabel('json code'), findsOneWidget);
    await tester.pumpWidget(_host(const CodeBlock(code: 'hi')));
    expect(find.bySemanticsLabel('Code'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a diff counts its lines and reads added and removed lines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(const CodeBlock(code: _patch, diff: true, filename: 'f.ts')),
    );
    expect(find.text('+2'), findsOneWidget);
    expect(find.text('-1'), findsOneWidget);
    expect(find.bySemanticsLabel('Added 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Removed 1'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Removed: const shown = notes;'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Added:   : notes;'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('plain code has no counts', (tester) async {
    await tester.pumpWidget(_host(const CodeBlock(code: 'let a = 1')));
    expect(find.byType(CodeBlockStats), findsOneWidget);
    expect(find.text('+0'), findsNothing);
  });

  testWidgets('line numbers follow the model and skip removed lines', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const CodeBlock(code: _patch, diff: true, lineNumbers: true)),
    );
    for (final number in ['1', '2', '3']) {
      expect(find.text(number), findsOneWidget);
    }
    expect(find.text('4'), findsNothing);
  });

  testWidgets('copy puts the code on the clipboard and ticks for a while', (
    tester,
  ) async {
    final copied = _clipboard(tester);
    await tester.pumpWidget(
      _host(
        const CodeBlock(code: _patch, diff: true, seed: 'c'),
      ),
    );
    await tester.tap(find.byType(Button));
    await tester.pump();
    expect(copied, [
      'const shown = picked.size\n  : notes;\nexport const count = shown.length;',
    ]);
    expect(find.text('copied'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is InkIcon && w.name == 'check'),
      findsOneWidget,
    );
    await tester.pump(CodeBlockCopy.settle);
    expect(find.text('copy'), findsOneWidget);
  });

  testWidgets('a refused copy asks for Ctrl+C and says so', (tester) async {
    _clipboard(tester, fail: true);
    final handle = tester.ensureSemantics();
    final results = <bool>[];
    await tester.pumpWidget(
      _host(
        CodeBlock(
          code: 'x',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CodeBlockHeader(
                children: [
                  const CodeBlockTitle(),
                  CodeBlockActions(
                    children: [CodeBlockCopy(onCopied: results.add)],
                  ),
                ],
              ),
              const CodeBlockContent(),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byType(Button));
    await tester.pump();
    expect(find.text('press Ctrl+C'), findsOneWidget);
    expect(results, [false]);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Could not copy')),
      matchesSemantics(label: 'Could not copy', isLiveRegion: true),
    );
    expect(find.bySemanticsLabel('Copy code'), findsOneWidget);
    await tester.pump(CodeBlockCopy.settle);
    handle.dispose();
  });

  testWidgets('the copyable flag drops the button', (tester) async {
    await tester.pumpWidget(
      _host(const CodeBlock(code: 'x', copyable: false)),
    );
    expect(find.byType(CodeBlockCopy), findsNothing);
  });

  testWidgets('the body is a tab stop with a ring and arrow keys scroll it', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      _host(
        CodeBlock(
          code: 'const long = "${'x' * 200}"',
          child: CodeBlockContent(focusNode: focusNode),
        ),
      ),
    );
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    focusNode.requestFocus();
    await tester.pump();
    final body = find.descendant(
      of: find.byType(CodeBlockContent),
      matching: find.byType(InkSurface),
    );
    expect(tester.widget<InkSurface>(body).states, {InkState.focused});
    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.pixels, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(scrollable.position.pixels, Spacing.d40);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(scrollable.position.pixels, 0);
  });

  testWidgets('wrap wraps long lines instead of scrolling', (tester) async {
    await tester.pumpWidget(
      _host(
        CodeBlock(code: 'echo ${'word ' * 60}', language: 'bash', wrap: true),
      ),
    );
    expect(find.byType(Scrollable), findsNothing);
    final line = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byType(CodeBlockLineView),
        matching: find.byType(RichText),
      ),
    );
    expect(line.size.height, greaterThan(Spacing.d40));
  });

  testWidgets('code is IBM Plex Mono at 13.5 / 1.7, 13 / 1.6 when calm', (
    tester,
  ) async {
    for (final (density, size, height) in [
      (LooseleafDensity.comfortable, 13.5, 1.7),
      (LooseleafDensity.calm, 13.0, 1.6),
    ]) {
      await tester.pumpWidget(
        componentHost(
          const SizedBox(
            width: Spacing.d256,
            child: CodeBlock(code: 'x'),
          ),
          theme: LooseleafThemeData(density: density),
        ),
      );
      final style = DefaultTextStyle.of(
        tester.element(find.byType(CodeBlockLineView)),
      ).style;
      expect(style.fontFamily, 'packages/looseleaf_ui/IBMPlexMono');
      expect(style.fontSize, size);
      expect(style.height, height);
    }
  });

  testWidgets('tokens take the tone colours', (tester) async {
    await tester.pumpWidget(
      _host(const CodeBlock(code: 'const a', language: 'ts')),
    );
    final text = tester
        .renderObject<RenderParagraph>(
          find.descendant(
            of: find.byType(CodeBlockLineView),
            matching: find.byType(RichText),
          ),
        )
        .text;
    final spans = <TextSpan>[];
    text.visitChildren((span) {
      if (span is TextSpan && span.text != null) spans.add(span);
      return true;
    });
    final keyword = spans.firstWhere((span) => span.text == 'const');
    expect(
      keyword.style?.color,
      CodeBlockTone.dark.token(CodeTokenType.keyword, const LooseleafColors()),
    );
  });

  testWidgets('content can show its own code', (tester) async {
    await tester.pumpWidget(
      _host(
        const CodeBlock(
          code: 'block',
          child: CodeBlockContent(code: '{"a": 1}', language: 'json'),
        ),
      ),
    );
    expect(find.text('block'), findsNothing);
    expect(find.byType(CodeBlockLineView), findsOneWidget);
  });

  testWidgets('parts throw outside a code block', (tester) async {
    await tester.pumpWidget(componentHost(const CodeBlockStats()));
    expect(tester.takeException(), isA<FlutterError>());
  });
}
