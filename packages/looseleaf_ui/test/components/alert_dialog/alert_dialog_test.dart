import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

const Key _cancel = Key('cancel');

Widget _alert({
  AlertDialogSize size = AlertDialogSize.regular,
  AlertDialogTone tone = AlertDialogTone.neutral,
  VoidCallback? onAction,
  VoidCallback? onCancel,
  ValueChanged<bool>? onOpenChange,
  FocusNode? cancel,
}) => AlertDialog(
  onOpenChange: onOpenChange,
  content: AlertDialogContent(
    size: size,
    tone: tone,
    seed: 'a',
    children: [
      const AlertDialogHeader(
        children: [
          AlertDialogMedia(child: InkIcon('trash')),
          AlertDialogTitle(Text('Delete this notebook?')),
          AlertDialogDescription(Text('You cannot undo this.')),
        ],
      ),
      AlertDialogFooter(
        children: [
          AlertDialogCancel(
            key: _cancel,
            focusNode: cancel,
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
          AlertDialogAction(
            variant: ButtonVariant.destructive,
            onPressed: onAction,
            child: const Text('Delete'),
          ),
        ],
      ),
    ],
  ),
  child: AlertDialogTrigger.builder(
    builder: (context, dialog) =>
        Button(onPressed: dialog.show, child: const Text('Open')),
  ),
);

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the answers call back and close it', (tester) async {
    final calls = <String>[];
    final changes = <bool>[];
    await tester.pumpWidget(
      overlayHost(
        _alert(
          onAction: () => calls.add('action'),
          onCancel: () => calls.add('cancel'),
          onOpenChange: changes.add,
        ),
      ),
    );
    await _open(tester);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this notebook?'), findsNothing);
    await _open(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this notebook?'), findsNothing);
    expect(calls, ['action', 'cancel']);
    expect(changes, [true, false, true, false]);
  });

  testWidgets('focus starts on Cancel; the dim does not close it', (
    tester,
  ) async {
    final cancel = FocusNode();
    addTearDown(cancel.dispose);
    await tester.pumpWidget(overlayHost(_alert(cancel: cancel)));
    await _open(tester);
    expect(cancel.hasFocus, isTrue);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.text('Delete this notebook?'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Delete this notebook?'), findsNothing);
  });

  testWidgets('the regular size puts the media beside the text', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(_alert()));
    await _open(tester);
    final media = tester.getRect(find.byType(AlertDialogMedia));
    final title = tester.getRect(find.text('Delete this notebook?'));
    expect(media.size, const Size.square(Spacing.d64));
    expect(title.left - media.right, Spacing.d24);
    final cancel = tester.getRect(find.byKey(_cancel));
    final action = tester.getRect(find.text('Delete'));
    expect(cancel.right, lessThan(action.left));
    expect(find.byType(DialogCloseMark), findsNothing);
  });

  testWidgets('the small size stacks the header and halves the answers', (
    tester,
  ) async {
    await tester.pumpWidget(overlayHost(_alert(size: AlertDialogSize.small)));
    await _open(tester);
    final sheet = tester.getRect(find.byType(AlertDialogContent));
    expect(sheet.width, AlertDialogContent.smallWidth);
    final media = tester.getRect(find.byType(AlertDialogMedia));
    final title = tester.getRect(find.text('Delete this notebook?'));
    expect(media.center.dx, closeTo(sheet.center.dx, 0.5));
    expect(title.top, greaterThan(media.bottom));
    final cancel = tester.getRect(find.byKey(_cancel));
    expect(cancel.width, (sheet.width - Spacing.d48 - Spacing.d8) / 2);
  });

  testWidgets('danger tapes the corners, but not when calm', (tester) async {
    await tester.pumpWidget(
      overlayHost(_alert(tone: AlertDialogTone.danger)),
    );
    await _open(tester);
    expect(find.byType(Tape), findsNWidgets(2));
    await tester.pumpWidget(
      overlayHost(
        _alert(tone: AlertDialogTone.danger),
        theme: const LooseleafThemeData(density: LooseleafDensity.calm),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Tape), findsNothing);
  });
}
