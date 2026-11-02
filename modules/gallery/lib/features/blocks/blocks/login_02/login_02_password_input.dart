import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A password input with a button that shows or hides what was typed.
class Login02PasswordInput extends StatefulWidget {
  const Login02PasswordInput({
    super.key,
    this.controller,
    this.focusNode,
    this.invalid = false,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool invalid;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<Login02PasswordInput> createState() => _Login02PasswordInputState();
}

class _Login02PasswordInputState extends State<Login02PasswordInput> {
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
        semanticLabel: 'Password',
      ),
      InputGroupAddon(
        align: InputGroupAlign.inlineEnd,
        child: InputGroupButton(
          size: InputGroupButtonSize.iconSm,
          semanticLabel: 'Show password',
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
