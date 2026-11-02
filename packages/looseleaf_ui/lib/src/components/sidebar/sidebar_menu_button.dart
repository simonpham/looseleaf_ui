import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/components/tooltip/tooltip.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A row's button: an optional [leading] icon, the [child] label (cut short
/// with an ellipsis) and an optional [trailing] widget, in Kevin Sans Hand
/// on its own line of the pad's ruling.
///
/// Hover and keyboard focus lay the highlighter under it. The current page
/// ([isActive]) is bold, with a drawn highlighter swipe and a blue pencil
/// bracket in the margin; [SidebarMenuButtonVariant.outline] draws a
/// pencil box. Collapsed to icons it is a 32 px square showing only
/// [leading], named by [tooltip] on hover and focus.
///
/// ```dart
/// SidebarMenuButton(
///   isActive: true,
///   tooltip: 'Inbox',
///   leading: const InkIcon('inbox'),
///   onPressed: openInbox,
///   child: const Text('Inbox'),
/// )
/// ```
///
/// Mirrors `SidebarMenuButton` in upstream `src/components/ui/sidebar.tsx`.
class SidebarMenuButton extends StatefulWidget {
  const SidebarMenuButton({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.isActive = false,
    this.variant = SidebarMenuButtonVariant.regular,
    this.size = SidebarMenuButtonSize.regular,
    this.tooltip,
    this.disabled = false,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The label, usually a [Text].
  final Widget child;

  /// The icon (or avatar) before the label; all that shows collapsed.
  final Widget? leading;

  /// A chevron or indicator at the end.
  final Widget? trailing;

  /// Called on tap, Enter and Space.
  final VoidCallback? onPressed;

  /// Marks the current page.
  final bool isActive;

  /// [SidebarMenuButtonVariant.outline] adds a pencil box.
  final SidebarMenuButtonVariant variant;

  /// 32, 28 or 48 px high.
  final SidebarMenuButtonSize size;

  /// Names the row while collapsed to icons (never expanded or on phones).
  final String? tooltip;

  /// Graphite text, no input.
  final bool disabled;

  /// Pins the active mark.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name when the label is not text.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<SidebarMenuButton> createState() => _SidebarMenuButtonState();
}

class _SidebarMenuButtonState extends State<SidebarMenuButton> with InkSeed {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reportSize();
  }

  @override
  void didUpdateWidget(SidebarMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) _reportSize();
  }

  void _reportSize() {
    final notifier = SidebarMenuItemScope.maybeOf(context)?.buttonSize;
    if (notifier == null || notifier.value == widget.size) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) notifier.value = widget.size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final panel = SidebarPanelScope.maybeOf(context);
    final icons = panel?.collapsedToIcons ?? false;
    final button = Semantics(
      container: true,
      button: true,
      selected: widget.isActive,
      enabled: !widget.disabled,
      label: widget.semanticLabel,
      child: InkInteraction(
        enabled: !widget.disabled,
        onActivate: widget.onPressed,
        states: widget.forcedStates,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        builder: (context, states) => _body(context, states, icons),
      ),
    );
    final tooltip = widget.tooltip;
    if (tooltip == null) return button;
    return Tooltip(
      disabled: !icons || (panel?.mobile ?? false),
      content: TooltipContent(
        side: OverlaySide.right,
        child: Text(tooltip),
      ),
      child: button,
    );
  }

  Widget _body(BuildContext context, Set<InkState> states, bool icons) {
    final theme = LooseleafTheme.of(context);
    final active = widget.isActive;
    final engaged =
        states.contains(InkState.hovered) || states.contains(InkState.focused);
    final item = SidebarMenuItemScope.maybeOf(context);
    final endSlot = (item?.hasAction ?? false) || (item?.hasBadge ?? false);
    final height = widget.size.height.resolve(theme.density);
    final style = theme.typography.face(
      KevinSansFace.hand,
      cssSize: widget.size.cssFontSize(theme.density),
      cssLineHeight: 1.5,
      fontWeight: switch (active) {
        true => FontWeight.w700,
        false => FontWeight.w400,
      },
      color: switch (widget.disabled) {
        true => theme.colors.pencilText,
        false => theme.colors.ink,
      },
    );
    final padding = switch ((icons, widget.size, endSlot)) {
      (true, SidebarMenuButtonSize.lg, _) => EdgeInsets.zero,
      (true, _, _) => const EdgeInsets.all(Spacing.d8),
      (false, _, true) => const EdgeInsetsDirectional.only(
        start: Spacing.d8,
        end: Spacing.d32,
      ),
      (false, _, false) => const EdgeInsets.symmetric(horizontal: Spacing.d8),
    };
    Widget row = Padding(
      padding: padding,
      child: IconTheme.merge(
        data: IconThemeData(color: theme.colors.inkSoft),
        child: Row(
          spacing: Spacing.d8,
          children: [
            ?widget.leading,
            Expanded(child: widget.child),
            ?widget.trailing,
          ],
        ),
      ),
    );
    if (icons) {
      row = SizedBox.square(
        dimension: SidebarMetrics.iconRow,
        child: ClipRect(
          child: OverflowBox(
            alignment: AlignmentDirectional.centerStart,
            minWidth: SidebarMetrics.width,
            maxWidth: SidebarMetrics.width,
            minHeight: SidebarMetrics.iconRow,
            maxHeight: SidebarMetrics.iconRow,
            child: row,
          ),
        ),
      );
    }
    if (!icons) row = SizedBox(height: height, child: row);
    final marked = active || widget.variant == SidebarMenuButtonVariant.outline;
    if (marked) {
      row = InkSurface(
        source: SidebarMarkSource(
          active: active,
          outline: widget.variant == SidebarMenuButtonVariant.outline,
          bracket: !icons,
        ),
        seed: inkSeed(widget.seed),
        still: true,
        child: row,
      );
    }
    final ruled = !icons && !PaperInk.calm(theme);
    return InkContent(
      style: style,
      iconSize: Spacing.d16,
      wrap: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SidebarSwipe(on: engaged && !active, child: row),
          if (ruled)
            PositionedDirectional(
              start: Spacing.d4,
              end: Spacing.d4,
              bottom: -Spacing.d2,
              child: SidebarRowRule(odd: SidebarMenuItemIndex.oddOf(context)),
            ),
        ],
      ),
    );
  }
}
