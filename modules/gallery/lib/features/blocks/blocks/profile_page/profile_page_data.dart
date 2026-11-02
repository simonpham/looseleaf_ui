import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A number on the profile's stat row.
typedef ProfilePageStat = ({
  String id,
  String label,
  String value,
  String note,
});

/// Pages written in one week.
typedef ProfilePageWeek = ({String label, int pages});

/// A notebook on the shelf; a black cover when [tone] is null.
typedef ProfilePageNotebook = ({Accent? tone, String name, int pages});

/// A sticker to earn; [earned] is null until it is.
typedef ProfilePageBadge = ({
  String id,
  String sticker,
  String name,
  String how,
  String? earned,
});

/// A line in the activity feed.
typedef ProfilePageEntry = ({
  String id,
  String day,
  String icon,
  String title,
  String where,
  String time,
});

/// Who the page is about.
class ProfilePageProfile {
  const ProfilePageProfile({
    required this.name,
    required this.handle,
    required this.pronouns,
    required this.place,
    required this.joined,
    required this.website,
    required this.bio,
    required this.followers,
    required this.following,
    required this.topics,
    this.stats = profilePageStats,
    this.streakDays = profilePageStreakDays,
    this.weeks = profilePageWeeks,
    this.feed = profilePageFeed,
    this.shelf = profilePageShelf,
    this.badges = profilePageBadges,
  });

  final String name;
  final String handle;
  final String pronouns;
  final String place;
  final String joined;
  final String website;
  final String bio;
  final int followers;
  final int following;
  final List<String> topics;
  final List<ProfilePageStat> stats;
  final int streakDays;
  final List<ProfilePageWeek> weeks;
  final List<ProfilePageEntry> feed;
  final List<ProfilePageNotebook> shelf;
  final List<ProfilePageBadge> badges;
}

const profilePageProfile = ProfilePageProfile(
  name: 'Jo Delacroix',
  handle: 'jo_writes',
  pronouns: 'she / her',
  place: 'Lisbon',
  joined: 'March 2024',
  website: 'jo.looseleaf.example',
  bio:
      'I write in the margins. Letterpress on weekends, tea all week, and a running argument with a dead author about semicolons.',
  followers: 312,
  following: 148,
  topics: ['Letterpress', 'Recipes', 'Margins', 'Tea'],
);

const List<ProfilePageStat> profilePageStats = [
  (
    id: 'pages',
    label: 'Pages written',
    value: '1,284',
    note: 'up 12% on last month',
  ),
  (id: 'books', label: 'Notebooks', value: '12', note: '3 of them full'),
  (id: 'words', label: 'Words a day', value: '640', note: 'steady since June'),
];

const List<ProfilePageWeek> profilePageWeeks = [
  (label: 'Aug 4 to 10', pages: 28),
  (label: 'Aug 11 to 17', pages: 34),
  (label: 'Aug 18 to 24', pages: 19),
  (label: 'Aug 25 to 31', pages: 41),
  (label: 'Sep 1 to 7', pages: 12),
  (label: 'Sep 8 to 14', pages: 36),
  (label: 'Sep 15 to 21', pages: 30),
  (label: 'Sep 22 to 28', pages: 22),
];

const profilePageStreakDays = 23;

const List<String> profilePageDays = ['Today', 'Yesterday', 'Last week'];

const List<ProfilePageEntry> profilePageFeed = [
  (
    id: 'e1',
    day: 'Today',
    icon: 'pencil',
    title: 'Finished “Porridge, the slow way”',
    where: 'Recipes',
    time: '9:12',
  ),
  (
    id: 'e2',
    day: 'Today',
    icon: 'message-square',
    title: 'Answered a question from Nell about deckle edges',
    where: 'Letterpress club',
    time: '8:40',
  ),
  (
    id: 'e3',
    day: 'Yesterday',
    icon: 'book-open',
    title: 'Read “On owning books” for the seventh time',
    where: 'Reading',
    time: '21:05',
  ),
  (
    id: 'e4',
    day: 'Yesterday',
    icon: 'star',
    title: 'Earned a sticker: 100 pages in a month',
    where: 'Stickers',
    time: '18:30',
  ),
  (
    id: 'e5',
    day: 'Last week',
    icon: 'bookmark',
    title: 'Pinned “Lisbon, three days” to the top of Trips',
    where: 'Trips',
    time: 'Tue',
  ),
];

const List<ProfilePageNotebook> profilePageShelf = [
  (tone: Accent.tomato, name: 'Field notes', pages: 48),
  (tone: Accent.teal, name: 'Recipes', pages: 31),
  (tone: Accent.sky, name: 'Sketches', pages: 22),
  (tone: Accent.grape, name: 'Letters', pages: 64),
  (tone: null, name: 'Accounts', pages: 9),
];

const List<ProfilePageBadge> profilePageBadges = [
  (
    id: 'first',
    sticker: 'first-place',
    name: 'First notebook',
    how: 'Fill one notebook',
    earned: 'Apr 2024',
  ),
  (
    id: 'hundred',
    sticker: 'hundred',
    name: 'A hundred pages',
    how: 'Write 100 pages in a month',
    earned: 'Sep 2026',
  ),
  (
    id: 'rocket',
    sticker: 'rocket',
    name: 'Early bird',
    how: 'Join in the first year',
    earned: 'Mar 2024',
  ),
  (
    id: 'owl',
    sticker: 'owl',
    name: 'Night owl',
    how: 'Write after midnight, ten times',
    earned: 'Jun 2025',
  ),
  (
    id: 'tea',
    sticker: 'teacup',
    name: 'Tea break',
    how: 'Take a break every day for a week',
    earned: 'Nov 2024',
  ),
  (
    id: 'marker',
    sticker: 'highlighter',
    name: 'Margin note',
    how: 'Mark up 50 lines',
    earned: null,
  ),
  (
    id: 'party',
    sticker: 'party-popper',
    name: 'Full house',
    how: 'Fill ten notebooks',
    earned: null,
  ),
  (
    id: 'member',
    sticker: 'stamp-member',
    name: 'Club member',
    how: 'Join a club',
    earned: null,
  ),
];
