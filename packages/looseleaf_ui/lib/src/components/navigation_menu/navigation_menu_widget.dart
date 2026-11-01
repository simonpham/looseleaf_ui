import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/navigation_menu/navigation_menu.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A site's top navigation as a strip of index dividers: [child] (a
/// [NavigationMenuList]) of pencil tabs on a pencil line. A
/// [NavigationMenuTrigger] opens its item's [NavigationMenuContent] on a
/// slip that drops 8 px under the strip, resized to the open panel, with
/// the panels sliding inside it ([viewport]); without the viewport each
/// panel is a slip of its own under its tab.
///
/// Hover (after [delay], at once while one is open or within [skipDelay]
/// of a close), a tap, Enter or Space open a panel; Escape, a tap outside,
/// the pointer leaving both strip and panel, or focus leaving the menu
/// close it. Left and Right (mirrored in RTL) walk the tabs and Down steps
/// into an open panel. The open item can be yours with [value] and
/// [onValueChange].
///
/// ```dart
/// NavigationMenu(
///   semanticLabel: 'Main',
///   child: NavigationMenuList(children: [
///     NavigationMenuItem(
///       value: 'docs',
///       content: NavigationMenuContent(child: links),
///       child: const NavigationMenuTrigger(child: Text('Docs')),
///     ),
///     NavigationMenuItem(
///       child: NavigationMenuLink(onPressed: home, child: const Text('Home')),
///     ),
///     const NavigationMenuIndicator(),
///   ]),
/// )
/// ```
///
/// Mirrors `NavigationMenu` in upstream
/// `src/components/ui/navigation-menu.tsx` (Radix `NavigationMenu.Root`).
class NavigationMenu extends StatefulWidget {
  const NavigationMenu({
    super.key,
    required this.child,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.viewport = true,
    this.delay = defaultDelay,
    this.skipDelay = defaultSkipDelay,
    this.seed,
    this.semanticLabel,
  });

  /// Radix's `delayDuration`.
  static const Duration defaultDelay = Duration(milliseconds: 200);

  /// Radix's `skipDelayDuration`.
  static const Duration defaultSkipDelay = Duration(milliseconds: 300);

  /// The strip, a [NavigationMenuList].
  final Widget child;

  /// The open item; the menu keeps its own when null and [onValueChange]
  /// is null.
  final String? value;

  /// The item open at first, when uncontrolled.
  final String? defaultValue;

  /// Called when an item asks to open (or null to close).
  final ValueChanged<String?>? onValueChange;

  /// One slip shared by every panel; false gives each panel its own.
  final bool viewport;

  /// The hover intent before a panel opens.
  final Duration delay;

  /// How long after a close another panel opens without [delay].
  final Duration skipDelay;

  /// Pins the shared slip.
  final String? seed;

  /// Names the navigation landmark (`aria-label`).
  final String? semanticLabel;

  /// The nearest menu's controller.
  static NavigationMenuController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw FlutterError('No NavigationMenu above this widget.');
    }
    return controller;
  }

  /// The nearest menu's controller, or null.
  static NavigationMenuController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<NavigationMenuScope>()
      ?.notifier;

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  late final NavigationMenuController _controller = NavigationMenuController(
    value: widget.value ?? widget.defaultValue,
    delay: widget.delay,
    skipDelay: widget.skipDelay,
  );

  bool get _controlled => widget.value != null || widget.onValueChange != null;

  @override
  void initState() {
    super.initState();
    _configure();
  }

  @override
  void didUpdateWidget(NavigationMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _configure();
    if (_controlled) _controller.sync(widget.value);
  }

  void _configure() {
    _controller
      ..delay = widget.delay
      ..skipDelay = widget.skipDelay
      ..viewport = widget.viewport
      ..controlled = _controlled
      ..onValueChange = widget.onValueChange;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strip = MouseRegion(
      onEnter: (_) => _controller.stay(),
      onExit: (_) => _controller.leave(),
      child: widget.child,
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      child: NavigationMenuScope(
        controller: _controller,
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          includeSemantics: false,
          onFocusChange: (focused) {
            if (!focused) _controller.close();
          },
          child: TapRegion(
            groupId: _controller.groupId,
            onTapOutside: (_) => _controller.close(),
            child: switch (widget.viewport) {
              true => ListenableBuilder(
                listenable: _controller,
                builder: (context, child) => InkPopup(
                  open: _controller.isOpen,
                  onOpenChange: (open) {
                    if (!open) _controller.close();
                  },
                  align: OverlayAlign.start,
                  sideOffset: Spacing.d8,
                  autofocus: false,
                  groupId: _controller.groupId,
                  popupBuilder: (context, position) =>
                      NavigationMenuViewport(seed: widget.seed),
                  child: child ?? const SizedBox.shrink(),
                ),
                child: strip,
              ),
              false => strip,
            },
          ),
        ),
      ),
    );
  }
}
