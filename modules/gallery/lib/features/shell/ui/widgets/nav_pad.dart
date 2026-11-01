import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The notepad the side nav is written on, held by a binder clip.
///
/// Mirrors `NavPad` in upstream `src/docs/shell/NavPad.tsx`.
class NavPad extends StatelessWidget {
  const NavPad({super.key, required this.child});

  /// The nav.
  final Widget child;

  static const double width = 256;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Paper(
      stock: StockName.pad,
      tilt: false,
      fastener: FastenerKind.binderClip,
      seed: 'docs-pad',
      padding: const EdgeInsets.only(top: Spacing.d24),
      child: SizedBox.expand(
        child: ScrollArea(
          seed: 'docs-pad|scroll',
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.d8,
              vertical: Spacing.d8,
            ),
            child: child,
          ),
        ),
      ),
    ),
  );
}
