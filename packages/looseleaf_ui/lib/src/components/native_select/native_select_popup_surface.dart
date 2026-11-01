import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sheet a [NativeSelect]'s list sits on.
///
/// A stand-in until the `Paper` surface lands: upstream asks the browser's
/// popup for `bg-popover` (a slip of paper) and the popover's ink, which
/// this fills in without a drawn edge.
class NativeSelectPopupSurface extends StatelessWidget {
  const NativeSelectPopupSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: LooseleafTheme.of(context).colors.slip, child: child);
}
