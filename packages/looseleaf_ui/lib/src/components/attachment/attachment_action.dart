import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A small ghost icon [Button] for an [AttachmentActions] row.
///
/// ```dart
/// AttachmentAction(
///   semanticLabel: 'Remove field-notes.pdf',
///   onPressed: remove,
///   child: const InkIcon('x'),
/// )
/// ```
///
/// Mirrors `AttachmentAction` in upstream `src/components/ui/attachment.tsx`.
class AttachmentAction extends StatelessWidget {
  const AttachmentAction({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.ghost,
    this.size = ButtonSize.iconXs,
    this.disabled = false,
    this.seed,
    this.focusNode,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The icon.
  final Widget child;

  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;
  final String? seed;
  final FocusNode? focusNode;

  /// The action's name, as the icon has none.
  final String? semanticLabel;

  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) => Button(
    variant: variant,
    size: size,
    onPressed: onPressed,
    disabled: disabled,
    seed: seed,
    focusNode: focusNode,
    semanticLabel: semanticLabel,
    forcedStates: forcedStates,
    child: child,
  );
}
