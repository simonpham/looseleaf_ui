import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Stands for the pages left out: three soft dots in a 36 square. Hidden
/// from screen readers, like upstream's `aria-hidden` span.
///
/// Mirrors `PaginationEllipsis` in upstream
/// `src/components/ui/pagination.tsx`.
class PaginationEllipsis extends StatelessWidget {
  const PaginationEllipsis({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: Spacing.d36,
      child: Center(
        child: InkIcon(
          'ellipsis',
          size: Spacing.d16,
          color: LooseleafTheme.of(context).colors.inkSoft,
        ),
      ),
    ),
  );
}
