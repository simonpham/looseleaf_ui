import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

const _photo = DropzoneFile(name: 'garden.png', size: 2048, type: 'image/png');
const _big = DropzoneFile(name: 'huge.png', size: 9000000, type: 'image/png');
const _song = DropzoneFile(name: 'song.mp3', size: 4096, type: 'audio/mpeg');
const _pdf = DropzoneFile(name: 'notes.PDF', size: 4096);

class _Harness extends StatefulWidget {
  const _Harness({
    this.picked = const [_photo],
    this.multiple = true,
    this.maxFiles,
    this.disabled = false,
  });

  final List<DropzoneFile> picked;
  final bool multiple;
  final int? maxFiles;
  final bool disabled;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  List<DropzoneFile> files = const [];
  List<DropzoneRejection> rejected = const [];
  int browsed = 0;

  @override
  Widget build(BuildContext context) => FocusScope(
    autofocus: true,
    child: SizedBox(
      width: 320,
      child: SingleChildScrollView(
        child: Dropzone(
          accept: const ['image/*', '.pdf'],
          maxSize: 5 * 1024 * 1024,
          multiple: widget.multiple,
          maxFiles: widget.maxFiles,
          disabled: widget.disabled,
          files: files,
          onFilesChange: (next) => setState(() => files = next),
          onReject: (next) => rejected = next,
          onBrowse: () async {
            browsed++;
            return widget.picked;
          },
        ),
      ),
    ),
  );
}

_HarnessState _state(WidgetTester tester) =>
    tester.state<_HarnessState>(find.byType(_Harness));

void main() {
  testWidgets('tapping the area browses and keeps the picked files', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.tap(find.byType(DropzoneArea));
    await tester.pumpAndSettle();
    expect(_state(tester).browsed, 1);
    expect(_state(tester).files, [_photo]);
    expect(find.text('garden.png'), findsOneWidget);
    expect(find.text('2 KB'), findsOneWidget);
  });

  testWidgets('Enter and Space on the area browse', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(_state(tester).browsed, 2);
  });

  testWidgets('wrong kinds and large files are turned away in red', (
    tester,
  ) async {
    await tester.pumpWidget(
      overlayHost(const _Harness(picked: [_photo, _big, _song, _pdf])),
    );
    await tester.tap(find.byType(DropzoneArea));
    await tester.pumpAndSettle();
    expect(_state(tester).files, [_photo, _pdf]);
    expect(find.text('huge.png is larger than 5 MB.'), findsOneWidget);
    expect(find.text('song.mp3 is not a file type we take.'), findsOneWidget);
    expect(_state(tester).rejected, hasLength(2));
  });

  testWidgets('maxFiles limits the batch', (tester) async {
    await tester.pumpWidget(
      overlayHost(const _Harness(picked: [_photo, _pdf], maxFiles: 1)),
    );
    await tester.tap(find.byType(DropzoneArea));
    await tester.pumpAndSettle();
    expect(_state(tester).files, [_photo]);
    expect(find.text('Only 1 file at a time.'), findsOneWidget);
  });

  testWidgets('a single dropzone keeps one file', (tester) async {
    await tester.pumpWidget(
      overlayHost(const _Harness(picked: [_photo, _pdf], multiple: false)),
    );
    await tester.tap(find.byType(DropzoneArea));
    await tester.pumpAndSettle();
    expect(find.text('One file at a time.'), findsOneWidget);
  });

  testWidgets('the x takes a file back', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness()));
    await tester.tap(find.byType(DropzoneArea));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Remove garden.png'));
    await tester.pumpAndSettle();
    expect(_state(tester).files, isEmpty);
    expect(find.byType(DropzoneItem), findsNothing);
  });

  testWidgets('dragOver shows Stubby carrying a page', (tester) async {
    await tester.pumpWidget(
      overlayHost(const Dropzone(dragOver: true)),
    );
    expect(find.byType(Mascot), findsOneWidget);
    final surface = tester.widget<InkSurface>(
      find.descendant(
        of: find.byType(DropzoneArea),
        matching: find.byType(InkSurface),
      ),
    );
    expect(surface.states, contains(InkState.open));
  });

  testWidgets('minHeight and padding replace the density metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      overlayHost(
        const SizedBox(
          width: 320,
          child: Dropzone(
            child: DropzoneArea(
              minHeight: Spacing.d224,
              padding: Spacing.d16,
              children: [
                SizedBox(
                  key: ValueKey('content'),
                  width: double.infinity,
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(DropzoneArea)).height, Spacing.d224);
    final area = tester.getRect(find.byType(DropzoneArea));
    final content = tester.getRect(find.byKey(const ValueKey('content')));
    expect(content.center.dy, area.center.dy);
    expect(content.left - area.left, Spacing.d16);
  });

  testWidgets('disabled does not browse', (tester) async {
    await tester.pumpWidget(overlayHost(const _Harness(disabled: true)));
    await tester.tap(find.byType(DropzoneArea), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(_state(tester).browsed, 0);
  });

  testWidgets('the area reads as a button, the list is named', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(overlayHost(const _Harness()));
    expect(
      tester.getSemantics(find.byType(DropzoneArea)),
      isSemantics(isButton: true, isFocusable: true, hasTapAction: true),
    );
    await tester.tap(find.byType(DropzoneArea));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Selected files'), findsOneWidget);
    handle.dispose();
  });

  test('formatBytes matches upstream', () {
    expect(formatBytes(512), '512 B');
    expect(formatBytes(1024), '1 KB');
    expect(formatBytes(1536), '1.5 KB');
    expect(formatBytes(12 * 1024 * 1024), '12 MB');
    expect(formatBytes(-1), '0 B');
  });

  test('describeLimits says the limits in words', () {
    expect(
      describeLimits(
        accept: const ['image/*', '.pdf', 'application/zip'],
        maxSize: 2 * 1024 * 1024,
        maxFiles: 4,
      ),
      'Images, PDF, ZIP up to 2 MB each at most 4 files',
    );
    expect(describeLimits(maxFiles: 1), 'At most 1 file');
    expect(describeLimits(maxSize: 1024, multiple: false), 'Up to 1 KB');
  });

  test('matchesAccept reads extensions, types and families', () {
    expect(matchesAccept(_pdf, const ['.pdf']), isTrue);
    expect(matchesAccept(_photo, const ['image/*']), isTrue);
    expect(matchesAccept(_song, const ['image/png, .pdf']), isFalse);
    expect(matchesAccept(_song, const []), isTrue);
  });
}
