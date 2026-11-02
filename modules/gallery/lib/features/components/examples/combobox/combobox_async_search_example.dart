import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ComboboxAsyncSearchExample extends StatefulWidget {
  const ComboboxAsyncSearchExample({super.key});

  @override
  State<ComboboxAsyncSearchExample> createState() =>
      _ComboboxAsyncSearchExampleState();
}

class _ComboboxAsyncSearchExampleState
    extends State<ComboboxAsyncSearchExample> {
  static const _people = [
    'Ada Lovelace',
    'Grace Hopper',
    'Graham Bell',
    'Katherine Johnson',
    'Alan Turing',
    'Margaret Hamilton',
  ];

  List<String> _results = _people.take(3).toList();
  bool _loading = false;
  String? _value;
  Timer? _request;

  @override
  void dispose() {
    _request?.cancel();
    super.dispose();
  }

  void _search(String query) {
    _request?.cancel();
    setState(() => _loading = true);
    _request = Timer(const Duration(milliseconds: 600), () {
      final needle = query.trim().toLowerCase();
      setState(() {
        _results = _people
            .where((person) => person.toLowerCase().contains(needle))
            .take(5)
            .toList();
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Combobox(
    filter: null,
    loading: _loading,
    onInputValueChange: _search,
    items: [for (final person in _results) ComboboxItemData.of(person)],
    value: _value,
    onChanged: (value) => setState(() => _value = value),
    label: 'Assignee',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: Spacing.d256,
          child: ComboboxTrigger(
            semanticLabel: 'Assignee',
            child: ComboboxValue(placeholder: 'Assign to...'),
          ),
        ),
        ComboboxContent(
          children: [
            const ComboboxInput(placeholder: 'Search people...'),
            ComboboxList(
              children: [
                if (_loading)
                  const ComboboxLoading(child: Text('Searching...')),
                const ComboboxEmpty(child: Text('Nobody by that name.')),
                for (final person in _results)
                  ComboboxItem(value: person, child: Text(person)),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
