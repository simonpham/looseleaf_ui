import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/components/tooltip/tooltip.dart';

/// Holds a sidebar's open state and lays out its [children] (a [Sidebar]
/// and a [SidebarInset]) in a row filling the height it is given, under an
/// optional [header] across the full width.
///
/// The desktop state is yours with [open] and [onOpenChange], or starts at
/// [defaultOpen]. Below [mobileBreakpoint] the [Sidebar] becomes a sheet
/// with its own state, closed again when the window grows past it.
/// Ctrl or Cmd + B toggles whichever applies, unless something nearer the
/// focus handled the key first. Tooltips below open without a delay.
///
/// ```dart
/// SidebarProvider(
///   children: [
///     Sidebar(children: [SidebarContent(children: [...])]),
///     SidebarInset(child: page),
///   ],
/// )
/// ```
///
/// Read the state with [SidebarProvider.of] (upstream `useSidebar`).
///
/// Mirrors `SidebarProvider` in upstream `src/components/ui/sidebar.tsx`.
/// Upstream's `sidebar_state` cookie has no counterpart: persist [open]
/// from [onOpenChange] yourself.
class SidebarProvider extends StatefulWidget {
  const SidebarProvider({
    super.key,
    required this.children,
    this.defaultOpen = true,
    this.open,
    this.onOpenChange,
    this.width = SidebarMetrics.width,
    this.widthIcon = SidebarMetrics.widthIcon,
    this.widthMobile = SidebarMetrics.widthMobile,
    this.mobileBreakpoint = SidebarMetrics.mobileBreakpoint,
    this.keyboardShortcut = true,
    this.header,
  });

  /// The sidebar and the page beside it, in reading order.
  final List<Widget> children;

  /// Whether the sidebar starts open when [open] is null.
  final bool defaultOpen;

  /// Whether the desktop sidebar is open; the provider keeps its own state
  /// when null.
  final bool? open;

  /// Called when the desktop sidebar asks to open or close.
  final ValueChanged<bool>? onOpenChange;

  /// `--sidebar-width`.
  final double width;

  /// `--sidebar-width-icon`: the width collapsed to icons.
  final double widthIcon;

  /// The phone sheet's width.
  final double widthMobile;

  /// Windows narrower than this get the phone sheet.
  final double mobileBreakpoint;

  /// Whether Ctrl or Cmd + B toggles the sidebar.
  final bool keyboardShortcut;

  /// A strip across the top, above both the pad and the page (upstream's
  /// `SidebarProvider className="flex-col"` with the site header first);
  /// it can hold a [SidebarTrigger].
  final Widget? header;

  /// The nearest provider's state; throws outside one, like `useSidebar`.
  static SidebarData of(BuildContext context) {
    if (maybeOf(context) case final data?) return data;
    throw FlutterError(
      'SidebarProvider.of must be used within a SidebarProvider.',
    );
  }

  /// The nearest provider's state, or null.
  static SidebarData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SidebarScope>()?.data;

  /// The nearest provider's widths, or the defaults.
  static SidebarProvider? widgetOf(BuildContext context) =>
      context.findAncestorWidgetOfExactType<SidebarProvider>();

  @override
  State<SidebarProvider> createState() => _SidebarProviderState();
}

class _SidebarProviderState extends State<SidebarProvider> {
  late bool _open = widget.defaultOpen;
  bool _openMobile = false;
  bool _isMobile = false;
  final ValueNotifier<SidebarVariant?> _dockedVariant = ValueNotifier(null);

  bool get _isOpen => widget.open ?? _open;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_unfocusedKey);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.maybeSizeOf(context)?.width;
    _isMobile = width != null && width < widget.mobileBreakpoint;
    if (!_isMobile) _openMobile = false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_unfocusedKey);
    _dockedVariant.dispose();
    super.dispose();
  }

  void _setOpen(bool value) {
    if (widget.open == null) setState(() => _open = value);
    widget.onOpenChange?.call(value);
  }

  void _setOpenMobile(bool value) {
    if (value == _openMobile) return;
    setState(() => _openMobile = value);
  }

  void _toggle() {
    if (_isMobile) {
      _setOpenMobile(!_openMobile);
      return;
    }
    _setOpen(!_isOpen);
  }

  static bool _isShortcut(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.keyB) return false;
    final keyboard = HardwareKeyboard.instance;
    return keyboard.isMetaPressed || keyboard.isControlPressed;
  }

  /// Upstream listens on `window`; with nothing focused no widget hears
  /// keys, so the shortcut is caught here then.
  bool _unfocusedKey(KeyEvent event) {
    if (!widget.keyboardShortcut || !mounted || !_isShortcut(event)) {
      return false;
    }
    final primary = FocusManager.instance.primaryFocus;
    final nothingFocused =
        primary == null ||
        (primary is FocusScopeNode && primary.focusedChild == null);
    if (!nothingFocused) return false;
    _toggle();
    return true;
  }

  KeyEventResult _focusedKey(FocusNode node, KeyEvent event) {
    if (!widget.keyboardShortcut || !_isShortcut(event)) {
      return KeyEventResult.ignored;
    }
    _toggle();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    return SidebarScope(
      data: SidebarData(
        open: _isOpen,
        openMobile: _openMobile,
        isMobile: _isMobile,
        setOpen: _setOpen,
        setOpenMobile: _setOpenMobile,
        toggleSidebar: _toggle,
      ),
      dockedVariant: _dockedVariant,
      child: TooltipProvider(
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _focusedKey,
          child: _withHeader(
            // Laid out backwards so the pad paints over the page and is hit
            // first: its rail and shadow reach past its own box. Packed to
            // the reversed row's end, so without a SidebarInset the pad
            // still sits at the start.
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              textDirection: switch (direction) {
                TextDirection.ltr => TextDirection.rtl,
                TextDirection.rtl => TextDirection.ltr,
              },
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: widget.children.reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _withHeader(Widget row) {
    final header = widget.header;
    if (header == null) return row;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(child: row),
      ],
    );
  }
}
