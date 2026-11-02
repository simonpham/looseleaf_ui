import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The strip across the top of the page: the sidebar trigger, the page's
/// name and a share button, with a pencil rule under it.
///
/// Mirrors `SiteHeader` in upstream
/// `src/blocks/dashboard-01/components/dashboard-01-site-header.tsx`.
class Dashboard01SiteHeader extends StatelessWidget {
  const Dashboard01SiteHeader({super.key});

  static const double _height = 48;
  static const double _shareFrom = 640;
  static const double _wideFrom = 1024;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideFrom;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _height,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: switch (wide) {
                    true => Spacing.d24,
                    false => Spacing.d16,
                  },
                ),
                child: Row(
                  spacing: switch (wide) {
                    true => Spacing.d8,
                    false => Spacing.d4,
                  },
                  children: [
                    Transform.translate(
                      offset: const Offset(-Spacing.d4, 0),
                      child: const SidebarTrigger(),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: Spacing.d8),
                      child: SizedBox(
                        height: Spacing.d16,
                        child: Separator(
                          orientation: SeparatorOrientation.vertical,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          'Documents',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.face(
                            KevinSansFace.script,
                            cssSize: 24,
                            cssLineHeight: 1,
                            fontWeight: FontWeight.w600,
                            color: theme.colors.ink,
                          ),
                        ),
                      ),
                    ),
                    if (constraints.maxWidth >= _shareFrom)
                      Button(
                        variant: ButtonVariant.ghost,
                        size: ButtonSize.sm,
                        onPressed: () {},
                        leading: const InkIcon('external-link'),
                        child: const Text('Share a copy'),
                      ),
                  ],
                ),
              ),
            ),
            const Separator(),
          ],
        );
      },
    );
  }
}
