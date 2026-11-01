import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

class _Host extends StatefulWidget {
  const _Host({
    this.centered = false,
    this.scrim = false,
    this.modal = false,
    this.motion = PopupMotionStyle.pop,
  });

  final bool centered;
  final bool scrim;
  final bool modal;
  final PopupMotionStyle motion;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool open = false;
  final List<OverlayDismissReason> reasons = [];

  @override
  Widget build(BuildContext context) => InkPopup(
    open: open,
    onOpenChange: (value) => setState(() => open = value),
    onDismiss: reasons.add,
    centered: widget.centered,
    scrim: widget.scrim,
    modal: widget.modal,
    motion: widget.motion,
    popupBuilder: (context, position) =>
        const SizedBox(width: 100, height: 60, child: Text('Popup')),
    child: GestureDetector(
      onTap: () => setState(() => open = true),
      child: const Text('Anchor'),
    ),
  );
}

void main() {
  testWidgets('stays shown through its exit, then goes', (tester) async {
    await tester.pumpWidget(overlayHost(const _Host()));
    await tester.tap(find.text('Anchor'));
    await tester.pumpAndSettle();
    final state = tester.state<_HostState>(find.byType(_Host));
    state.setState(() => state.open = false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('Popup'), findsOneWidget);
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Popup'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, lessThan(1));
    await tester.pumpAndSettle();
    expect(find.text('Popup'), findsNothing);
  });

  testWidgets('Escape and outside taps report why', (tester) async {
    await tester.pumpWidget(overlayHost(const _Host()));
    await tester.tap(find.text('Anchor'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anchor'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    final state = tester.state<_HostState>(find.byType(_Host));
    expect(state.reasons, [
      OverlayDismissReason.escape,
      OverlayDismissReason.outside,
    ]);
  });

  testWidgets('a centred popup with a scrim dims and dismisses on tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      overlayHost(
        const _Host(
          centered: true,
          scrim: true,
          motion: PopupMotionStyle.sheetDrop,
        ),
      ),
    );
    await tester.tap(find.text('Anchor'));
    await tester.pumpAndSettle();
    final popup = tester.getRect(find.text('Popup'));
    final screen = tester.getRect(find.byType(Overlay).first);
    expect(popup.center.dx, closeTo(screen.center.dx, 1));
    expect(find.byType(OverlayScrim), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Popup'), findsNothing);
  });

  testWidgets('a modal popup traps Tab inside', (tester) async {
    final nodes = [FocusNode(), FocusNode()];
    addTearDown(() {
      for (final node in nodes) {
        node.dispose();
      }
    });
    await tester.pumpWidget(
      overlayHost(
        InkPopup(
          open: true,
          modal: true,
          popupBuilder: (context, position) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final node in nodes)
                Focus(
                  focusNode: node,
                  child: const SizedBox.square(dimension: 20),
                ),
            ],
          ),
          child: const Text('Anchor'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(nodes.first.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(nodes.last.hasFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(nodes.first.hasFocus, isTrue);
  });

  testWidgets('the topmost layer takes Escape first', (tester) async {
    final closed = <String>[];
    await tester.pumpWidget(
      overlayHost(
        OverlayDismiss(
          onDismiss: (_) => closed.add('outer'),
          child: OverlayDismiss(
            onDismiss: (_) => closed.add('inner'),
            child: const Text('Layers'),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(closed, ['inner']);
  });

  testWidgets('reduced motion opens at once', (tester) async {
    await tester.pumpWidget(
      overlayHost(
        const _Host(),
        theme: const LooseleafThemeData(motion: LooseleafMotion.reduced),
      ),
    );
    await tester.tap(find.text('Anchor'));
    await tester.pump();
    await tester.pump();
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Popup'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, 1);
  });
}
