import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "copy", turning into a green "copied" for two seconds after [onCopy].
class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.onCopy});

  final VoidCallback onCopy;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  Timer? _reset;
  bool _copied = false;

  void _copy() {
    widget.onCopy();
    _reset?.cancel();
    _reset = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
    setState(() => _copied = true);
  }

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final (label, icon, color) = switch (_copied) {
      true => ('copied', 'check', theme.colors.green),
      false => ('copy', 'copy', theme.colors.inkMuted),
    };
    return Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.xs,
      onPressed: _copy,
      semanticLabel: switch (_copied) {
        true => 'Copied',
        false => 'Copy code',
      },
      leading: InkIcon(icon, size: Spacing.d16, color: color),
      child: Text(
        label,
        style: theme.typography.stamp(cssSize: 13, color: color),
      ),
    );
  }
}
