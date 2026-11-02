import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BookmarkDefaultExample extends StatefulWidget {
  const BookmarkDefaultExample({super.key});

  @override
  State<BookmarkDefaultExample> createState() => _BookmarkDefaultExampleState();
}

class _BookmarkDefaultExampleState extends State<BookmarkDefaultExample> {
  bool _later = false;
  bool _saved = true;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d24),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d32,
      children: [
        Bookmark(
          value: _later,
          onChanged: (value) => setState(() => _later = value),
          seed: 'off',
          semanticLabel: 'Save for later',
        ),
        Bookmark(
          value: _saved,
          onChanged: (value) => setState(() => _saved = value),
          seed: 'on',
          semanticLabel: 'Saved',
        ),
        const Bookmark(
          value: false,
          disabled: true,
          seed: 'dis',
          semanticLabel: 'Cannot save',
        ),
      ],
    ),
  );
}
