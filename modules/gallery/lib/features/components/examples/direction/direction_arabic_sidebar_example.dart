import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _pages = [
  (title: 'الرئيسية', icon: 'house', active: true, count: null),
  (title: 'الملاحظات', icon: 'file-text', active: false, count: '12'),
  (title: 'الأصدقاء', icon: 'users', active: false, count: null),
  (title: 'الإعدادات', icon: 'settings', active: false, count: null),
];

class DirectionArabicSidebarExample extends StatelessWidget {
  const DirectionArabicSidebarExample({super.key});

  static const _height = 520.0;
  static const _textWidth = Spacing.d448;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final heading = theme.typography.face(
      KevinSansFace.script,
      cssSize: 24,
      cssLineHeight: 1,
      fontWeight: FontWeight.w600,
    );
    return DirectionProvider(
      direction: TextDirection.rtl,
      child: SizedBox(
        height: _height,
        child: SidebarProvider(
          children: [
            Sidebar(
              side: SidebarSide.right,
              seed: 'direction-sidebar',
              children: [
                SidebarHeader(children: [Text('دفتري', style: heading)]),
                SidebarContent(
                  children: [
                    SidebarGroup(
                      children: [
                        const SidebarGroupLabel(child: Text('الصفحات')),
                        SidebarGroupContent(
                          child: SidebarMenu(
                            children: [
                              for (final page in _pages)
                                SidebarMenuItem(
                                  badge: switch (page.count) {
                                    final count? => SidebarMenuBadge(
                                      child: Text(count),
                                    ),
                                    null => null,
                                  },
                                  child: SidebarMenuButton(
                                    isActive: page.active,
                                    tooltip: page.title,
                                    leading: InkIcon(page.icon),
                                    onPressed: () {},
                                    child: Text(page.title),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SidebarInset(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.d16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: Spacing.d8,
                      children: [
                        const SidebarTrigger(),
                        Text('مرحبًا بك', style: heading),
                      ],
                    ),
                    const SizedBox(height: Spacing.d12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _textWidth),
                      child: Text(
                        'الشريط الجانبي على يمين الصفحة. اطوِه بالزر، أو بالاختصار Ctrl/Cmd+B.',
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.d16),
                    Button(
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.sm,
                      leading: const InkIcon('sparkles'),
                      onPressed: () {},
                      child: const Text('ابدأ'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
