import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/sticker_board/sticker_board.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The tools under a [StickerBoardCanvas], acting on the selected sticker:
/// turn left and right, smaller and larger, back, backward, forward and
/// front, duplicate and delete; Export works on the whole board. A slip of
/// paper with a hairline shadow; the arrow keys, Home and End move between
/// its buttons (mirrored right to left). [actions] picks the groups shown.
///
/// Mirrors `StickerBoardToolbar` in upstream
/// `src/components/ui/sticker-board.tsx`.
class StickerBoardToolbar extends StatefulWidget {
  const StickerBoardToolbar({
    super.key,
    this.actions = StickerBoardAction.values,
  });

  /// The groups shown, in toolbar order.
  final List<StickerBoardAction> actions;

  @override
  State<StickerBoardToolbar> createState() => _StickerBoardToolbarState();
}

typedef _Tool = ({
  String label,
  String icon,
  String? text,
  bool mirror,
  bool enabled,
  VoidCallback run,
});

class _StickerBoardToolbarState extends State<StickerBoardToolbar> {
  final Map<String, FocusNode> _nodes = {};

  FocusNode _node(String label) =>
      _nodes.putIfAbsent(label, () => FocusNode(debugLabel: label));

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  List<List<_Tool>> _groups(StickerBoardScope scope) {
    final board = scope.board;
    final id = scope.selectedId;
    final off = id == null || !scope.editable;
    StickerBoardItem? item;
    for (final s in scope.items) {
      if (s.id == id) item = s;
    }
    void on(void Function(String id) run) {
      if (id case final selected?) run(selected);
    }

    _Tool tool(
      String label,
      String icon,
      void Function(String id) run, {
      String? text,
      bool mirror = false,
      bool? disabled,
    }) => (
      label: label,
      icon: icon,
      text: text,
      mirror: mirror,
      enabled: !(disabled ?? off),
      run: () => on(run),
    );

    final has = widget.actions.contains;
    return [
      if (has(StickerBoardAction.turn))
        [
          tool(
            'Turn left',
            'rotate-cw',
            (id) => board.turn(id, -StickerBoard.turn),
            mirror: true,
          ),
          tool(
            'Turn right',
            'rotate-cw',
            (id) => board.turn(id, StickerBoard.turn),
          ),
        ],
      if (has(StickerBoardAction.size))
        [
          tool(
            'Smaller',
            'minus',
            (id) => board.resize(id, 1 / StickerBoard.zoom),
            disabled: off || (item?.scale ?? 1) <= board.widget.minScale,
          ),
          tool(
            'Larger',
            'plus',
            (id) => board.resize(id, StickerBoard.zoom),
            disabled: off || (item?.scale ?? 1) >= board.widget.maxScale,
          ),
        ],
      if (has(StickerBoardAction.layer))
        [
          tool(
            'Send to back',
            '',
            (id) => board.reorder(id, StickerReorder.back),
            text: 'Back',
          ),
          tool(
            'Send backward',
            'arrow-down',
            (id) => board.reorder(id, StickerReorder.backward),
          ),
          tool(
            'Bring forward',
            'arrow-up',
            (id) => board.reorder(id, StickerReorder.forward),
          ),
          tool(
            'Bring to front',
            '',
            (id) => board.reorder(id, StickerReorder.front),
            text: 'Front',
          ),
        ],
      if (has(StickerBoardAction.duplicate) || has(StickerBoardAction.delete))
        [
          if (has(StickerBoardAction.duplicate))
            tool('Duplicate', 'copy', board.duplicate),
          if (has(StickerBoardAction.delete))
            tool('Delete', 'trash', (id) {
              board.remove(id);
              board.surfaceFocus.requestFocus();
            }),
        ],
      if (has(StickerBoardAction.export))
        [
          (
            label: 'Export',
            icon: 'download',
            text: 'Export',
            mirror: false,
            enabled: true,
            run: board.exportBoard,
          ),
        ],
    ];
  }

  KeyEventResult _roving(
    List<_Tool> tools,
    KeyEvent event,
    TextDirection direction,
  ) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final list = [
      for (final tool in tools)
        if (tool.enabled) _node(tool.label),
    ];
    final at = list.indexWhere((node) => node.hasPrimaryFocus);
    if (at < 0) return KeyEventResult.ignored;
    final rtl = direction == TextDirection.rtl;
    final step = switch ((key, rtl)) {
      (LogicalKeyboardKey.arrowRight, false) ||
      (LogicalKeyboardKey.arrowLeft, true) => 1,
      (LogicalKeyboardKey.arrowLeft, false) ||
      (LogicalKeyboardKey.arrowRight, true) => -1,
      _ => 0,
    };
    final to = switch (key) {
      LogicalKeyboardKey.home => 0,
      LogicalKeyboardKey.end => list.length - 1,
      _ when step != 0 => (at + step + list.length) % list.length,
      _ => null,
    };
    if (to == null) return KeyEventResult.ignored;
    list[to].requestFocus();
    return KeyEventResult.handled;
  }

  Widget _button(_Tool tool) {
    final text = tool.text;
    final icon = switch (tool.icon) {
      '' => null,
      final name => InkIcon(
        name,
        size: Spacing.d16,
        flip: switch (tool.mirror) {
          true => IconFlip.x,
          false => IconFlip.none,
        },
      ),
    };
    return Button(
      key: ValueKey(tool.label),
      variant: ButtonVariant.outline,
      size: switch (text) {
        null => ButtonSize.iconSm,
        _ => ButtonSize.sm,
      },
      disabled: !tool.enabled,
      onPressed: tool.run,
      focusNode: _node(tool.label),
      semanticLabel: tool.label,
      seed: 'sticker-tool-${tool.label}',
      leading: switch (text) {
        null => null,
        _ => icon,
      },
      child: switch (text) {
        final label? => Text(label),
        null => icon ?? const SizedBox.shrink(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = StickerBoardScope.of(context);
    final groups = _groups(scope);
    final direction = Directionality.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Sticker tools',
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, event) =>
            _roving([for (final group in groups) ...group], event, direction),
        child: Paper(
          stock: StockName.slip,
          edge: const EdgeSpec.all(EdgeKind.cut),
          tilt: false,
          shadow: PaperShadow.hair,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d8,
            vertical: Spacing.d6,
          ),
          child: Wrap(
            spacing: Spacing.d16,
            runSpacing: Spacing.d8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final group in groups)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d6,
                  children: [for (final tool in group) _button(tool)],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
