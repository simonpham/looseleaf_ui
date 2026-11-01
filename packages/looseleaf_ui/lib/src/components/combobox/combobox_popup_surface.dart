import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sheet the combobox popup sits on.
///
/// Upstream draws `PopoverContent` on a `Paper` slip (`stock="slip"`,
/// `edge="cut"`, a lifted shadow); until the Paper widget is ported this
/// is a plain slip-colored fill, to be swapped for it.
class ComboboxPopupSurface extends StatelessWidget {
  const ComboboxPopupSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: LooseleafTheme.of(context).colors.slip,
    child: child,
  );
}
