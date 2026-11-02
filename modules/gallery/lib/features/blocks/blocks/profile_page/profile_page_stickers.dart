import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/profile_page/profile_page.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The Stickers tab: earned stickers in colour, the rest greyed out with
/// how to earn them.
class ProfilePageStickers extends StatelessWidget {
  const ProfilePageStickers({
    super.key,
    required this.badges,
    required this.width,
  });

  final List<ProfilePageBadge> badges;

  /// The page's content width, for upstream's `@container/profile` queries.
  final double width;

  static const double _stickerSize = 88;
  static const _grayscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final muted = theme.colors.inkMuted;
    final small = theme.typography.interface(cssSize: 14, color: muted);
    final earned = badges.where((badge) => badge.earned != null).length;
    final columns = switch (width) {
      >= 768 => 4,
      >= 512 => 3,
      _ => 2,
    };
    Widget tile(ProfilePageBadge badge) {
      final sticker = Sticker(
        badge.sticker,
        size: _stickerSize,
        seed: badge.id,
        shadow: badge.earned != null,
      );
      final (icon, line) = switch (badge.earned) {
        final date? => ('check', 'Earned $date'),
        null => ('lock', badge.how),
      };
      return Column(
        spacing: Spacing.d8,
        children: [
          switch (badge.earned) {
            null => Opacity(
              opacity: 0.35,
              child: ColorFiltered(colorFilter: _grayscale, child: sticker),
            ),
            _ => sticker,
          },
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: theme.typography
                .interface(color: theme.colors.ink)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d4,
            children: [
              InkIcon(icon, size: Spacing.d14, color: muted),
              Flexible(
                child: Text(line, style: small, textAlign: TextAlign.center),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$earned',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
              TextSpan(text: ' of ${badges.length} stickers earned.'),
            ],
          ),
          style: theme.typography.interface(color: muted),
        ),
        Semantics(
          label: 'Stickers',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d32,
            children: [
              for (var start = 0; start < badges.length; start += columns)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d24,
                  children: [
                    for (var i = start; i < start + columns; i++)
                      Expanded(
                        child: switch (badges.elementAtOrNull(i)) {
                          final badge? => tile(badge),
                          null => const SizedBox.shrink(),
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
