import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_scope.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/mascot/mascot.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The area's picture: an upload arrow, or Stubby carrying a page while
/// files are dragged over, lifted 3 px. Decorative.
///
/// Mirrors `DropzoneIcon` in upstream `src/components/ui/dropzone.tsx`.
class DropzoneIcon extends StatelessWidget {
  const DropzoneIcon({super.key, this.child});

  /// Replaces the default picture.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final zone = DropzoneScope.of(context).state;
    final colors = LooseleafTheme.of(context).colors;
    final over = zone.dragOver;
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          end: switch (over) {
            true => -3,
            false => 0,
          },
        ),
        duration: InkMotion.of(context, InkMotion.pop),
        curve: InkMotion.settle,
        builder: (context, lift, child) =>
            Transform.translate(offset: Offset(0, lift), child: child),
        child: SizedBox.square(
          dimension: Spacing.d64,
          child: Center(
            child:
                child ??
                switch (over) {
                  true => const Mascot(pose: 'carry', size: Spacing.d64),
                  false => InkIcon(
                    'upload',
                    size: Spacing.d32,
                    weight: 1.2,
                    color: switch (zone.disabled) {
                      true => colors.pencilText,
                      false => colors.inkSoft,
                    },
                  ),
                },
          ),
        ),
      ),
    );
  }
}
