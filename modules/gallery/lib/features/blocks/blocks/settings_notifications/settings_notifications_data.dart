import 'package:flutter/foundation.dart';

/// How much news gets through.
enum NotifyMode {
  all('Everything', 'Every comment, reply, follower and shared notebook.'),
  mentions('Just me', 'Only replies to you and comments on your own notes.'),
  nothing(
    'Nothing',
    'Mute it all. Quiet hours and the weekly summary switch off too.',
  );

  const NotifyMode(this.title, this.help);

  final String title;
  final String help;
}

/// Where news arrives.
enum NotifyChannel {
  email('Email'),
  push('Push'),
  app('In the app');

  const NotifyChannel(this.label);

  final String label;
}

/// A kind of news.
enum NotifyEvent {
  comments('Comments on my notes', 'Someone wrote in your margin.', true),
  replies('Replies to my questions', 'An answer to something you asked.', true),
  follows('New followers', 'A person started reading your notebooks.', false),
  shared('Notebooks shared with me', 'Someone handed you a notebook.', false),
  news('News from Looseleaf', 'New pens, about once a month.', false);

  const NotifyEvent(this.label, this.help, this.personal);

  final String label;
  final String help;

  /// Only about you, so still sent in "Just me".
  final bool personal;

  /// Whether this row is sent at all in [mode].
  bool enabledIn(NotifyMode mode) =>
      mode == NotifyMode.all || (mode == NotifyMode.mentions && personal);
}

enum NotifyDay {
  mon('Monday', 'M'),
  tue('Tuesday', 'T'),
  wed('Wednesday', 'W'),
  thu('Thursday', 'T'),
  fri('Friday', 'F'),
  sat('Saturday', 'S'),
  sun('Sunday', 'S');

  const NotifyDay(this.label, this.short);

  final String label;
  final String short;
}

/// Every half hour of the day: `22:00` labelled `10:00 pm`.
final List<({String value, String label})> notifyTimes = [
  for (var i = 0; i < 48; i++)
    (
      value:
          '${'${i ~/ 2}'.padLeft(2, '0')}:${switch (i.isOdd) {
            true => '30',
            false => '00',
          }}',
      label:
          '${switch ((i ~/ 2) % 12) {
            0 => 12,
            final hour => hour,
          }}:${switch (i.isOdd) {
            true => '30',
            false => '00',
          }} ${switch (i ~/ 2 < 12) {
            true => 'am',
            false => 'pm',
          }}',
    ),
];

/// Every notification choice.
@immutable
class NotifyPrefs {
  const NotifyPrefs({
    this.mode = NotifyMode.all,
    this.on = const {
      NotifyEvent.comments: {
        NotifyChannel.email,
        NotifyChannel.push,
        NotifyChannel.app,
      },
      NotifyEvent.replies: {
        NotifyChannel.email,
        NotifyChannel.push,
        NotifyChannel.app,
      },
      NotifyEvent.follows: {NotifyChannel.app},
      NotifyEvent.shared: {NotifyChannel.email, NotifyChannel.app},
      NotifyEvent.news: {},
    },
    this.quiet = true,
    this.quietFrom = '22:00',
    this.quietTo = '07:30',
    this.quietDays = const {...NotifyDay.values},
    this.summaryDay = NotifyDay.fri,
    this.tally = true,
  });

  final NotifyMode mode;
  final Map<NotifyEvent, Set<NotifyChannel>> on;
  final bool quiet;
  final String quietFrom;
  final String quietTo;
  final Set<NotifyDay> quietDays;
  final NotifyDay summaryDay;
  final bool tally;

  bool get muted => mode == NotifyMode.nothing;

  NotifyPrefs copyWith({
    NotifyMode? mode,
    Map<NotifyEvent, Set<NotifyChannel>>? on,
    bool? quiet,
    String? quietFrom,
    String? quietTo,
    Set<NotifyDay>? quietDays,
    NotifyDay? summaryDay,
    bool? tally,
  }) => NotifyPrefs(
    mode: mode ?? this.mode,
    on: on ?? this.on,
    quiet: quiet ?? this.quiet,
    quietFrom: quietFrom ?? this.quietFrom,
    quietTo: quietTo ?? this.quietTo,
    quietDays: quietDays ?? this.quietDays,
    summaryDay: summaryDay ?? this.summaryDay,
    tally: tally ?? this.tally,
  );

  /// [event] sent by [channel], or not.
  NotifyPrefs toggle(NotifyEvent event, NotifyChannel channel, bool send) {
    final now = on[event] ?? const <NotifyChannel>{};
    return copyWith(
      on: {
        ...on,
        event: switch (send) {
          true => {...now, channel},
          false => {...now}..remove(channel),
        },
      },
    );
  }

  bool sends(NotifyEvent event, NotifyChannel channel) =>
      on[event]?.contains(channel) ?? false;
}

/// What is wrong with a set of choices, by section.
typedef NotifyProblems = ({String? channels, String? quiet});

NotifyProblems validateNotify(NotifyPrefs prefs) {
  if (prefs.muted) return (channels: null, quiet: null);
  final reachable = NotifyEvent.values.any(
    (event) =>
        event.enabledIn(prefs.mode) && (prefs.on[event]?.isNotEmpty ?? false),
  );
  final quiet = switch (prefs) {
    NotifyPrefs(quiet: false) => null,
    NotifyPrefs(:final quietFrom, :final quietTo) when quietFrom == quietTo =>
      'Quiet hours need two different times.',
    NotifyPrefs(:final quietDays) when quietDays.isEmpty =>
      'Pick at least one day for quiet hours.',
    _ => null,
  };
  return (
    channels: switch (reachable) {
      true => null,
      false =>
        'You asked to hear about things, but every box is empty. Tick at least one.',
    },
    quiet: quiet,
  );
}
