import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class BookmarkTonesExample extends StatefulWidget {
  const BookmarkTonesExample({super.key});

  @override
  State<BookmarkTonesExample> createState() => _BookmarkTonesExampleState();
}

class _BookmarkTonesExampleState extends State<BookmarkTonesExample> {
  final _pressed = {for (final tone in Accent.values) tone: true};

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d24),
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: Spacing.d24,
      runSpacing: Spacing.d24,
      children: [
        for (final tone in Accent.values)
          Bookmark(
            tone: tone,
            value: _pressed[tone] ?? false,
            onChanged: (value) => setState(() => _pressed[tone] = value),
            seed: tone.name,
            semanticLabel: tone.name,
          ),
      ],
    ),
  );
}
