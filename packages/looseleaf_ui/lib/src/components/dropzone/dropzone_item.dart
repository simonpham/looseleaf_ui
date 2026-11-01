import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_file.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_limits.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_remove_button.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_scope.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Where a [DropzoneItem]'s upload stands.
enum DropzoneUploadStatus { idle, uploading, done, error }

/// One kept file on a pencil rule: a kind icon (or a taped-on photo
/// thumbnail), the name and size, an upload bar while [progress] runs, a
/// green tick when done or a red mark and [error], and an x.
///
/// Mirrors `DropzoneItem` in upstream `src/components/ui/dropzone.tsx`.
class DropzoneItem extends StatelessWidget {
  const DropzoneItem({
    super.key,
    required this.file,
    this.progress,
    this.status = DropzoneUploadStatus.idle,
    this.error,
    this.thumbnail = true,
    this.onRemove,
    this.removeLabel,
    this.seed,
  });

  final DropzoneFile file;

  /// The upload's percent, 0 to 100, shown while [status] is uploading.
  final double? progress;

  final DropzoneUploadStatus status;

  /// The message shown in red when [status] is error.
  final String? error;

  /// Shows [DropzoneFile.preview] instead of the kind icon.
  final bool thumbnail;

  /// Replaces taking the file out of the list.
  final VoidCallback? onRemove;

  /// The x's accessible name; `Remove <name>` when null.
  final String? removeLabel;

  /// Pins the hand of the rule.
  final String? seed;

  static String _iconFor(DropzoneFile file) {
    final type = file.type;
    if (type.startsWith('image/')) return 'image';
    if (RegExp('pdf|text|word|document').hasMatch(type)) return 'file-text';
    if (RegExp('zip|compressed|tar').hasMatch(type)) return 'archive';
    return 'file';
  }

  String get _detail {
    final size = formatBytes(file.size);
    final percent = progress;
    return switch ((status, error, percent)) {
      (DropzoneUploadStatus.error, final message?, _) => message,
      (DropzoneUploadStatus.done, _, _) => '$size, done',
      (DropzoneUploadStatus.uploading, _, final value?) =>
        '$size, ${value.round()}%',
      _ => size,
    };
  }

  @override
  Widget build(BuildContext context) {
    final zone = DropzoneScope.of(context).state;
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final params = DropzoneItemParams(
      status: switch (status) {
        DropzoneUploadStatus.error => DropzoneItemStatus.error,
        DropzoneUploadStatus.done => DropzoneItemStatus.done,
        _ => DropzoneItemStatus.idle,
      },
    );
    final small = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 14,
      cssLineHeight: 20 / 14,
      color: switch (status) {
        DropzoneUploadStatus.error => colors.red,
        _ => colors.inkMuted,
      },
    );
    final percent = progress;
    return InkSurface(
      source: RecipeInkSource(
        dropzoneItemRecipe,
        params,
        json: params.toJson(),
      ),
      seed: seed ?? 'dropzone-item|${file.name}',
      states: {if (status == DropzoneUploadStatus.error) InkState.invalid},
      still: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d4,
          vertical: Spacing.d10,
        ),
        child: DefaultTextStyle.merge(
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 16,
            cssLineHeight: 1.5,
            color: colors.ink,
          ),
          child: Row(
            spacing: Spacing.d12,
            children: [
              ExcludeSemantics(child: _media(colors)),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d2,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: small,
                    ),
                    if (status == DropzoneUploadStatus.uploading &&
                        percent != null)
                      _bar(colors, percent),
                  ],
                ),
              ),
              if (status == DropzoneUploadStatus.done)
                InkIcon('circle-check', size: Spacing.d18, color: colors.green),
              if (status == DropzoneUploadStatus.error)
                InkIcon('circle-alert', size: Spacing.d18, color: colors.red),
              DropzoneRemoveButton(
                label: removeLabel ?? 'Remove ${file.name}',
                disabled: zone.disabled,
                onPressed: onRemove ?? () => zone.remove(file),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _media(LooseleafColors colors) {
    final preview = file.preview;
    if (thumbnail && preview != null) {
      return Transform.rotate(
        angle: -2 * math.pi / 180,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.photo,
            border: Border.all(color: colors.photo, width: Spacing.d2),
            boxShadow: [
              BoxShadow(
                color: colors.shade.withValues(alpha: 0.35),
                offset: const Offset(0, Spacing.d1),
                blurRadius: Spacing.d2,
              ),
            ],
          ),
          child: SizedBox.square(
            dimension: Spacing.d40 - Spacing.d4,
            child: Image(image: preview, fit: BoxFit.cover),
          ),
        ),
      );
    }
    return SizedBox.square(
      dimension: Spacing.d40,
      child: Center(
        child: InkIcon(
          _iconFor(file),
          size: Spacing.d24,
          color: colors.inkSoft,
        ),
      ),
    );
  }

  Widget _bar(LooseleafColors colors, double percent) => Semantics(
    label: 'Uploading ${file.name}',
    value: '${percent.round()}%',
    child: Padding(
      padding: const EdgeInsets.only(top: Spacing.d2),
      child: SizedBox(
        height: Spacing.d6,
        child: ColoredBox(
          color: colors.pencilMark.withValues(alpha: 0.25),
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: percent.clamp(0, 100) / 100,
            child: ColoredBox(color: colors.hiSelect),
          ),
        ),
      ),
    ),
  );
}
