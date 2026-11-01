import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_metrics.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_scope.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The square at the start of an [Attachment]: a pencil-framed file icon,
/// or an image (a photo in a white frame) when [variant] is
/// [AttachmentMediaVariant.image]. A vertical print's media fills its width.
/// An errored attachment draws it in red.
///
/// ```dart
/// const AttachmentMedia(child: InkIcon('file-text'))
/// ```
///
/// Mirrors `AttachmentMedia` in upstream `src/components/ui/attachment.tsx`.
class AttachmentMedia extends StatefulWidget {
  const AttachmentMedia({
    super.key,
    required this.child,
    this.variant = AttachmentMediaVariant.icon,
    this.color,
    this.seed,
  });

  /// An icon, or the image for [AttachmentMediaVariant.image].
  final Widget child;

  final AttachmentMediaVariant variant;

  /// A tint behind the drawing, like the docs' `bg-sky/45`.
  final Color? color;

  /// Pins the hand.
  final String? seed;

  @override
  State<AttachmentMedia> createState() => _AttachmentMediaState();
}

class _AttachmentMediaState extends State<AttachmentMedia> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final scope = AttachmentScope.of(context);
    final theme = LooseleafTheme.of(context);
    final params = AttachmentMediaParams(
      state: scope.state,
      variant: widget.variant,
    );
    final image = widget.variant == AttachmentMediaVariant.image;
    final faded =
        image &&
        scope.state != AttachmentState.done &&
        scope.state != AttachmentState.idle;
    final color = switch (scope.state) {
      AttachmentState.error => theme.colors.red,
      _ => theme.colors.ink,
    };
    final content = switch (image) {
      true => Padding(
        padding: const EdgeInsets.all(AttachmentMetrics.imageInset),
        child: SizedBox.expand(
          child: FittedBox(fit: BoxFit.cover, child: widget.child),
        ),
      ),
      false => Center(child: widget.child),
    };
    Widget media = InkSurface(
      source: RecipeInkSource(
        attachmentMediaRecipe,
        params,
        json: params.toJson(),
      ),
      seed: inkSeed(widget.seed),
      still: true,
      child: InkContent(
        style: TextStyle(color: color),
        iconSize: AttachmentMetrics.mediaIcon(
          scope.size,
          vertical: scope.vertical,
        ),
        child: content,
      ),
    );
    if (widget.color case final tint?) {
      media = DecoratedBox(
        decoration: BoxDecoration(color: tint),
        child: media,
      );
    }
    if (faded) media = Opacity(opacity: 0.6, child: media);
    return switch (scope.vertical) {
      true => AspectRatio(aspectRatio: 1, child: media),
      false => SizedBox.square(
        dimension: AttachmentMetrics.media(scope.size),
        child: media,
      ),
    };
  }
}
