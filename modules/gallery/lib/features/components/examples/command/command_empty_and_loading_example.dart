import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CommandEmptyAndLoadingExample extends StatefulWidget {
  const CommandEmptyAndLoadingExample({super.key});

  @override
  State<CommandEmptyAndLoadingExample> createState() =>
      _CommandEmptyAndLoadingExampleState();
}

class _CommandEmptyAndLoadingExampleState
    extends State<CommandEmptyAndLoadingExample> {
  static const _width = 352.0;
  static const _docs = [
    'Invoice 0142',
    'Invoice 0143',
    'Invoice 0150',
    'Inventory count',
    'Invitation list',
  ];

  String _query = '';
  List<String> _results = const [];
  bool _busy = false;
  Timer? _search;

  @override
  void dispose() {
    _search?.cancel();
    super.dispose();
  }

  void _onQuery(String query) {
    _search?.cancel();
    setState(() => _query = query);
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _busy = false;
      });
      return;
    }
    setState(() => _busy = true);
    _search = Timer(const Duration(milliseconds: 700), () {
      final needle = query.toLowerCase();
      setState(() {
        _results = [
          for (final doc in _docs)
            if (doc.toLowerCase().contains(needle)) doc,
        ];
        _busy = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      width: _width,
      child: Command(
        shouldFilter: false,
        semanticLabel: 'Search documents',
        children: [
          CommandInput(
            value: _query,
            onValueChange: _onQuery,
            placeholder: 'Search documents...',
            autofocus: false,
          ),
          CommandList(
            children: [
              if (_busy) const CommandLoading(child: Text('Searching...')),
              if (!_busy && _query.isNotEmpty && _results.isEmpty)
                const CommandEmpty(child: Text('No documents found.')),
              if (!_busy && _results.isNotEmpty)
                CommandGroup(
                  heading: const Text('Documents'),
                  children: [
                    for (final doc in _results)
                      CommandItem(
                        key: ValueKey(doc),
                        value: doc,
                        leading: const InkIcon('file-text'),
                        child: Text(doc),
                      ),
                  ],
                ),
            ],
          ),
          if (_query.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.d12,
                vertical: Spacing.d24,
              ),
              child: Text(
                'Type to search.',
                textAlign: TextAlign.center,
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 20,
                  color: theme.colors.inkMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
