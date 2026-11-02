import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/popover/popover.dart';

/// The control that opens a [Popover].
///
/// With [PopoverTrigger.builder], hand the controller to your own control
/// (a `Button`'s `onPressed: popover.toggle`): the usual case, like
/// upstream's `asChild`. With a plain [child], the trigger itself takes
/// taps, Enter and Space and is announced as a button. Either way it joins
/// the popover's tap region, so tapping it toggles instead of counting as
/// outside, and reports `expanded`.
///
/// Mirrors `PopoverTrigger` in upstream `src/components/ui/popover.tsx`.
class PopoverTrigger extends StatelessWidget {
  /// A trigger that toggles on tap, Enter and Space.
  const PopoverTrigger({
    super.key,
    required Widget this.child,
    this.focusNode,
    this.autofocus = false,
  }) : builder = null;

  /// A trigger built around your own control.
  const PopoverTrigger.builder({super.key, required this.builder})
    : child = null,
      focusNode = null,
      autofocus = false;

  /// The trigger's content.
  final Widget? child;

  /// Builds the trigger with the popover's controller.
  final Widget Function(BuildContext context, PopoverController popover)?
  builder;

  /// The plain trigger's focus node.
  final FocusNode? focusNode;

  /// Whether the plain trigger takes focus first.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final popover = Popover.of(context);
    final build = builder;
    if (build != null) {
      return TapRegion(
        groupId: popover.groupId,
        child: InkTriggerSemantics(
          expanded: popover.open,
          child: Builder(builder: (context) => build(context, popover)),
        ),
      );
    }
    return TapRegion(
      groupId: popover.groupId,
      child: Semantics(
        container: true,
        button: true,
        expanded: popover.open,
        onTap: popover.toggle,
        child: FocusableActionDetector(
          focusNode: focusNode,
          autofocus: autofocus,
          mouseCursor: SystemMouseCursors.click,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                popover.toggle();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: popover.toggle,
            child: child,
          ),
        ),
      ),
    );
  }
}
