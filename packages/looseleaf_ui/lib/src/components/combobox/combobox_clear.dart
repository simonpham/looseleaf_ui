import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';

/// A small ghost x that clears the choice and hands focus back to the
/// input; hidden while nothing is chosen. Out of the tab order.
///
/// Mirrors `ComboboxClear` in upstream `src/components/ui/combobox.tsx`.
class ComboboxClear extends StatefulWidget {
  const ComboboxClear({super.key, this.semanticLabel = 'Clear'});

  final String semanticLabel;

  @override
  State<ComboboxClear> createState() => _ComboboxClearState();
}

class _ComboboxClearState extends State<ComboboxClear> {
  final FocusNode _focusNode = FocusNode(skipTraversal: true);

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ComboboxScope.of(context).controller;
    if (controller.value.isEmpty ||
        controller.disabled ||
        controller.readOnly) {
      return const SizedBox.shrink();
    }
    return Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.iconXs,
      semanticLabel: widget.semanticLabel,
      focusNode: _focusNode,
      onPressed: () {
        controller.clear();
        controller.inputFocus.requestFocus();
      },
      child: const InkIcon('x'),
    );
  }
}
