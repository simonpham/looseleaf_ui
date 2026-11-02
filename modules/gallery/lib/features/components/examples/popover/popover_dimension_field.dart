import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A label and an input on one row, a third and two thirds wide, as in the
/// shadcn popover demo.
class PopoverDimensionField extends StatefulWidget {
  const PopoverDimensionField({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  State<PopoverDimensionField> createState() => _PopoverDimensionFieldState();
}

class _PopoverDimensionFieldState extends State<PopoverDimensionField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    spacing: Spacing.d16,
    children: [
      Expanded(
        child: Label(
          focusNode: _focusNode,
          child: Text(widget.label),
        ),
      ),
      Expanded(
        flex: 2,
        child: Input(
          controller: _controller,
          focusNode: _focusNode,
          semanticLabel: widget.label,
          height: Spacing.d32,
        ),
      ),
    ],
  );
}
