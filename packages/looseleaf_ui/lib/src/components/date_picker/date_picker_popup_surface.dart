import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sheet the date picker's calendar sits on.
///
/// Upstream draws `PopoverContent` on a `Paper` slip; until the Paper
/// widget lands this is a plain slip-colored fill, to be swapped for it.
class DatePickerPopupSurface extends StatelessWidget {
  const DatePickerPopupSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: LooseleafTheme.of(context).colors.slip,
    child: child,
  );
}
