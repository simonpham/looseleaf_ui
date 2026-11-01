import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The area's line in script: "Drop files here or browse", with "browse"
/// in blue felt on a wavy underline.
///
/// Mirrors `DropzoneTitle` in upstream `src/components/ui/dropzone.tsx`.
class DropzoneTitle extends StatelessWidget {
  const DropzoneTitle({super.key, this.child});

  /// Replaces the default line.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final zone = DropzoneScope.of(context).state;
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.script,
        cssSize: 23.2,
        cssLineHeight: 1.25,
        fontWeight: FontWeight.w700,
      ),
      child:
          child ??
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: switch (zone.multiple) {
                    true => 'Drop files here or ',
                    false => 'Drop a file here or ',
                  },
                ),
                TextSpan(
                  text: 'browse',
                  style: TextStyle(
                    color: switch (zone.disabled) {
                      true => colors.pencilText,
                      false => colors.inkYou,
                    },
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.wavy,
                    decorationColor: switch (zone.disabled) {
                      true => colors.pencilText,
                      false => colors.inkYou,
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
