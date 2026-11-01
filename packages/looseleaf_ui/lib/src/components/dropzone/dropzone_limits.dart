import 'package:looseleaf_ui/src/components/dropzone/dropzone_file.dart';

/// [bytes] for people: `512 B`, `1.5 KB`, `12 MB`.
///
/// Mirrors `formatBytes` in upstream `src/components/ui/dropzone.tsx`.
String formatBytes(num bytes) {
  if (!bytes.isFinite || bytes < 0) return '0 B';
  if (bytes < 1024) return '${bytes.round()} B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final whole = value == value.roundToDouble();
  final shown = switch (value >= 10 || whole) {
    true => value.round().toString(),
    false => value.toStringAsFixed(1),
  };
  return '$shown ${units[unit]}';
}

/// The accept tokens: `.pdf`, `image/*`, `application/zip`.
List<String> acceptTokens(List<String> accept) => [
  for (final token in accept)
    for (final part in token.split(','))
      if (part.trim().isNotEmpty) part.trim(),
];

/// Whether [file] is one of the [accept] kinds (all kinds when empty):
/// an extension, a MIME type, or a `type/*` family.
///
/// Mirrors `matchesAccept` in upstream `src/components/ui/dropzone.tsx`.
bool matchesAccept(DropzoneFile file, List<String> accept) {
  final tokens = [
    for (final token in acceptTokens(accept)) token.toLowerCase(),
  ];
  if (tokens.isEmpty) return true;
  final name = file.name.toLowerCase();
  final type = file.type.toLowerCase();
  return tokens.any((token) {
    if (token.startsWith('.')) return name.endsWith(token);
    if (token.endsWith('/*')) {
      return type.startsWith(token.substring(0, token.length - 1));
    }
    return type == token;
  });
}

/// The limits in words: "PDF, PNG up to 5 MB each at most 3 files".
///
/// Mirrors `describeLimits` in upstream `src/components/ui/dropzone.tsx`.
String describeLimits({
  List<String> accept = const [],
  int? maxSize,
  int? maxFiles,
  bool multiple = true,
}) {
  final kinds = [
    for (final token in acceptTokens(accept))
      switch (token) {
        _ when token.startsWith('.') => token.substring(1).toUpperCase(),
        'image/*' => 'Images',
        'video/*' => 'Videos',
        'audio/*' => 'Audio',
        'text/*' => 'Text files',
        _ => switch (token.split('/').elementAtOrNull(1)) {
          final sub? when sub.isNotEmpty && sub != '*' => sub.toUpperCase(),
          _ => token,
        },
      },
  ];
  final parts = <String>[];
  if (kinds.isNotEmpty) parts.add(kinds.join(', '));
  if (maxSize != null && maxSize > 0) {
    final lead = switch (parts.isEmpty) {
      true => 'Up to',
      false => 'up to',
    };
    final each = switch (multiple) {
      true => ' each',
      false => '',
    };
    parts.add('$lead ${formatBytes(maxSize)}$each');
  }
  if (maxFiles != null && maxFiles > 0 && multiple) {
    final lead = switch (parts.isEmpty) {
      true => 'At most',
      false => 'at most',
    };
    final plural = switch (maxFiles == 1) {
      true => '',
      false => 's',
    };
    parts.add('$lead $maxFiles file$plural');
  }
  return parts.join(' ');
}
