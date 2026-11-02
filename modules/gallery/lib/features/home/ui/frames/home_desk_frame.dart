import 'package:flutter/widgets.dart';
import 'package:gallery/features/settings/view_models/view_models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// The home page's own desk, with clips and a ruler on it while the desk
/// is cluttered.
///
/// Mirrors the `Desk` of upstream `src/docs/content/home.tsx`.
class HomeDeskFrame extends StatelessWidget {
  const HomeDeskFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final clutter = context.select<SettingsViewModel, bool>(
      (model) => model.clutter,
    );
    return Desk(
      objects: switch (clutter) {
        true => const [DeskObject.clips, DeskObject.ruler],
        false => const [],
      },
      lamp: 0,
      seed: 'home-desk',
      child: child,
    );
  }
}
