import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/alert_dialog/alert_dialog.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The icon at the head of an alert dialog, on a round patch whose [tone]
/// says what kind of question it is: highlighter for a plain confirmation,
/// sky for information, red for danger. 64 px, the icon 32 px; 8 px above
/// the title when stacked.
///
/// Mirrors `AlertDialogMedia` in upstream
/// `src/components/ui/alert-dialog.tsx` (`alertMediaRecipe`).
class AlertDialogMedia extends StatefulWidget {
  const AlertDialogMedia({
    super.key,
    required this.child,
    this.tone = AlertMediaTone.neutral,
    this.seed,
  });

  /// The icon.
  final Widget child;

  /// The patch's colour.
  final AlertMediaTone tone;

  /// Pins the patch.
  final String? seed;

  @override
  State<AlertDialogMedia> createState() => _AlertDialogMediaState();
}

class _AlertDialogMediaState extends State<AlertDialogMedia> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final params = AlertMediaParams(tone: widget.tone);
    final phone =
        DialogContentScope.maybeOf(context)?.phone ??
        DialogMetrics.phone(context);
    final stacked =
        phone ||
        AlertDialogContentScope.sizeOf(context) == AlertDialogSize.small;
    return Padding(
      padding: EdgeInsets.only(
        bottom: switch (stacked) {
          true => Spacing.d8,
          false => 0,
        },
      ),
      child: InkSurface(
        source: RecipeInkSource(
          alertMediaRecipe,
          params,
          json: params.toJson(),
        ),
        seed: inkSeed(widget.seed),
        child: SizedBox.square(
          dimension: Spacing.d64,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(
                size: Spacing.d32,
                color: LooseleafTheme.of(context).colors.ink,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
