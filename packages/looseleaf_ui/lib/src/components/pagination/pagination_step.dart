import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/pagination/pagination_link.dart';

/// The step back of a [Pagination]: a chevron and "Previous" (the word
/// hides below 640 wide). Read as "Go to previous page".
///
/// Mirrors `PaginationPrevious` in upstream
/// `src/components/ui/pagination.tsx`.
class PaginationPrevious extends StatelessWidget {
  const PaginationPrevious({
    super.key,
    this.onPressed,
    this.disabled = false,
    this.label = 'Previous',
    this.size = ButtonSize.regular,
    this.seed,
  });

  final VoidCallback? onPressed;
  final bool disabled;
  final String label;

  /// The button size (upstream `size`, `default` unless given); below
  /// 640 wide the matching square icon size.
  final ButtonSize size;
  final String? seed;

  @override
  Widget build(BuildContext context) => PaginationStep(
    onPressed: onPressed,
    disabled: disabled,
    label: label,
    semanticLabel: 'Go to previous page',
    icon: 'chevron-left',
    before: true,
    size: size,
    seed: seed,
  );
}

/// The step on of a [Pagination]: "Next" and a chevron (the word hides
/// below 640 wide). Read as "Go to next page".
///
/// Mirrors `PaginationNext` in upstream `src/components/ui/pagination.tsx`.
class PaginationNext extends StatelessWidget {
  const PaginationNext({
    super.key,
    this.onPressed,
    this.disabled = false,
    this.label = 'Next',
    this.size = ButtonSize.regular,
    this.seed,
  });

  final VoidCallback? onPressed;
  final bool disabled;
  final String label;

  /// The button size (upstream `size`, `default` unless given); below
  /// 640 wide the matching square icon size.
  final ButtonSize size;
  final String? seed;

  @override
  Widget build(BuildContext context) => PaginationStep(
    onPressed: onPressed,
    disabled: disabled,
    label: label,
    semanticLabel: 'Go to next page',
    icon: 'chevron-right',
    before: false,
    size: size,
    seed: seed,
  );
}

/// The shared body of [PaginationPrevious] and [PaginationNext].
class PaginationStep extends StatelessWidget {
  const PaginationStep({
    super.key,
    required this.onPressed,
    required this.disabled,
    required this.label,
    required this.semanticLabel,
    required this.icon,
    required this.before,
    this.size = ButtonSize.regular,
    this.seed,
  });

  final VoidCallback? onPressed;
  final bool disabled;
  final String label;
  final String semanticLabel;

  /// The chevron's icon name; it mirrors itself right to left.
  final String icon;

  /// Whether the chevron comes before the word.
  final bool before;

  /// The size with the word; the icon size of the same height without.
  final ButtonSize size;
  final String? seed;

  /// Tailwind's `sm` breakpoint, from where the word shows.
  static const double smallWidth = 640;

  @override
  Widget build(BuildContext context) {
    final wide = (MediaQuery.maybeSizeOf(context)?.width ?? 0) >= smallWidth;
    final chevron = InkIcon(icon);
    if (!wide) {
      return PaginationLink(
        onPressed: onPressed,
        disabled: disabled,
        size: switch (size) {
          ButtonSize.xs || ButtonSize.iconXs => ButtonSize.iconXs,
          ButtonSize.sm || ButtonSize.iconSm => ButtonSize.iconSm,
          ButtonSize.lg || ButtonSize.iconLg => ButtonSize.iconLg,
          ButtonSize.regular || ButtonSize.icon => ButtonSize.icon,
        },
        semanticLabel: semanticLabel,
        seed: seed,
        child: chevron,
      );
    }
    return PaginationLink(
      onPressed: onPressed,
      disabled: disabled,
      size: size,
      semanticLabel: semanticLabel,
      seed: seed,
      leading: switch (before) {
        true => chevron,
        false => null,
      },
      trailing: switch (before) {
        true => null,
        false => chevron,
      },
      child: ExcludeSemantics(child: Text(label)),
    );
  }
}
