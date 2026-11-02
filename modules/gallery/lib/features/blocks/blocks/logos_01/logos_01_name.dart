import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/logos_01/logos_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One team's name, set in its own lettering on a single line.
///
/// Mirrors `Logos01Name` in upstream
/// `src/blocks/logos-01/components/logos-01-names.tsx`.
class Logos01Name extends StatelessWidget {
  const Logos01Name(this.logo, {super.key});

  final Logos01Logo logo;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Text(
      logo.label,
      maxLines: 1,
      softWrap: false,
      style: logo.style(theme).copyWith(color: theme.colors.ink),
    );
  }
}
