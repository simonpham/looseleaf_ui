import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An index card of settings: two switches, a pen pressure slider with its
/// value written beside it, and a checkbox, each on a printed rule.
///
/// Mirrors upstream `src/docs/content/home/prefs-card.tsx`.
class PrefsCard extends StatefulWidget {
  const PrefsCard({super.key});

  @override
  State<PrefsCard> createState() => _PrefsCardState();
}

class _PrefsCardState extends State<PrefsCard> {
  bool _airplane = false;
  bool _pencil = true;
  double _pressure = 60;
  bool _tally = true;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return IndexCard(
      seed: 'home-prefs',
      flag: Accent.sky,
      stack: 1,
      children: [
        const IndexCardHeader(children: [IndexCardTitle(Text('Settings'))]),
        IndexCardContent(
          children: [
            _line(
              Row(
                spacing: Spacing.d12,
                children: [
                  Expanded(
                    child: Label(
                      onPressed: () => setState(() => _airplane = !_airplane),
                      child: const Text('Airplane mode'),
                    ),
                  ),
                  Switch(
                    value: _airplane,
                    onChanged: (on) => setState(() => _airplane = on),
                    semanticLabel: 'Airplane mode',
                  ),
                ],
              ),
            ),
            _line(
              Row(
                spacing: Spacing.d12,
                children: [
                  Expanded(
                    child: Label(
                      onPressed: () => setState(() => _pencil = !_pencil),
                      child: const Text('Write in pencil'),
                    ),
                  ),
                  Switch(
                    value: _pencil,
                    onChanged: (on) => setState(() => _pencil = on),
                    semanticLabel: 'Write in pencil',
                  ),
                ],
              ),
            ),
            _line(
              Row(
                spacing: Spacing.d12,
                children: [
                  const Label(child: Text('Pen pressure')),
                  Expanded(
                    child: Slider(
                      values: [_pressure],
                      onChanged: (values) =>
                          setState(() => _pressure = values.first),
                      semanticLabel: 'Pen pressure',
                    ),
                  ),
                  SizedBox(
                    width: Spacing.d32,
                    child: Text(
                      '${_pressure.round()}',
                      textAlign: TextAlign.end,
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 20,
                        cssLineHeight: 1,
                        color: theme.colors.inkYou,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _line(
              Checkbox(
                value: _tally,
                onChanged: (on) => setState(() => _tally = on),
                label: const Text('Keep score with tally marks'),
              ),
            ),
          ],
        ),
        const IndexCardFooter(children: [Text('no. 0007'), Text('p. 1')]),
      ],
    );
  }

  Widget _line(Widget child) => SizedBox(
    height: Spacing.d30,
    child: Align(alignment: AlignmentDirectional.centerStart, child: child),
  );
}
