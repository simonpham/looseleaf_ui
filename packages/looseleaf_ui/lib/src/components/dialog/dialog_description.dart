import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What a dialog is for, in small muted ink.
///
/// Mirrors `DialogDescription` in upstream `src/components/ui/dialog.tsx`.
class DialogDescription extends StatelessWidget {
  const DialogDescription(this.child, {super.key});

  /// The description.
  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: DialogMetrics.description(LooseleafTheme.of(context)),
    child: child,
  );
}
