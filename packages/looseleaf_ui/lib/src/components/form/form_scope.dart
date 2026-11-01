import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/form/form_controller.dart';

/// Hands an [InkForm]'s controller down and rebuilds its fields when it
/// changes, like react-hook-form's `FormProvider`.
class FormScope extends InheritedNotifier<FormController> {
  const FormScope({
    super.key,
    required FormController controller,
    required super.child,
  }) : super(notifier: controller);

  /// The nearest form's controller.
  static FormController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FormScope>();
    if (scope?.notifier case final controller?) return controller;
    throw FlutterError('FormScope.of() called outside an InkForm.');
  }
}

/// Hands a [FormItem]'s control holder to its label and control, like
/// upstream's `FormItemContext` id.
class FormItemScope extends InheritedWidget {
  const FormItemScope({super.key, required this.control, required super.child});

  /// Wraps the item's control: the label focuses its first focusable
  /// descendant.
  final FocusNode control;

  /// The nearest item's scope; null outside an item.
  static FormItemScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FormItemScope>();

  @override
  bool updateShouldNotify(FormItemScope oldWidget) =>
      oldWidget.control != control;
}
