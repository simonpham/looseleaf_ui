import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_appearance/settings_appearance.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Appearance settings on a hole-punched page: theme, density and motion
/// as choice cards, fine ink, the preview's paper and the reading
/// direction, with a live preview and the theme code to copy beside them.
///
/// Mirrors upstream `src/blocks/settings-appearance/page.tsx`.
class SettingsAppearanceBlock extends StatefulWidget {
  const SettingsAppearanceBlock({
    super.key,
    this.initialValue = const Appearance(),
    this.onChanged,
  });

  final Appearance initialValue;
  final ValueChanged<Appearance>? onChanged;

  @override
  State<SettingsAppearanceBlock> createState() =>
      _SettingsAppearanceBlockState();
}

class _SettingsAppearanceBlockState extends State<SettingsAppearanceBlock> {
  static const double _sideFrom = 896;
  static const double _sideWidth = 352;
  static const double _themesAcrossFrom = 576;
  static const double _motionsAcrossFrom = 512;

  late Appearance _appearance = widget.initialValue;

  void _set(Appearance next) {
    setState(() => _appearance = next);
    widget.onChanged?.call(next);
  }

  Widget _options(BuildContext context) {
    final appearance = _appearance;
    final isDefault = appearance == const Appearance();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d32,
      children: [
        SettingsAppearanceChoices<String>(
          legend: 'Theme',
          choices: appearanceThemes,
          value: appearance.theme,
          onChanged: (theme) => _set(appearance.copyWith(theme: theme)),
          columns: 3,
          columnsFrom: _themesAcrossFrom,
        ),
        SettingsAppearanceChoices<LooseleafDensity>(
          legend: 'Density',
          choices: appearanceDensities,
          value: appearance.density,
          onChanged: (density) => _set(appearance.copyWith(density: density)),
        ),
        SettingsAppearanceChoices<LooseleafMotion>(
          legend: 'Motion',
          choices: appearanceMotions,
          value: appearance.motion,
          onChanged: (motion) => _set(appearance.copyWith(motion: motion)),
          columns: 2,
          columnsFrom: _motionsAcrossFrom,
        ),
        const Separator(variant: SeparatorVariant.dashed),
        Field(
          orientation: FieldOrientation.horizontal,
          children: [
            FieldContent(
              children: [
                FieldLabel(
                  onPressed: () =>
                      _set(appearance.copyWith(fine: !appearance.fine)),
                  child: const Text('Fine ink'),
                ),
                const FieldDescription(
                  Text(
                    'Draws with more strokes. Lovely on a big screen, heavier on a small phone.',
                  ),
                ),
              ],
            ),
            Switch(
              value: appearance.fine,
              semanticLabel: 'Fine ink',
              onChanged: (fine) => _set(appearance.copyWith(fine: fine)),
            ),
          ],
        ),
        Field(
          children: [
            const FieldLabel(child: Text('Paper for the preview')),
            ToggleGroup<AppearancePaper>(
              variant: ToggleVariant.outline,
              wrap: true,
              value: {appearance.paper},
              semanticLabel: 'Paper for the preview',
              onChanged: (value) {
                if (value.firstOrNull case final paper?) {
                  _set(appearance.copyWith(paper: paper));
                }
              },
              children: [
                for (final paper in AppearancePaper.values)
                  ToggleGroupItem(value: paper, child: Text(paper.label)),
              ],
            ),
          ],
        ),
        Field(
          children: [
            const FieldLabel(child: Text('Reading direction')),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ToggleGroup<TextDirection>(
                variant: ToggleVariant.outline,
                value: {appearance.direction},
                semanticLabel: 'Reading direction',
                onChanged: (value) {
                  if (value.firstOrNull case final direction?) {
                    _set(appearance.copyWith(direction: direction));
                  }
                },
                children: const [
                  ToggleGroupItem(
                    value: TextDirection.ltr,
                    child: Text('Left to right'),
                  ),
                  ToggleGroupItem(
                    value: TextDirection.rtl,
                    child: Text('Right to left'),
                  ),
                ],
              ),
            ),
            const FieldDescription(
              Text(
                'Margins, tabs and arrows turn round; the handwriting does not.',
              ),
            ),
          ],
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Button(
            variant: ButtonVariant.outline,
            disabled: isDefault,
            onPressed: () => _set(const Appearance()),
            leading: const InkIcon('rotate-cw'),
            child: const Text('Back to the defaults'),
          ),
        ),
      ],
    );
  }

  Widget _side(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        SettingsAppearancePreview(appearance: _appearance),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d8,
          children: [
            Text(
              'Your theme',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 24,
                cssLineHeight: 1,
                fontWeight: FontWeight.w600,
                color: theme.colors.ink,
              ),
            ),
            CodeBlock(
              code: _appearance.snippet,
              language: 'ts',
              filename: 'main.dart',
              wrap: true,
              seed: 'appearance-snippet',
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.d20,
      vertical: Spacing.d40,
    ),
    child: PaperPage(
      width: PageWidth.xl,
      holes: PageHoles.top,
      seed: 'settings-appearance',
      children: [
        const PageHeader(
          children: [
            PageTitle(
              Text('Appearance'),
              underline: TitleMark.highlight,
              seed: 'appearance-title',
            ),
            PageDescription(
              Text(
                'How the desk feels. Choices apply to the preview straight away; the code below is what to give your own theme.',
              ),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < _sideFrom) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d40,
                children: [_options(context), _side(context)],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d40,
              children: [
                Expanded(child: _options(context)),
                SizedBox(width: _sideWidth, child: _side(context)),
              ],
            );
          },
        ),
      ],
    ),
  );
}
