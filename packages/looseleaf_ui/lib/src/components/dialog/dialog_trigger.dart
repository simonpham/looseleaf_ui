import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';

/// The control that opens a [Dialog] (and the alert dialog, sheet and
/// drawer, which share its controller).
///
/// With [DialogTrigger.builder], hand the controller to your own control
/// (a `Button`'s `onPressed: dialog.show`), like upstream's `asChild`. With
/// a plain [child], the trigger itself opens on tap, Enter and Space and is
/// announced as a button. Either way it joins the dialog's tap region and
/// reports `expanded`.
///
/// Mirrors `DialogTrigger` in upstream `src/components/ui/dialog.tsx`.
class DialogTrigger extends StatelessWidget {
  /// A trigger that opens on tap, Enter and Space.
  const DialogTrigger({
    super.key,
    required Widget this.child,
    this.focusNode,
    this.autofocus = false,
  }) : builder = null;

  /// A trigger built around your own control.
  const DialogTrigger.builder({super.key, required this.builder})
    : child = null,
      focusNode = null,
      autofocus = false;

  /// The trigger's content.
  final Widget? child;

  /// Builds the trigger with the dialog's controller.
  final Widget Function(BuildContext context, DialogController dialog)? builder;

  /// The plain trigger's focus node.
  final FocusNode? focusNode;

  /// Whether the plain trigger takes focus first.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final dialog = DialogScope.of(context);
    final build = builder;
    if (build != null) {
      return TapRegion(
        groupId: dialog.groupId,
        child: InkTriggerSemantics(
          expanded: dialog.open,
          child: Builder(builder: (context) => build(context, dialog)),
        ),
      );
    }
    return TapRegion(
      groupId: dialog.groupId,
      child: Semantics(
        container: true,
        button: true,
        expanded: dialog.open,
        onTap: dialog.show,
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
                dialog.show();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: dialog.show,
            child: child,
          ),
        ),
      ),
    );
  }
}
