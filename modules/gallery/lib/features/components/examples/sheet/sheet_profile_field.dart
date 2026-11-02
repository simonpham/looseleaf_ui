import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A labelled input holding [value]: the label above it, or [inline] on
/// its left in a quarter of the row, end-aligned.
class SheetProfileField extends StatefulWidget {
  const SheetProfileField({
    super.key,
    required this.label,
    required this.value,
    this.inline = false,
  });

  final String label;
  final String value;
  final bool inline;

  @override
  State<SheetProfileField> createState() => _SheetProfileFieldState();
}

class _SheetProfileFieldState extends State<SheetProfileField> {
  late final _controller = TextEditingController(text: widget.value);
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = Label(focusNode: _focusNode, child: Text(widget.label));
    final input = Input(
      controller: _controller,
      focusNode: _focusNode,
      semanticLabel: widget.label,
    );
    if (widget.inline) {
      return Row(
        spacing: Spacing.d16,
        children: [
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: label,
            ),
          ),
          Expanded(flex: 3, child: input),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d12,
      children: [label, input],
    );
  }
}
