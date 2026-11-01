import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_scope.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The files the latest batch turned away, each with its reasons, in red
/// and announced as an alert.
///
/// Mirrors `DropzoneRejections` in upstream `src/components/ui/dropzone.tsx`.
class DropzoneRejections extends StatelessWidget {
  const DropzoneRejections({super.key});

  @override
  Widget build(BuildContext context) {
    final zone = DropzoneScope.of(context).state;
    final rejections = zone.rejections;
    if (rejections.isEmpty) return const SizedBox.shrink();
    final theme = LooseleafTheme.of(context);
    final red = theme.colors.red;
    return Semantics(
      liveRegion: true,
      container: true,
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 14,
          cssLineHeight: 20 / 14,
          color: red,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d4,
          children: [
            for (final rejection in rejections)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d6,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.d2),
                    child: InkIcon(
                      'circle-alert',
                      size: Spacing.d16,
                      color: red,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rejection.errors.map((error) => error.message).join(' '),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
