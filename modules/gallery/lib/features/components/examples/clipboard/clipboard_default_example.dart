import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ClipboardDefaultExample extends StatefulWidget {
  const ClipboardDefaultExample({super.key});

  @override
  State<ClipboardDefaultExample> createState() =>
      _ClipboardDefaultExampleState();
}

class _ClipboardDefaultExampleState extends State<ClipboardDefaultExample> {
  static const _items = [
    'Passport, tickets',
    'Waterproof notebook',
    'Two rolls of washi',
    'Tea (a lot)',
    'The very small pencil',
  ];

  final _packed = {_items[0], _items[1]};

  void _toggle(String item, bool packed) => setState(() {
    if (packed) {
      _packed.add(item);
      return;
    }
    _packed.remove(item);
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return InkClipboard(
      seed: 'pack',
      tiltDegrees: -1.1,
      maxWidth: Spacing.d96 * 4,
      children: [
        ClipboardPaper(
          seed: 'pack-p',
          child: Semantics(
            container: true,
            label: 'Packing list',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: Spacing.d28,
                  child: Text(
                    'Packing list',
                    style: theme.typography
                        .face(KevinSansFace.script, cssSize: 28)
                        .copyWith(fontWeight: FontWeight.bold, height: 1),
                  ),
                ),
                for (final item in _items)
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: Spacing.d28),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Checkbox(
                        value: _packed.contains(item),
                        onChanged: (packed) => _toggle(item, packed),
                        label: Text(
                          item,
                          style: theme.typography.interface(cssSize: 17),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
