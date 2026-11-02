import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/profile_page/profile_page.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The Activity tab: the weekly tally beside the feed, stacked when narrow.
class ProfilePageActivity extends StatelessWidget {
  const ProfilePageActivity({
    super.key,
    required this.weeks,
    required this.feed,
    required this.width,
  });

  final List<ProfilePageWeek> weeks;
  final List<ProfilePageEntry> feed;

  /// The page's content width, for upstream's `@container/profile` queries.
  final double width;

  @override
  Widget build(BuildContext context) {
    final tally = ProfilePageWeeklyTally(weeks: weeks, width: width);
    final lately = ProfilePageFeed(feed: feed);
    if (width >= 896) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d40,
          children: [
            Expanded(child: tally),
            Expanded(
              child: Align(alignment: Alignment.topCenter, child: lately),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d40,
      children: [tally, lately],
    );
  }
}
