import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// An [Attachment]'s size; `id` is the upstream name.
enum AttachmentSize {
  regular('default'),
  sm('sm'),
  xs('xs');

  const AttachmentSize(this.id);

  /// The upstream name.
  final String id;
}

/// Sizes of an attachment, from the `cva` classes in upstream
/// `src/components/ui/attachment.tsx`.
abstract final class AttachmentMetrics {
  /// `min-w-40`: a horizontal slip's narrowest.
  static const double minWidth = Spacing.d160;

  /// `w-28`: a vertical print with only media.
  static const double printWidth = Spacing.d112;

  /// `w-32`: a vertical print with a caption.
  static const double captionedPrintWidth = Spacing.d128;

  /// `pb-4`: a print's bottom margin when it has neither media nor caption.
  static const double printBottom = Spacing.d16;

  /// `pe-3`: room for the clip on a done slip without actions.
  static const double clipRoom = Spacing.d12;

  /// The gap between the parts.
  static double gap(AttachmentSize size) => switch (size) {
    AttachmentSize.regular => Spacing.d8,
    AttachmentSize.sm => Spacing.d10,
    AttachmentSize.xs => Spacing.d6,
  };

  /// `has-data-[slot=attachment-content]:px-* py-*`.
  static EdgeInsets contentPadding(AttachmentSize size) => switch (size) {
    AttachmentSize.regular => const EdgeInsets.symmetric(
      horizontal: Spacing.d10,
      vertical: Spacing.d8,
    ),
    AttachmentSize.sm => const EdgeInsets.symmetric(
      horizontal: Spacing.d8,
      vertical: Spacing.d6,
    ),
    AttachmentSize.xs => const EdgeInsets.symmetric(
      horizontal: Spacing.d6,
      vertical: Spacing.d4,
    ),
  };

  /// `has-data-[slot=attachment-media]:p-*`, without a caption.
  static EdgeInsets mediaPadding(AttachmentSize size) => switch (size) {
    AttachmentSize.regular => const EdgeInsets.all(Spacing.d10),
    AttachmentSize.sm => const EdgeInsets.all(Spacing.d8),
    AttachmentSize.xs => const EdgeInsets.all(Spacing.d6),
  };

  /// The media square's side in a horizontal slip.
  static double media(AttachmentSize size) => switch (size) {
    AttachmentSize.regular => Spacing.d40,
    AttachmentSize.sm => Spacing.d32,
    AttachmentSize.xs => Spacing.d28,
  };

  /// The icon size inside the media.
  static double mediaIcon(AttachmentSize size, {required bool vertical}) =>
      switch ((vertical, size)) {
        (true, _) => Spacing.d24,
        (false, AttachmentSize.xs) => Spacing.d14,
        (false, _) => Spacing.d16,
      };

  /// `[&>img]:m-[3px]`: the inset of an image in its frame.
  static const double imageInset = Spacing.d3;

  /// `h-2.5`: the progress pill's height.
  static const double progressHeight = Spacing.d10;

  /// `min-w-16`.
  static const double progressMinWidth = Spacing.d64;

  /// `mt-1.5`.
  static const double progressGap = Spacing.d6;

  /// `mt-0.5`: the description under the title.
  static const double descriptionGap = Spacing.d2;

  /// `-top-3 end-1.5`: the paper clip of a done slip.
  static const double clipTop = -Spacing.d12;
  static const double clipEnd = Spacing.d6;
  static const double clipSize = 30;

  /// `-top-2.5`, 52 × 18: the tape of a done print.
  static const double tapeTop = -Spacing.d10;
  static const double tapeLength = 52;
  static const double tapeHeight = 18;

  /// `top-2 end-2`: where a print's actions sit.
  static const double printActionsInset = Spacing.d8;

  /// The text size: 15 px, 14 px for small sizes.
  static double textSize(AttachmentSize size) => switch (size) {
    AttachmentSize.regular => 15,
    _ => 14,
  };

  /// `leading-tight`.
  static const double lineHeight = 1.25;

  /// `animate-pulse`: one breath, 1 → 0.5 → 1.
  static const Duration pulse = Duration(seconds: 2);
}
