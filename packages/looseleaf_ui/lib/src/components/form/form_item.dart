import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/form/form.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A field's label, control, description and message, 8 px apart.
///
/// Mirrors `FormItem` in upstream `src/components/ui/form.tsx`
/// (`grid gap-2`).
class FormItem extends StatefulWidget {
  const FormItem({super.key, required this.children});

  /// A [FormLabel], a [FormControl], a [FormDescription], a [FormMessage].
  final List<Widget> children;

  @override
  State<FormItem> createState() => _FormItemState();
}

class _FormItemState extends State<FormItem> {
  final FocusNode _control = FocusNode(
    debugLabel: 'FormItem control',
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FormItemScope(
    control: _control,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: widget.children,
    ),
  );
}
