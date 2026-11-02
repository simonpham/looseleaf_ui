import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_profile/settings_profile.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The profile as others see it: an index card with the name, avatar,
/// handle, bio, website and time zone.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({super.key, required this.values, this.photo});

  static const double _minHeight = 254;
  static const int _bioLines = 3;
  static const double _footRow = 30;

  final Map<String, Object?> values;
  final ImageProvider? photo;

  String _text(String key) => '${values[key] ?? ''}'.trim();

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final name = switch (_text('name')) {
      '' => 'Your name',
      final typed => typed,
    };
    final username = switch (_text('username')) {
      '' => 'username',
      final typed => typed,
    };
    final pronouns = profilePronouns
        .where((choice) => choice.value == values['pronouns'])
        .firstOrNull;
    final zone = profileTimeZones
        .where((choice) => choice.value == values['timezone'])
        .firstOrNull;
    final website = '${values['website'] ?? ''}';
    final photo = this.photo;
    final small = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 15,
      color: theme.colors.ink,
    );
    return Semantics(
      container: true,
      label: 'Preview of your profile card',
      child: IndexCard(
        hole: true,
        flag: Accent.grape,
        seed: 'profile-card',
        tiltDegrees: -0.2,
        maxWidth: double.infinity,
        minHeight: _minHeight,
        children: [
          IndexCardHeader(
            children: [
              IndexCardTitle(Text(name)),
              Avatar(
                size: AvatarSize.sm,
                ring: null,
                children: [
                  if (photo != null) AvatarImage(image: photo),
                  AvatarFallback(name: name),
                ],
              ),
            ],
          ),
          IndexCardContent(
            children: [
              Text(
                '@$username${switch (pronouns) {
                  (value: 'none', label: _) || null => '',
                  (value: _, :final label) => ' · $label',
                }}',
                style: small.copyWith(color: theme.colors.inkSoft),
              ),
              Text(
                switch (_text('bio')) {
                  '' => 'A line or two about you goes here.',
                  final bio => bio,
                },
                maxLines: _bioLines,
                overflow: TextOverflow.ellipsis,
                style: small,
              ),
            ],
          ),
          IndexCardFooter(
            wrap: true,
            spacing: Spacing.d16,
            children: [
              if (website.isNotEmpty)
                _Fact(
                  icon: 'link',
                  height: _footRow,
                  child: Text(
                    website.replaceFirst(RegExp('^https?://'), ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (zone case (value: _, :final label))
                _Fact(
                  icon: 'globe',
                  height: _footRow,
                  child: Text(label),
                ),
              if (values['discoverable'] == false)
                SizedBox(
                  height: _footRow,
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      'not in search',
                      style: TextStyle(color: theme.colors.inkSoft),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.height, required this.child});

  final String icon;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d6,
      children: [
        InkIcon(icon, size: Spacing.d14),
        Flexible(child: child),
      ],
    ),
  );
}
