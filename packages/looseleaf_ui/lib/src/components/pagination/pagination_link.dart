import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';

/// One page of a [Pagination]: a ghost [Button], or a highlighter one for
/// the page you are on ([isActive], read as selected).
///
/// Mirrors `PaginationLink` in upstream `src/components/ui/pagination.tsx`.
class PaginationLink extends StatelessWidget {
  const PaginationLink({
    super.key,
    required this.child,
    this.onPressed,
    this.isActive = false,
    this.disabled = false,
    this.size = ButtonSize.icon,
    this.leading,
    this.trailing,
    this.seed,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;

  /// The current page: the secondary highlighter instead of the ghost.
  final bool isActive;

  final bool disabled;
  final ButtonSize size;
  final Widget? leading;
  final Widget? trailing;

  /// Pins the hand of the button.
  final String? seed;

  /// The accessible name, such as "Go to page 2".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    selected: isActive,
    child: Button(
      variant: switch (isActive) {
        true => ButtonVariant.secondary,
        false => ButtonVariant.ghost,
      },
      size: size,
      disabled: disabled,
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      seed: seed,
      semanticLabel: semanticLabel,
      child: child,
    ),
  );
}
