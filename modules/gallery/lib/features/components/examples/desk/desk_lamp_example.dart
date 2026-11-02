import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DeskLampExample extends StatelessWidget {
  const DeskLampExample({super.key});

  static const _wide = 640.0;
  static const _height = 208.0;
  static const _lamps = [0.0, 1.0, 2.5];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final desks = [
      for (final lamp in _lamps)
        SizedBox(
          height: _height,
          child: Desk(
            lamp: lamp,
            padding: const EdgeInsets.all(Spacing.d12),
            child: Center(
              child: Paper(
                stock: StockName.slip,
                tilt: false,
                seed: 'lamp-${_format(lamp)}',
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.d20,
                  vertical: Spacing.d16,
                ),
                child: Text(
                  'lamp: ${_format(lamp)}',
                  textAlign: TextAlign.center,
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 24,
                    cssLineHeight: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
    return Padding(
      padding: const EdgeInsets.all(Spacing.d16),
      child: LayoutBuilder(
        builder: (context, constraints) =>
            switch (constraints.maxWidth >= _wide) {
              true => Row(
                spacing: Spacing.d16,
                children: [for (final desk in desks) Expanded(child: desk)],
              ),
              false => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d16,
                children: desks,
              ),
            },
      ),
    );
  }

  static String _format(double lamp) => switch (lamp == lamp.roundToDouble()) {
    true => '${lamp.round()}',
    false => '$lamp',
  };
}
