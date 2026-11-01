import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _items = [
  ('Overview', 'layout-dashboard'),
  ('Reports', 'chart-column'),
  ('Team', 'users'),
  ('Billing', 'credit-card'),
];

class SidebarVariantsExample extends StatefulWidget {
  const SidebarVariantsExample({super.key});

  @override
  State<SidebarVariantsExample> createState() => _SidebarVariantsExampleState();
}

class _SidebarVariantsExampleState extends State<SidebarVariantsExample> {
  SidebarVariant _variant = SidebarVariant.floating;
  SidebarSide _side = SidebarSide.left;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final pad = _Pad(variant: _variant, side: _side);
    return SizedBox(
      height: 400,
      child: SidebarProvider(
        children: [
          if (_side == SidebarSide.left) pad,
          SidebarInset(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.d16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d16,
                children: [
                  Wrap(
                    spacing: Spacing.d12,
                    runSpacing: Spacing.d12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const SidebarTrigger(),
                      ToggleGroup<SidebarVariant>(
                        value: {_variant},
                        variant: ToggleVariant.outline,
                        size: ToggleSize.sm,
                        semanticLabel: 'Variant',
                        onChanged: (value) {
                          if (value.firstOrNull case final variant?) {
                            setState(() => _variant = variant);
                          }
                        },
                        children: const [
                          ToggleGroupItem(
                            value: SidebarVariant.sidebar,
                            child: Text('sidebar'),
                          ),
                          ToggleGroupItem(
                            value: SidebarVariant.floating,
                            child: Text('floating'),
                          ),
                          ToggleGroupItem(
                            value: SidebarVariant.inset,
                            child: Text('inset'),
                          ),
                        ],
                      ),
                      ToggleGroup<SidebarSide>(
                        value: {_side},
                        variant: ToggleVariant.outline,
                        size: ToggleSize.sm,
                        semanticLabel: 'Side',
                        onChanged: (value) {
                          if (value.firstOrNull case final side?) {
                            setState(() => _side = side);
                          }
                        },
                        children: const [
                          ToggleGroupItem(
                            value: SidebarSide.left,
                            child: Text('left'),
                          ),
                          ToggleGroupItem(
                            value: SidebarSide.right,
                            child: Text('right'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 384),
                    child: Text(
                      switch (_variant) {
                        SidebarVariant.inset =>
                          'This page is a sheet of paper set on the desk, '
                              'beside the pad.',
                        _ => 'This page is plain: the pad hangs beside it.',
                      },
                      style: theme.typography.interface(
                        cssSize: 14,
                        color: theme.colors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_side == SidebarSide.right) pad,
        ],
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({required this.variant, required this.side});

  final SidebarVariant variant;
  final SidebarSide side;

  @override
  Widget build(BuildContext context) => Sidebar(
    variant: variant,
    side: side,
    seed: 'variants',
    children: [
      SidebarContent(
        children: [
          SidebarGroup(
            children: [
              const SidebarGroupLabel(child: Text('Dashboard')),
              SidebarGroupContent(
                child: SidebarMenu(
                  children: [
                    for (final (index, (title, icon)) in _items.indexed)
                      SidebarMenuItem(
                        child: SidebarMenuButton(
                          isActive: index == 0,
                          leading: InkIcon(icon),
                          onPressed: () {},
                          child: Text(title),
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
  );
}
