import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PaperRuledNoteExample extends StatelessWidget {
  const PaperRuledNoteExample({super.key});

  static const _maxWidth = 448.0;
  static const _minHeight = 236.0;
  static const _pitch = 28.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _maxWidth,
          minHeight: _minHeight,
        ),
        child: Paper(
          rules: RuleName.ruled,
          seed: 'notes',
          padding: const EdgeInsetsDirectional.fromSTEB(
            Spacing.d56,
            Spacing.d16,
            Spacing.d16,
            Spacing.d24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(0, Spacing.d3 - Spacing.d8),
                child: Text(
                  'Field notes',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 27.2,
                    cssLineHeight: _pitch / 27.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Tuesday. Rain on the window, three cups of tea, and one very small plan for a very big week.',
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 15,
                  cssLineHeight: _pitch / 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
