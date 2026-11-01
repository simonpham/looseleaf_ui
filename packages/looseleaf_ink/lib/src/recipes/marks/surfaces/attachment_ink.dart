import 'package:looseleaf_ink/src/builder/builder.dart';
import 'package:looseleaf_ink/src/core/core.dart';
import 'package:looseleaf_ink/src/draw/draw.dart';
import 'package:looseleaf_ink/src/geom/geom.dart';
import 'package:looseleaf_ink/src/pen/pen.dart';
import 'package:looseleaf_ink/src/recipes/framework/framework.dart';

/// An attachment's upload state.
enum AttachmentState { idle, uploading, processing, error, done }

/// How an attachment lays out its media and text.
enum AttachmentOrientation { horizontal, vertical }

/// Attachment recipe params.
///
/// Mirrors `AttachmentParams` in `src/lib/ink/recipes/attachment-ink.ts`.
final class AttachmentParams {
  /// Params.
  const AttachmentParams({
    required this.state,
    required this.orientation,
    this.interactive,
  });

  final AttachmentState state;
  final AttachmentOrientation orientation;

  /// Draws a hover wash.
  final bool? interactive;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'state': state.name,
    'orientation': orientation.name,
    if (interactive case final bool i) 'interactive': i,
  };
}

/// An attachment card: dashed while idle, red when failed, pencil outline
/// otherwise, a hover wash when interactive and a lazy focus ring.
///
/// Mirrors `attachmentRecipe` in `src/lib/ink/recipes/attachment-ink.ts`.
final Recipe<AttachmentParams> attachmentRecipe =
    defineRecipe<AttachmentParams>(
      id: 'attachment',
      kind: 'attachment',
      layers: const [LayerName.rest, LayerName.hover, LayerName.focus],
      lazy: const [LayerName.focus],
      pad: 12,
      draw: _drawAttachment,
    );

void _drawAttachment(
  Ink ink,
  Box size,
  AttachmentParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final state = params.state;
  final r = switch (params.orientation) {
    AttachmentOrientation.vertical => 2.5,
    AttachmentOrientation.horizontal => clamp(h * 0.09, 3, 5),
  };
  ctx.lazy(LayerName.focus, (f) => focusRing(f, 0, 0, w, h, r: r));
  if (ctx.lazyOnly) return;
  final body = roundRectPoly(1.5, 1.5, w - 3, h - 3, r);
  ink.layer(LayerName.rest, () {
    if (state == AttachmentState.idle) {
      dashedBox(
        ink,
        0,
        0,
        w,
        h,
        r: r,
        pen: PenName.pencil,
        opts: const StrokeOpts(color: PaintKey.pencilMark),
      );
      return;
    }
    if (state == AttachmentState.error) {
      wash(ink, body, PaintKey.red, alpha: 0.1, material: Material.wash);
      box(ink, 0, 0, w, h, pen: PenName.red, corner: r);
      return;
    }
    final pen = switch (ctx.calm) {
      true => PenName.pencilFine,
      false => PenName.pencil,
    };
    final alpha = switch (state) {
      AttachmentState.done => 0.55,
      _ => 0.8,
    };
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: pen,
      corner: r,
      opts: StrokeOpts(alpha: alpha),
    );
  });
  if (params.interactive ?? false) {
    ink.layer(LayerName.hover, () {
      final alpha = switch (ctx.calm) {
        true => 0.3,
        false => 0.4,
      };
      wash(ink, body, PaintKey.hi, alpha: alpha);
    });
  }
}

/// The attachment media slot: a generic file icon or an image.
enum AttachmentMediaVariant { icon, image }

/// Attachment media recipe params.
///
/// Mirrors `AttachmentMediaParams` in `src/lib/ink/recipes/attachment-ink.ts`.
final class AttachmentMediaParams {
  /// Params.
  const AttachmentMediaParams({required this.state, required this.variant});

  final AttachmentState state;
  final AttachmentMediaVariant variant;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    'state': state.name,
    'variant': variant.name,
  };
}

/// The attachment's media tile: a paper (or red) blot for icons and a fine
/// outline.
///
/// Mirrors `attachmentMediaRecipe` in `src/lib/ink/recipes/attachment-ink.ts`.
final Recipe<AttachmentMediaParams> attachmentMediaRecipe =
    defineRecipe<AttachmentMediaParams>(
      id: 'attachment-media',
      kind: 'media',
      layers: const [LayerName.rest],
      pad: 6,
      draw: _drawMedia,
    );

void _drawMedia(
  Ink ink,
  Box size,
  AttachmentMediaParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  final err = params.state == AttachmentState.error;
  final body = roundRectPoly(1.2, 1.2, w - 2.4, h - 2.4, 2.5);
  ink.layer(LayerName.rest, () {
    if (params.variant == AttachmentMediaVariant.icon) {
      ink.part(
        'fill',
        () => blobFill(
          ink,
          body,
          switch (err) {
            true => PaintKey.red,
            false => PaintKey.paperShade,
          },
          alpha: switch (err) {
            true => 0.22,
            false => 0.95,
          },
          mis: switch (ctx.calm) {
            true => null,
            false => 1.4,
          },
          material: Material.wash,
        ),
      );
    }
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: switch (err) {
        true => PenName.redFine,
        false => PenName.pencilFine,
      },
      corner: 2.5,
      opts: const StrokeOpts(alpha: 0.85),
    );
  });
}

/// Attachment progress recipe params.
///
/// Mirrors the params of `attachmentProgressRecipe` in
/// `src/lib/ink/recipes/attachment-ink.ts`.
final class AttachmentProgressParams {
  /// Params.
  const AttachmentProgressParams({this.indeterminate});

  final bool? indeterminate;

  /// Upstream's params object, for memo keys.
  Map<String, Object?> toJson() => {
    if (indeterminate case final bool i) 'indeterminate': i,
  };
}

/// The upload progress pill: a paper track, a marker bar part and an
/// outline.
///
/// Mirrors `attachmentProgressRecipe` in
/// `src/lib/ink/recipes/attachment-ink.ts`.
final Recipe<AttachmentProgressParams> attachmentProgressRecipe =
    defineRecipe<AttachmentProgressParams>(
      id: 'attachment-progress',
      kind: 'progress',
      layers: const [LayerName.rest],
      pad: 6,
      draw: _drawProgress,
    );

void _drawProgress(
  Ink ink,
  Box size,
  AttachmentProgressParams params,
  RecipeContext ctx,
) {
  final Box(:w, :h) = size;
  ink.layer(LayerName.rest, () {
    ink
      ..part(
        'track',
        () => wash(
          ink,
          pillPoly(1.5, 1.5, w - 3, h - 3),
          PaintKey.paperShade,
          alpha: 0.8,
          material: Material.wash,
        ),
      )
      ..group(GroupAttrs(part: 'bar'), () {
        solidFill(
          ink,
          pillPoly(2.4, 2.4, w - 4.8, h - 4.8),
          PaintKey.marker,
          alpha: 0.94,
        );
      });
    box(
      ink,
      0,
      0,
      w,
      h,
      pen: switch (ctx.calm) {
        true => PenName.pencilFine,
        false => PenName.inkFine,
      },
      corner: h / 2,
    );
  });
}
