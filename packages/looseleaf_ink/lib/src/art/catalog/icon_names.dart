import 'package:looseleaf_ink/src/art/icons/icons.dart';
import 'package:looseleaf_ink/src/art/model/model.dart';

final Map<String, String> _reverse = {
  for (final MapEntry(:key, :value) in iconAliases.entries)
    for (final alias in value) alias: key,
};

/// [name] in kebab case without a `Lucide` prefix or `Icon` suffix:
/// `LucideArrowRight` and `ArrowRightIcon` both give `arrow-right`.
///
/// Mirrors `kebabIconName` in `src/lib/ink/art/icons/aliases.ts`.
String kebabIconName(String name) => name
    .replaceFirst(RegExp('^Lucide(?=[A-Z])'), '')
    .replaceFirst(RegExp(r'Icon$'), '')
    .replaceAllMapped(
      RegExp('([A-Z])([A-Z][a-z])'),
      (m) => '${m[1]}-${m[2]}',
    )
    .replaceAllMapped(RegExp('([a-z])([A-Z])'), (m) => '${m[1]}-${m[2]}')
    .replaceAllMapped(RegExp(r'([a-zA-Z])(\d)'), (m) => '${m[1]}-${m[2]}')
    .replaceAllMapped(RegExp(r'(\d)([A-Z])'), (m) => '${m[1]}-${m[2]}')
    .replaceAll(RegExp(r'[_\s]+'), '-')
    .toLowerCase();

/// The icon id for [name]: kebab-cased, old Lucide names mapped to the
/// current ids.
///
/// Mirrors `resolveIconName` in `src/lib/ink/art/icons/aliases.ts`.
String resolveIconName(String name) {
  final k = kebabIconName(name);
  return _reverse[k] ?? k;
}

/// The icon for [name] (any spelling [resolveIconName] understands), or
/// null.
ArtDef? iconNamed(String name) => icons[resolveIconName(name)];
