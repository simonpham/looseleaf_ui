import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A dialog's name, in the script face at 27 px, set solid; it names the
/// dialog for screen readers.
///
/// Mirrors `DialogTitle` in upstream `src/components/ui/dialog.tsx`.
class DialogTitle extends StatelessWidget {
  const DialogTitle(this.child, {super.key});

  /// The title.
  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: DialogMetrics.title(LooseleafTheme.of(context)),
    child: Semantics(
      container: true,
      header: true,
      namesRoute: true,
      child: child,
    ),
  );
}
