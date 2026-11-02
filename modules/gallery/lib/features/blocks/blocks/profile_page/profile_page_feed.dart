import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/profile_page/profile_page.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Lately": the activity feed under Today, Yesterday and Last week markers.
class ProfilePageFeed extends StatelessWidget {
  const ProfilePageFeed({super.key, required this.feed});

  final List<ProfilePageEntry> feed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Paper(
      tiltDegrees: 0.25,
      seed: 'profile-feed',
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.d24,
        vertical: Spacing.d20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d8,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Lately',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 30,
                cssLineHeight: 1,
                fontWeight: FontWeight.w600,
                color: theme.colors.ink,
              ),
            ),
          ),
          for (final day in profilePageDays)
            Semantics(
              container: true,
              label: day,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Marker(
                    variant: MarkerVariant.separator,
                    children: [MarkerContent(child: Text(day))],
                  ),
                  ItemGroup(
                    children: [
                      for (final entry in feed.where((e) => e.day == day))
                        InkItem(
                          size: ItemSize.sm,
                          children: [
                            ItemMedia(
                              variant: ItemMediaVariant.icon,
                              child: InkIcon(entry.icon),
                            ),
                            ItemContent(
                              children: [
                                ItemTitle(Text(entry.title)),
                                ItemDescription(
                                  Text('${entry.where} · ${entry.time}'),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
