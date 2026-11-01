import 'dart:ui' show SemanticsRole;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';

/// The slip a menu or sub-menu is written on, and its keyboard: a
/// [PaperPopup] (no rules, the `lift` shadow) with its rows in a scrolling
/// viewport 4 px in (2 compact and calm), at least [minWidth] wide.
///
/// It owns one [InkMenuLevel]: Up and Down move the highlight (wrapping
/// with [loop]), Home and End jump, typed letters find a row, Tab stays put.
/// The back arrow (Left, or Right in right-to-left) closes a [sub]-menu;
/// at the top level horizontal arrows go to [InkMenuRootData.onArrowOut].
///
/// Mirrors `menuContentClass` and `menuViewportClass` in upstream
/// `src/lib/menu-styles.ts`, and Radix's `MenuContent`.
class InkMenuPanel extends StatefulWidget {
  const InkMenuPanel({
    super.key,
    required this.children,
    required this.seed,
    this.stock = StockName.slip,
    this.edge,
    this.tilt = true,
    this.tape,
    this.width,
    this.minWidth = InkMenuMetrics.minWidth,
    this.loop = false,
    this.focusFirst = false,
    this.position,
    this.side = OverlaySide.bottom,
    this.sub,
    this.semanticLabel,
  });

  /// The rows.
  final List<Widget> children;

  /// Seeds the sheet.
  final String seed;

  /// The paper stock.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the slip flat.
  final bool tilt;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// A fixed width; the widest row's when null.
  final double? width;

  /// The least width.
  final double minWidth;

  /// Whether Up and Down wrap at the ends.
  final bool loop;

  /// Highlights the first row on open.
  final bool focusFirst;

  /// Where the slip landed.
  final OverlayPosition? position;

  /// The side it opens on, until [position] is known.
  final OverlaySide side;

  /// The sub-menu this slip belongs to; null for the top level.
  final InkMenuSubState? sub;

  /// Names the menu for screen readers.
  final String? semanticLabel;

  @override
  State<InkMenuPanel> createState() => _InkMenuPanelState();
}

class _InkMenuPanelState extends State<InkMenuPanel> {
  late final FocusNode _node = FocusNode(debugLabel: 'InkMenuPanel');
  late final InkMenuLevel _level = InkMenuLevel(_node);

  @override
  void initState() {
    super.initState();
    widget.sub?.attach(_level);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.focusFirst) {
        _level.edge(last: false);
        return;
      }
      _node.requestFocus();
    });
  }

  @override
  void dispose() {
    widget.sub?.detach(_level);
    _node.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final back = switch (rtl) {
      true => LogicalKeyboardKey.arrowRight,
      false => LogicalKeyboardKey.arrowLeft,
    };
    final forward = switch (rtl) {
      true => LogicalKeyboardKey.arrowLeft,
      false => LogicalKeyboardKey.arrowRight,
    };
    if (key == LogicalKeyboardKey.arrowDown) {
      _level.move(1, loop: widget.loop);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _level.move(-1, loop: widget.loop);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home || key == LogicalKeyboardKey.pageUp) {
      _level.edge(last: false);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end || key == LogicalKeyboardKey.pageDown) {
      _level.edge(last: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) return KeyEventResult.handled;
    if (key == back || key == forward) return _horizontal(key == back);
    return _type(event);
  }

  KeyEventResult _horizontal(bool back) {
    if (widget.sub case final sub? when back) {
      sub.close(focusTrigger: true);
      return KeyEventResult.handled;
    }
    if (widget.sub != null) return KeyEventResult.ignored;
    final out = InkMenuRootScope.maybeOf(context)?.onArrowOut;
    if (out == null) return KeyEventResult.ignored;
    out(switch (back) {
      true => -1,
      false => 1,
    });
    return KeyEventResult.handled;
  }

  KeyEventResult _type(KeyEvent event) {
    final char = event.character;
    final keyboard = HardwareKeyboard.instance;
    final modified =
        keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isAltPressed;
    if (char == null || modified || char.characters.length != 1) {
      return KeyEventResult.ignored;
    }
    if (char.trim().isEmpty || char.codeUnitAt(0) < 0x20) {
      return KeyEventResult.ignored;
    }
    _level.typeahead(char);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final window = MediaQuery.maybeSizeOf(context)?.width ?? double.infinity;
    final rows = SingleChildScrollView(
      padding: EdgeInsets.all(InkMenuMetrics.viewportPadding.of(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.children,
      ),
    );
    return Focus(
      focusNode: _node,
      onKeyEvent: _onKey,
      child: InkMenuLevelScope(
        level: _level,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          role: SemanticsRole.menu,
          label: widget.semanticLabel,
          child: PaperPopup(
            seed: widget.seed,
            stock: widget.stock,
            edge: widget.edge,
            tilt: widget.tilt,
            tape: widget.tape,
            width: widget.width,
            maxWidth: window - InkMenuMetrics.windowGap,
            position: widget.position,
            side: widget.side,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: widget.minWidth),
              child: switch (widget.width) {
                null => IntrinsicWidth(child: rows),
                _ => rows,
              },
            ),
          ),
        ),
      ),
    );
  }
}
