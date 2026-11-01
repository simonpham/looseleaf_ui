import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_scope.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The dashed pencil area: tap it, or press Enter or Space on it, to
/// browse; it turns solid while files are dragged over.
///
/// Mirrors `DropzoneArea` in upstream `src/components/ui/dropzone.tsx`.
class DropzoneArea extends StatefulWidget {
  const DropzoneArea({
    super.key,
    required this.children,
    this.seed,
    this.semanticLabel,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// Usually a [DropzoneIcon], a [DropzoneTitle] and a
  /// [DropzoneDescription], centered with 6 px between them.
  final List<Widget> children;

  /// Pins the hand.
  final String? seed;

  /// The accessible name; the children's text when null.
  final String? semanticLabel;

  final bool autofocus;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  /// `min-h-40 compact:min-h-32 calm:min-h-24`.
  static const ByDensity<double> minHeight = ByDensity(
    comfortable: Spacing.d160,
    compact: Spacing.d128,
    calm: Spacing.d96,
  );

  /// `p-6 compact:p-5 calm:p-3`.
  static const ByDensity<double> padding = ByDensity(
    comfortable: Spacing.d24,
    compact: Spacing.d20,
    calm: Spacing.d12,
  );

  @override
  State<DropzoneArea> createState() => _DropzoneAreaState();
}

class _DropzoneAreaState extends State<DropzoneArea> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final zone = DropzoneScope.of(context).state;
    final theme = LooseleafTheme.of(context);
    final disabled = zone.disabled;
    final params = DropzoneParams(
      over: zone.dragOver,
      invalid: zone.invalid && !disabled,
      disabled: disabled,
    );
    final pad = DropzoneArea.padding.resolve(theme.density);
    return Semantics(
      container: true,
      button: true,
      enabled: !disabled,
      label: widget.semanticLabel,
      child: InkInteraction(
        enabled: !disabled,
        onActivate: zone.browse,
        states: {
          ...widget.forcedStates,
          if (zone.dragOver) InkState.open,
          if (zone.invalid && !disabled) InkState.invalid,
        },
        autofocus: widget.autofocus,
        disabledMouseCursor: SystemMouseCursors.forbidden,
        builder: (context, states) => InkContent(
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 16,
            cssLineHeight: 1.5,
            color: switch (disabled) {
              true => theme.colors.pencilText,
              false => theme.colors.ink,
            },
          ),
          child: DefaultTextStyle.merge(
            textAlign: TextAlign.center,
            child: InkSurface(
              source: RecipeInkSource(
                dropzoneRecipe,
                params,
                json: params.toJson(),
              ),
              seed: inkSeed(widget.seed),
              states: states,
              still: true,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: DropzoneArea.minHeight.resolve(theme.density),
                ),
                child: Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: Spacing.d6,
                    children: widget.children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
