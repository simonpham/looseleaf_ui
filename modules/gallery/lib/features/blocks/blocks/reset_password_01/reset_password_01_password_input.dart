import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A password input with a button that shows or hides what was typed.
class ResetPassword01PasswordInput extends StatefulWidget {
  const ResetPassword01PasswordInput({
    super.key,
    this.controller,
    this.focusNode,
    this.invalid = false,
    this.onChanged,
    this.onSubmitted,
    this.toggleLabel = 'Show password',
    this.semanticLabel = 'Password',
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool invalid;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Names the show button for screen readers.
  final String toggleLabel;

  /// Names the input for screen readers.
  final String semanticLabel;

  @override
  State<ResetPassword01PasswordInput> createState() =>
      _ResetPassword01PasswordInputState();
}

class _ResetPassword01PasswordInputState
    extends State<ResetPassword01PasswordInput> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) => InputGroup(
    focusNode: widget.focusNode,
    invalid: widget.invalid,
    children: [
      InputGroupInput(
        controller: widget.controller,
        obscureText: !_shown,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        semanticLabel: widget.semanticLabel,
      ),
      InputGroupAddon(
        align: InputGroupAlign.inlineEnd,
        child: InputGroupButton(
          size: InputGroupButtonSize.iconSm,
          semanticLabel: widget.toggleLabel,
          onPressed: () => setState(() => _shown = !_shown),
          child: InkIcon(switch (_shown) {
            true => 'eye-off',
            false => 'eye',
          }, size: Spacing.d16),
        ),
      ),
    ],
  );
}
