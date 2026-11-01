import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/menubar/menubar.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An application's menu bar: a shaded strip in an inked box with a
/// ruler's ticks along its bottom (a plain pencil box when calm), holding
/// [MenubarMenu]s, 40 px tall (36 compact, 32 calm).
///
/// The bar is one Tab stop; Left and Right (mirrored in right-to-left)
/// move between titles; Enter, Space or Down open a menu with its first row
/// highlighted. Once one is open, hovering another title or pressing Left
/// or Right from a plain row switches menus; Escape closes it and focus
/// goes back to its title.
///
/// ```dart
/// Menubar(
///   children: [
///     MenubarMenu(
///       trigger: const MenubarTrigger(child: Text('File')),
///       content: MenubarContent(
///         children: [
///           MenubarItem(
///             trailing: const MenubarShortcut('⌘T'),
///             onSelect: newTab,
///             child: const Text('New Tab'),
///           ),
///         ],
///       ),
///     ),
///   ],
/// )
/// ```
///
/// Mirrors `Menubar` in upstream `src/components/ui/menubar.tsx` (Radix
/// `Menubar.Root`).
class Menubar extends StatefulWidget {
  const Menubar({
    super.key,
    required this.children,
    this.value,
    this.onValueChange,
    this.seed,
  });

  /// The menus.
  final List<Widget> children;

  /// The open menu's [MenubarMenu.value]; the bar keeps its own when null.
  final String? value;

  /// Called with the menu that opens, or null when they all close.
  final ValueChanged<String?>? onValueChange;

  /// Pins the strip's drawing.
  final String? seed;

  /// The strip's height: `h-10 compact:h-9 calm:h-8`.
  static const ByDensity<double> height = ByDensity(
    comfortable: Spacing.d40,
    compact: Spacing.d36,
    calm: Spacing.d32,
  );

  @override
  State<Menubar> createState() => MenubarState();
}

/// The state of a [Menubar]: which menu is open, and the moves between
/// menus.
class MenubarState extends State<Menubar> with InkSeed {
  static final _source = RecipeInkSource(
    menubarRecipe,
    const NoParams(),
    json: const NoParams().toJson(),
  );

  final List<(Object, FocusNode)> _menus = [];
  Object? _open;

  /// Whether the open menu highlights its first row.
  bool focusFirst = false;

  /// The tap region group of the bar and every slip.
  final Object groupId = Object();

  /// The open menu's id.
  Object? get openMenu => switch (widget.value) {
    final value? => value,
    null => _open,
  };

  /// Adds a menu, in bar order.
  void register(Object id, FocusNode trigger) => _menus.add((id, trigger));

  void unregister(Object id) => _menus.removeWhere((menu) => menu.$1 == id);

  /// Opens the menu [id] (or closes every menu with null); [focusFirst]
  /// highlights its first row.
  void setOpen(Object? id, {bool focusFirst = false}) {
    if (id == openMenu) return;
    setState(() {
      this.focusFirst = focusFirst;
      if (widget.value == null) _open = id;
    });
    widget.onValueChange?.call(switch (id) {
      final String value => value,
      _ => null,
    });
  }

  /// Opens the menu [step] places from [id] (in reading order, wrapping),
  /// focusing its title first so Escape comes back to it.
  void step(Object id, int step) {
    final index = _menus.indexWhere((menu) => menu.$1 == id);
    if (index < 0 || _menus.isEmpty) return;
    final (next, trigger) = _menus[(index + step) % _menus.length];
    trigger.requestFocus();
    setOpen(next, focusFirst: true);
  }

  @override
  Widget build(BuildContext context) => MenubarScope(
    state: this,
    openMenu: openMenu,
    child: TapRegion(
      groupId: groupId,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        role: SemanticsRole.menuBar,
        child: InkSurface(
          source: _source,
          seed: inkSeed(widget.seed),
          still: true,
          child: SizedBox(
            height: Menubar.height.of(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
              child: InkRovingFocus(
                axis: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.d4,
                  children: widget.children,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
