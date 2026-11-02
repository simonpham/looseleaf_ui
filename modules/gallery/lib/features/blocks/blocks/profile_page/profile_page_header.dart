import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/profile_page/profile_page.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The polaroid, name, bio, about line, topics and the follow and message
/// buttons.
class ProfilePageHeader extends StatelessWidget {
  const ProfilePageHeader({
    super.key,
    required this.profile,
    required this.width,
    required this.following,
    required this.onFollow,
    this.onMessage,
  });

  final ProfilePageProfile profile;

  /// The page's content width, for upstream's `@container/profile` queries.
  final double width;
  final bool following;
  final ValueChanged<bool> onFollow;
  final VoidCallback? onMessage;

  static const double _polaroidWidth = 240;

  static String _initials(String name) => name
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final muted = theme.colors.inkMuted;
    final small = theme.typography.interface(cssSize: 14, color: muted);
    final followers =
        profile.followers +
        switch (following) {
          true => 1,
          false => 0,
        };
    final polaroid = Polaroid(
      width: _polaroidWidth,
      tape: PaperTape.top,
      tiltDegrees: -2.5,
      seed: 'profile-polaroid',
      children: [
        PolaroidImage(
          date: "'26 9 25",
          seed: 'profile-window',
          child: ExcludeSemantics(
            child: ColoredBox(
              color: theme.colors.hi.withValues(alpha: 0.6),
              child: Center(
                child: Text(
                  _initials(profile.name),
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 96,
                    cssLineHeight: 1,
                    fontWeight: FontWeight.w700,
                    color: theme.colors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
        PolaroidCaption(
          Text('${profile.name.split(RegExp(r'\s+')).first}, at the desk'),
        ),
      ],
    );
    Widget about(String icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d6,
      children: [
        InkIcon(icon, size: Spacing.d16, color: muted),
        Flexible(child: Text(text, style: small)),
      ],
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d4,
          children: [
            Semantics(
              header: true,
              child: Text(
                profile.name,
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: switch (width >= 512) {
                    true => 60,
                    false => 48,
                  },
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
            ),
            Text(
              '@${profile.handle} · ${profile.pronouns}',
              style: theme.typography.interface(color: muted),
            ),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            profile.bio,
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 18,
              cssLineHeight: 28 / 18,
              color: theme.colors.ink,
            ),
          ),
        ),
        Semantics(
          label: 'About',
          child: Wrap(
            spacing: Spacing.d20,
            runSpacing: Spacing.d4,
            children: [
              about('map', profile.place),
              about('calendar', 'Writing here since ${profile.joined}'),
              about('link', profile.website),
            ],
          ),
        ),
        Semantics(
          label: 'Writes about',
          child: Wrap(
            spacing: Spacing.d8,
            runSpacing: Spacing.d8,
            children: [
              for (final topic in profile.topics)
                Badge(
                  variant: BadgeVariant.secondary,
                  child: Text(topic),
                ),
            ],
          ),
        ),
        Wrap(
          spacing: Spacing.d16,
          runSpacing: Spacing.d12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              toggled: following,
              child: Button(
                variant: switch (following) {
                  true => ButtonVariant.outline,
                  false => ButtonVariant.primary,
                },
                onPressed: () => onFollow(!following),
                leading: InkIcon(switch (following) {
                  true => 'check',
                  false => 'user-plus',
                }),
                child: Text(switch (following) {
                  true => 'Following',
                  false => 'Follow',
                }),
              ),
            ),
            Button(
              variant: ButtonVariant.outline,
              onPressed: onMessage ?? () {},
              leading: const InkIcon('message-square'),
              child: const Text('Message'),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$followers',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.colors.ink,
                    ),
                  ),
                  const TextSpan(text: ' followers · '),
                  TextSpan(
                    text: '${profile.following}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.colors.ink,
                    ),
                  ),
                  const TextSpan(text: ' following'),
                ],
              ),
              style: small,
            ),
          ],
        ),
      ],
    );
    if (width >= 672) {
      return Row(
        spacing: Spacing.d48,
        children: [
          polaroid,
          Expanded(child: details),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d32,
      children: [
        Center(child: polaroid),
        details,
      ],
    );
  }
}
