import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_limits.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The limits in small muted text ("Images, PDF up to 5 MB each"), or
/// [child]; nothing when there are no limits.
///
/// Mirrors `DropzoneDescription` in upstream
/// `src/components/ui/dropzone.tsx`.
class DropzoneDescription extends StatelessWidget {
  const DropzoneDescription({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final zone = DropzoneScope.of(context).state;
    final theme = LooseleafTheme.of(context);
    final text = describeLimits(
      accept: zone.accept,
      maxSize: zone.maxSize,
      maxFiles: zone.maxFiles,
      multiple: zone.multiple,
    );
    final content = child;
    if (content == null && text.isEmpty) return const SizedBox.shrink();
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 20 / 14,
        color: theme.colors.inkMuted,
      ),
      child: content ?? Text(text),
    );
  }
}
