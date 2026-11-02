import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ToggleGroupMultipleExample extends StatefulWidget {
  const ToggleGroupMultipleExample({super.key});

  @override
  State<ToggleGroupMultipleExample> createState() =>
      _ToggleGroupMultipleExampleState();
}

class _ToggleGroupMultipleExampleState
    extends State<ToggleGroupMultipleExample> {
  var _styles = {'bold'};

  void _set(Set<String> styles) => setState(() => _styles = styles);

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final letter = theme.typography.face(
      KevinSansFace.script,
      cssSize: 24,
      cssLineHeight: 1,
      fontWeight: FontWeight.w700,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        Wrap(
          spacing: Spacing.d24,
          runSpacing: Spacing.d16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ToggleGroup<String>(
              type: ToggleGroupType.multiple,
              variant: ToggleVariant.outline,
              value: _styles,
              onChanged: _set,
              semanticLabel: 'Text style',
              children: const [
                ToggleGroupItem(
                  value: 'bold',
                  semanticLabel: 'Bold',
                  child: InkIcon('bold'),
                ),
                ToggleGroupItem(
                  value: 'italic',
                  semanticLabel: 'Italic',
                  child: InkIcon('italic'),
                ),
                ToggleGroupItem(
                  value: 'underline',
                  semanticLabel: 'Underline',
                  child: InkIcon('underline'),
                ),
              ],
            ),
            ToggleGroup<String>(
              type: ToggleGroupType.multiple,
              variant: ToggleVariant.outline,
              tone: ToggleTone.marker,
              value: _styles,
              onChanged: _set,
              semanticLabel: 'Text style, hand-lettered',
              children: [
                ToggleGroupItem(
                  value: 'bold',
                  semanticLabel: 'Bold',
                  child: Text('B', style: letter),
                ),
                ToggleGroupItem(
                  value: 'italic',
                  semanticLabel: 'Italic',
                  child: Text(
                    'I',
                    style: letter.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
                ToggleGroupItem(
                  value: 'underline',
                  semanticLabel: 'Underline',
                  child: Text(
                    'U',
                    style: letter.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          'The quick brown fox, written down.',
          style: theme.typography
              .interface(cssSize: 20)
              .copyWith(
                fontWeight: switch (_styles.contains('bold')) {
                  true => FontWeight.w700,
                  false => FontWeight.w400,
                },
                fontStyle: switch (_styles.contains('italic')) {
                  true => FontStyle.italic,
                  false => FontStyle.normal,
                },
                decoration: switch (_styles.contains('underline')) {
                  true => TextDecoration.underline,
                  false => TextDecoration.none,
                },
                decorationStyle: TextDecorationStyle.wavy,
              ),
        ),
      ],
    );
  }
}
