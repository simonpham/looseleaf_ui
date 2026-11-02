import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/profile_page/profile_page.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A writer's profile: a taped polaroid, bio, follow and message buttons,
/// a stat row with a writing streak, then Activity, Notebooks and Stickers
/// tabs.
///
/// Mirrors upstream `src/blocks/profile-page/page.tsx`.
class ProfilePageBlock extends StatefulWidget {
  const ProfilePageBlock({
    super.key,
    this.profile = profilePageProfile,
    this.defaultFollowing = false,
    this.onFollowChange,
    this.onMessage,
  });

  final ProfilePageProfile profile;
  final bool defaultFollowing;
  final ValueChanged<bool>? onFollowChange;
  final VoidCallback? onMessage;

  @override
  State<ProfilePageBlock> createState() => _ProfilePageBlockState();
}

class _ProfilePageBlockState extends State<ProfilePageBlock> {
  late bool _following = widget.defaultFollowing;

  static const double _maxWidth = 1152;

  void _follow(bool next) {
    setState(() => _following = next);
    widget.onFollowChange?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.profile;
    final wide = MediaQuery.sizeOf(context).width >= 640;
    return Semantics(
      container: true,
      label: '${person.name}, profile',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: switch (wide) {
                true => Spacing.d32,
                false => Spacing.d16,
              },
              vertical: Spacing.d48,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d48,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d40,
                      children: [
                        ProfilePageHeader(
                          profile: person,
                          width: width,
                          following: _following,
                          onFollow: _follow,
                          onMessage: widget.onMessage,
                        ),
                        ProfilePageStats(profile: person, width: width),
                      ],
                    ),
                    Tabs(
                      defaultValue: 'activity',
                      spacing: Spacing.d24,
                      children: [
                        const SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: TabsList(
                            variant: TabsVariant.line,
                            children: [
                              TabsTrigger(
                                value: 'activity',
                                child: Text('Activity'),
                              ),
                              TabsTrigger(
                                value: 'notebooks',
                                child: Text('Notebooks'),
                              ),
                              TabsTrigger(
                                value: 'stickers',
                                child: Text('Stickers'),
                              ),
                            ],
                          ),
                        ),
                        TabsContent(
                          value: 'activity',
                          child: ProfilePageActivity(
                            weeks: person.weeks,
                            feed: person.feed,
                            width: width,
                          ),
                        ),
                        TabsContent(
                          value: 'notebooks',
                          child: ProfilePageNotebooks(
                            shelf: person.shelf,
                            width: width,
                          ),
                        ),
                        TabsContent(
                          value: 'stickers',
                          child: ProfilePageStickers(
                            badges: person.badges,
                            width: width,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
