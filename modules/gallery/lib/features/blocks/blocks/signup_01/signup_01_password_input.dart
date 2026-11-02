import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A password input with a button that shows or hides what was typed.
class Signup01PasswordInput extends StatefulWidget {
  const Signup01PasswordInput({
    super.key,
    this.focusNode,
    this.invalid = false,
    this.onChanged,
    this.toggleLabel = 'Show password',
  });

  final FocusNode? focusNode;
  final bool invalid;
  final ValueChanged<String>? onChanged;
  final String toggleLabel;

  @override
  State<Signup01PasswordInput> createState() => _Signup01PasswordInputState();
}

class _Signup01PasswordInputState extends State<Signup01PasswordInput> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) => InputGroup(
    focusNode: widget.focusNode,
    invalid: widget.invalid,
    children: [
      InputGroupInput(obscureText: !_shown, onChanged: widget.onChanged),
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
