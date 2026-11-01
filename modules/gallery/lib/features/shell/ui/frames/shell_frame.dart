import 'package:flutter/widgets.dart';
import 'package:gallery/features/navigation/models/models.dart';
import 'package:gallery/features/navigation/view_models/view_models.dart';
import 'package:gallery/features/settings/view_models/view_models.dart';
import 'package:gallery/features/shell/ui/frames/outlet_frame.dart';
import 'package:gallery/features/shell/ui/frames/settings_frame.dart';
import 'package:gallery/features/shell/ui/frames/side_nav_frame.dart';
import 'package:gallery/features/shell/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// The whole gallery on the desk: the top bar, the nav pad (a drawer on
/// phones) and the current page in a scrolling column.
///
/// Mirrors `Shell` in upstream `src/docs/shell/Shell.tsx`.
class ShellFrame extends StatelessWidget {
  const ShellFrame({super.key});

  /// Below this width the nav moves into a drawer (upstream `md`).
  static const double compactBelow = 768;

  static const double _mainMaxWidth = 1600;

  @override
  Widget build(BuildContext context) {
    final navigation = context.read<NavigationViewModel>();
    final route = context.select<NavigationViewModel, GalleryRoute>(
      (model) => model.route,
    );
    final drawerOpen = context.select<NavigationViewModel, bool>(
      (model) => model.drawerOpen,
    );
    final navHidden = context.select<NavigationViewModel, bool>(
      (model) => model.navHidden,
    );
    final clutter = context.select<SettingsViewModel, bool>(
      (model) => model.clutter,
    );
    final compact = MediaQuery.sizeOf(context).width < compactBelow;
    final wide = MediaQuery.sizeOf(context).width >= 1024;
    final mainPadding = switch (wide) {
      true => const EdgeInsets.fromLTRB(
        Spacing.d40,
        Spacing.d36,
        Spacing.d40,
        Spacing.d96,
      ),
      false => const EdgeInsets.fromLTRB(
        Spacing.d16,
        Spacing.d24,
        Spacing.d16,
        Spacing.d80,
      ),
    };
    return Desk(
      objects: switch (clutter) {
        true => const [DeskObject.clips, DeskObject.coffee],
        false => const [],
      },
      seed: 'docs-desk',
      child: SizedBox.expand(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.d8,
                    Spacing.d8,
                    Spacing.d8,
                    0,
                  ),
                  child: TopBar(
                    compact: compact,
                    onToggleNav: switch (compact) {
                      true => () => navigation.setDrawerOpen(true),
                      false => navigation.toggleNav,
                    },
                    onHome: () => navigation.go(const HomeRoute()),
                    primary: [
                      TopBarLink(
                        label: 'Getting started',
                        current: route is GettingStartedRoute,
                        onPressed: () =>
                            navigation.go(const GettingStartedRoute()),
                      ),
                      TopBarLink(
                        label: 'Components',
                        current: route is ComponentsRoute,
                        onPressed: () => navigation.go(const ComponentsRoute()),
                      ),
                      TopBarLink(
                        label: 'Blocks',
                        current: route is BlocksRoute,
                        onPressed: () => navigation.go(const BlocksRoute()),
                      ),
                    ],
                    settings: const SettingsFrame(),
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!compact && !navHidden)
                        const Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            Spacing.d8,
                            Spacing.d28,
                            0,
                            Spacing.d16,
                          ),
                          child: NavPad(child: SideNavFrame()),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          key: PageStorageKey(route.path),
                          padding: mainPadding,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _mainMaxWidth,
                              ),
                              child: const OutletFrame(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (compact)
              Positioned.fill(
                child: NavDrawer(
                  open: drawerOpen,
                  onClose: () => navigation.setDrawerOpen(false),
                  child: const SideNavFrame(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
