const List<String> profileTakenUsernames = [
  'ada',
  'admin',
  'jo',
  'nell',
  'stubby',
];

const int profileBioMax = 160;

typedef ProfileChoice = ({String value, String label});

const List<ProfileChoice> profileTimeZones = [
  (value: 'Europe/Lisbon', label: 'Lisbon (WET)'),
  (value: 'Europe/London', label: 'London (GMT)'),
  (value: 'America/New_York', label: 'New York (ET)'),
  (value: 'America/Los_Angeles', label: 'Los Angeles (PT)'),
  (value: 'Asia/Tokyo', label: 'Tokyo (JST)'),
  (value: 'Australia/Sydney', label: 'Sydney (AEST)'),
];

const List<ProfileChoice> profilePronouns = [
  (value: 'none', label: 'Rather not say'),
  (value: 'she', label: 'she / her'),
  (value: 'he', label: 'he / him'),
  (value: 'they', label: 'they / them'),
];

const Map<String, Object?> profileDefaults = {
  'name': 'Jo Delacroix',
  'username': 'jo_writes',
  'email': 'jo@looseleaf.example',
  'bio': 'I write in the margins. Letterpress on weekends, tea all week.',
  'website': 'https://jo.looseleaf.example',
  'pronouns': 'she',
  'timezone': 'Europe/Lisbon',
  'discoverable': true,
};

final RegExp _username = RegExp(r'^[a-z0-9_]+$', caseSensitive: false);
final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String _text(Object? value) => '${value ?? ''}';

String? profileValidateName(Object? value) => switch (_text(value).trim()) {
  final name when name.length < 2 => 'Your name needs at least 2 letters.',
  final name when name.length > 40 => 'Keep your name to 40 letters or fewer.',
  _ => null,
};

String? profileValidateUsername(Object? value) {
  final username = _text(value).trim();
  if (username.length < 3) return 'Usernames need at least 3 characters.';
  if (username.length > 20) return 'Usernames are 20 characters or fewer.';
  if (!_username.hasMatch(username)) {
    return 'Use letters, numbers and underscores only.';
  }
  if (profileTakenUsernames.contains(username.toLowerCase())) {
    return 'That username is taken. Try another.';
  }
  return null;
}

String? profileValidateEmail(Object? value) =>
    switch (_email.hasMatch(_text(value))) {
      true => null,
      false => 'Enter an address like ada@notes.dev.',
    };

String? profileValidateBio(Object? value) =>
    switch (_text(value).length > profileBioMax) {
      true => 'Bios are $profileBioMax characters or fewer.',
      false => null,
    };

String? profileValidateWebsite(Object? value) {
  final website = _text(value);
  if (website.isEmpty) return null;
  final uri = Uri.tryParse(website);
  if (uri case Uri(hasScheme: true, host: final host) when host.isNotEmpty) {
    return null;
  }
  return 'Start with https:// so the link works.';
}

String? profileValidateTimezone(Object? value) => switch (_text(value)) {
  '' => 'Pick a time zone.',
  _ => null,
};
