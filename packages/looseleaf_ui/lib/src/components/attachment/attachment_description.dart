import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_metrics.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The small line under an [AttachmentTitle]: a size, a status, an error
/// (in red). 14 px muted, one line, cut with an ellipsis.
///
/// Mirrors `AttachmentDescription` in upstream
/// `src/components/ui/attachment.tsx`.
class AttachmentDescription extends StatelessWidget {
  const AttachmentDescription({super.key, required this.child});

  /// The line, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final error = AttachmentScope.of(context).state == AttachmentState.error;
    return Padding(
      padding: const EdgeInsets.only(top: AttachmentMetrics.descriptionGap),
      child: DefaultTextStyle.merge(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: 14,
          cssLineHeight: 20 / 14,
          color: switch (error) {
            true => theme.colors.red,
            false => theme.colors.inkMuted,
          },
        ),
        child: child,
      ),
    );
  }
}
