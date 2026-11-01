import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _base = [
  'Field notes',
  'Garden log',
  'Recipes',
  'Trip to Lisbon',
  'Sketches',
  'Reading list',
  'Letters',
  'Budget',
];

final _all = [
  for (var i = 0; i < 40; i++)
    switch (i >= _base.length) {
      true => '${_base[i % _base.length]} ${i ~/ _base.length + 1}',
      false => _base[i],
    },
];

class SidebarSearchAndLoadingExample extends StatefulWidget {
  const SidebarSearchAndLoadingExample({super.key});

  @override
  State<SidebarSearchAndLoadingExample> createState() =>
      _SidebarSearchAndLoadingExampleState();
}

class _SidebarSearchAndLoadingExampleState
    extends State<SidebarSearchAndLoadingExample> {
  String _query = '';
  bool _loading = false;
  String _current = _all.first;
  List<String> _extra = const [];
  Timer? _timer;

  List<String> get _names {
    final query = _query.trim().toLowerCase();
    return [
      ..._extra,
      ..._all,
    ].where((name) => name.toLowerCase().contains(query)).toList();
  }

  void _reload() {
    setState(() => _loading = true);
    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 1400),
      () => setState(() => _loading = false),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final names = _names;
    final muted = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    return SizedBox(
      height: 560,
      child: SidebarProvider(
        children: [
          Sidebar(
            seed: 'search',
            children: [
              SidebarHeader(
                children: [
                  SidebarInput(
                    semanticLabel: 'Search notebooks',
                    placeholder: 'Search notebooks…',
                    onChanged: (query) => setState(() => _query = query),
                  ),
                ],
              ),
              SidebarContent(
                children: [
                  SidebarGroup(
                    action: SidebarGroupAction(
                      semanticLabel: 'New notebook',
                      onPressed: () => setState(
                        () => _extra = [
                          'Untitled ${_extra.length + 1}',
                          ..._extra,
                        ],
                      ),
                      child: const InkIcon('plus'),
                    ),
                    children: [
                      const SidebarGroupLabel(child: Text('Notebooks')),
                      SidebarGroupContent(
                        child: SidebarMenu(
                          children: [
                            if (_loading)
                              for (var i = 0; i < 7; i++)
                                SidebarMenuItem(
                                  child: SidebarMenuSkeleton(
                                    showIcon: true,
                                    seed: 'sk-$i',
                                  ),
                                ),
                            if (!_loading)
                              for (final name in names)
                                SidebarMenuItem(
                                  key: ValueKey(name),
                                  child: SidebarMenuButton(
                                    isActive: _current == name,
                                    leading: const InkIcon('file-text'),
                                    onPressed: () =>
                                        setState(() => _current = name),
                                    child: Text(name),
                                  ),
                                ),
                            if (!_loading && names.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Spacing.d8,
                                  vertical: Spacing.d6,
                                ),
                                child: Text(
                                  'No notebook matches “$_query”.',
                                  style: muted,
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
                spacing: Spacing.d12,
                children: [
                  Text(_current, style: theme.typography.title(cssSize: 24)),
                  Semantics(
                    liveRegion: true,
                    child: Text(switch (_loading) {
                      true => 'Loading notebooks…',
                      false => '${names.length} notebooks shown.',
                    }, style: muted),
                  ),
                  Button(
                    variant: ButtonVariant.outline,
                    size: ButtonSize.sm,
                    disabled: _loading,
                    leading: const InkIcon('rotate-cw'),
                    onPressed: _reload,
                    child: const Text('Reload'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
