import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_appearance/settings_appearance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A taped sheet of controls drawn with [appearance]'s theme, so every
/// choice shows straight away.
class SettingsAppearancePreview extends StatefulWidget {
  const SettingsAppearancePreview({super.key, required this.appearance});

  final Appearance appearance;

  @override
  State<SettingsAppearancePreview> createState() =>
      _SettingsAppearancePreviewState();
}

class _SettingsAppearancePreviewState extends State<SettingsAppearancePreview> {
  static const double _pitch = 28;
  static const double _calmPitch = 24;

  var _outlined = true;
  var _shared = true;

  @override
  Widget build(BuildContext context) {
    final appearance = widget.appearance;
    final theme = appearance.apply(LooseleafTheme.of(context));
    final paper = appearance.paper;
    final ruled = paper.rules == RuleName.ruled;
    final calm = theme.density == LooseleafDensity.calm;
    final pitch = switch (calm) {
      true => _calmPitch,
      false => _pitch,
    };
    return LooseleafTheme(
      data: theme,
      child: Directionality(
        textDirection: appearance.direction,
        child: Semantics(
          container: true,
          label: 'Preview',
          child: Paper(
            stock: paper.stock,
            rules: paper.rules,
            mirrorRules: appearance.direction == TextDirection.rtl,
            tape: PaperTape.top,
            seed: 'appearance-preview',
            padding: switch (ruled) {
              true => const EdgeInsetsDirectional.fromSTEB(
                Spacing.d56,
                Spacing.d16,
                Spacing.d20,
                Spacing.d20,
              ),
              false => const EdgeInsetsDirectional.fromSTEB(
                Spacing.d20,
                Spacing.d24,
                Spacing.d20,
                Spacing.d20,
              ),
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: switch (ruled) {
                    true => 0,
                    false => Spacing.d16,
                  },
                  children: [
                    Transform.translate(
                      offset: switch ((ruled, calm)) {
                        (true, true) => const Offset(
                          0,
                          Spacing.d1 - Spacing.d6,
                        ),
                        (true, false) => const Offset(
                          0,
                          Spacing.d3 - Spacing.d8,
                        ),
                        _ => Offset.zero,
                      },
                      child: Text(
                        'Field notes',
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: 24,
                          cssLineHeight: switch (ruled) {
                            true => pitch / 24,
                            false => 1,
                          },
                          fontWeight: FontWeight.w600,
                          color: theme.colors.ink,
                        ),
                      ),
                    ),
                    Text(
                      'Tuesday. Rain on the window, three cups of tea, and one very small plan for a very big week.',
                      style: theme.typography.face(
                        KevinSansFace.hand,
                        cssSize: 15,
                        cssLineHeight: switch (ruled) {
                          true => pitch / 15,
                          false => null,
                        },
                        color: theme.colors.ink,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: Spacing.d8,
                  runSpacing: Spacing.d8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Button(
                      size: ButtonSize.sm,
                      onPressed: () {},
                      child: const Text('Save'),
                    ),
                    Button(
                      size: ButtonSize.sm,
                      variant: ButtonVariant.outline,
                      onPressed: () {},
                      child: const Text('Cancel'),
                    ),
                    const Badge(child: Text('3 new')),
                    const Tally(count: 7, size: TallySize.sm, label: '7 pages'),
                  ],
                ),
                const Input(
                  semanticLabel: 'Add a tag',
                  placeholder: 'Add a tag',
                ),
                Row(
                  spacing: Spacing.d8,
                  children: [
                    Checkbox(
                      value: _outlined,
                      onChanged: (value) => setState(() => _outlined = value),
                    ),
                    Flexible(
                      child: Label(
                        onPressed: () => setState(() => _outlined = !_outlined),
                        child: const Text('Ink the outline'),
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: Spacing.d8,
                  children: [
                    Switch(
                      value: _shared,
                      onChanged: (value) => setState(() => _shared = value),
                    ),
                    Flexible(
                      child: Label(
                        onPressed: () => setState(() => _shared = !_shared),
                        child: const Text('Share with the club'),
                      ),
                    ),
                  ],
                ),
                const Progress(value: 64, semanticLabel: 'Pages done'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
