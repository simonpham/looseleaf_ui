import 'package:gallery/features/blocks/blocks/dashboard_analytics/dashboard_analytics.dart';

/// A date range to look at.
typedef AnalyticsRange = ({String id, String label, int days, String long});

const List<AnalyticsRange> analyticsRanges = [
  (id: '7d', label: '7 days', days: 7, long: 'the last 7 days'),
  (id: '30d', label: '30 days', days: 30, long: 'the last 30 days'),
  (id: '90d', label: '90 days', days: 90, long: 'the last 90 days'),
];

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// JavaScript's `Math.round`: halves go up, also below zero.
int analyticsRound(num value) => (value + 0.5).floor();

/// Whole number with thousands commas: `12,345`.
String analyticsNumber(num value) {
  final sign = switch (value < 0) {
    true => '-',
    false => '',
  };
  final digits = '${analyticsRound(value.abs())}'.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$sign$digits';
}

/// Seconds as `m:ss`.
String analyticsDuration(num seconds) {
  final whole = analyticsRound(seconds);
  return '${whole ~/ 60}:${'${whole % 60}'.padLeft(2, '0')}';
}

/// An ISO date as `Apr 3`.
String analyticsDay(String iso) {
  final [_, month, day] = iso.split('-');
  return '${_months.elementAtOrNull(int.parse(month) - 1) ?? month} ${int.parse(day)}';
}

num _sum(Iterable<num> values) => values.fold<num>(0, (a, b) => a + b);
double _mean(List<num> values) => switch (values.length) {
  0 => 0,
  final count => _sum(values) / count,
};
double _round1(num value) => analyticsRound(value * 10) / 10;

/// Every figure of one date range and of the same span just before it.
class AnalyticsPeriod {
  AnalyticsPeriod(this.days)
    : rows = analyticsDailyRows.sublist(analyticsDailyRows.length - days),
      previous = analyticsDailyRows.sublist(
        analyticsDailyRows.length - 2 * days,
        analyticsDailyRows.length - days,
      );

  final int days;
  final List<AnalyticsDay> rows;
  final List<AnalyticsDay> previous;

  int get visitors => _sum(rows.map((row) => row.$2)).toInt();
  int get pageviews => _sum(rows.map((row) => row.$3)).toInt();
  double get bounce => _round1(_mean([for (final row in rows) row.$4]) / 10);
  double get session => _mean([for (final row in rows) row.$5]);
  int get previousVisitors => _sum(previous.map((row) => row.$2)).toInt();
  int get previousPageviews => _sum(previous.map((row) => row.$3)).toInt();
  double get previousBounce =>
      _round1(_mean([for (final row in previous) row.$4]) / 10);
  double get previousSession => _mean([for (final row in previous) row.$5]);
}

/// The change from [before] to [now] in percent, to one decimal.
double analyticsChange(num now, num before) => switch (before) {
  0 => 0,
  _ => _round1((now - before) / before * 100),
};

/// A number with its sign and unit: `+3.2%`, `-1 pts`.
String analyticsSigned(num value, [String unit = '%']) {
  final sign = switch (value) {
    > 0 => '+',
    < 0 => '-',
    _ => '',
  };
  final magnitude = value.abs();
  final text = switch (magnitude == magnitude.roundToDouble()) {
    true => '${magnitude.round()}',
    false => '$magnitude',
  };
  return '$sign$text$unit';
}

const List<({String source, double share})> analyticsSources = [
  (source: 'Search', share: 0.42),
  (source: 'Direct', share: 0.27),
  (source: 'Social', share: 0.16),
  (source: 'Referral', share: 0.11),
  (source: 'Email', share: 0.04),
];

/// A page in the top pages table.
typedef AnalyticsPage = ({
  String title,
  String path,
  double share,
  int time,
  double bounce,
  double trend,
});

const List<AnalyticsPage> analyticsTopPages = [
  (
    title: 'Home',
    path: '/',
    share: 0.18,
    time: 58,
    bounce: 41.5,
    trend: 3.2,
  ),
  (
    title: 'Why the margin is the best part',
    path: '/journal/why-the-margin-is-the-best-part',
    share: 0.16,
    time: 214,
    bounce: 29.8,
    trend: 18.4,
  ),
  (
    title: 'Washi tape',
    path: '/shop/washi-tape',
    share: 0.13,
    time: 107,
    bounce: 38.2,
    trend: 7.9,
  ),
  (
    title: 'Field notebooks',
    path: '/shop/field-notebooks',
    share: 0.11,
    time: 125,
    bounce: 35.6,
    trend: -2.1,
  ),
  (
    title: 'The journal',
    path: '/journal',
    share: 0.09,
    time: 72,
    bounce: 46,
    trend: -5.4,
  ),
  (
    title: 'About the studio',
    path: '/about',
    share: 0.07,
    time: 86,
    bounce: 52.3,
    trend: 0.8,
  ),
  (
    title: 'Gift wrap',
    path: '/shop/gift-wrap',
    share: 0.06,
    time: 63,
    bounce: 43.7,
    trend: 22.5,
  ),
  (
    title: 'Say hello',
    path: '/contact',
    share: 0.04,
    time: 41,
    bounce: 58.9,
    trend: -1.2,
  ),
];

const List<({String step, double share})> analyticsFunnel = [
  (step: 'Visited the shop', share: 1),
  (step: 'Looked at a notebook', share: 0.38),
  (step: 'Added to basket', share: 0.095),
  (step: 'Started checkout', share: 0.051),
  (step: 'Paid', share: 0.033),
];

const analyticsLive = (readers: 42, page: 'the journal');
