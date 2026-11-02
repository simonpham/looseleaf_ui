import 'package:flutter/widgets.dart';
import 'package:gallery/features/settings/view_models/view_models.dart';
import 'package:gallery/features/shell/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// The display settings button and its popover: density, ink tier, motion,
/// direction and the things on the desk.
///
/// Mirrors `SettingsMenu` in upstream `src/docs/shell/SettingsMenu.tsx`
/// (tier and direction are the gallery's own).
class SettingsFrame extends StatelessWidget {
  const SettingsFrame({super.key});

  @override
  Widget build(BuildContext context) => Popover(
    content: const PopoverContent(
      align: OverlayAlign.end,
      tilt: false,
      width: 320,
      semanticLabel: 'Display settings',
      child: _SettingsBody(),
    ),
    child: PopoverTrigger.builder(
      builder: (context, popover) => Button(
        variant: ButtonVariant.ghost,
        size: ButtonSize.icon,
        semanticLabel: 'Display settings',
        onPressed: popover.toggle,
        child: const InkIcon('sliders-horizontal', size: Spacing.d20),
      ),
    ),
  );
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsViewModel>();
    final density = context.select<SettingsViewModel, LooseleafDensity>(
      (model) => model.density,
    );
    final tier = context.select<SettingsViewModel, LooseleafTier>(
      (model) => model.tier,
    );
    final motion = context.select<SettingsViewModel, LooseleafMotion>(
      (model) => model.motion,
    );
    final rightToLeft = context.select<SettingsViewModel, bool>(
      (model) => model.direction == TextDirection.rtl,
    );
    final clutter = context.select<SettingsViewModel, bool>(
      (model) => model.clutter,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d16,
      children: [
        SettingsGroup(
          label: 'Density',
          child: InkRadioGroup<LooseleafDensity>(
            value: density,
            onChanged: settings.setDensity,
            semanticLabel: 'Density',
            children: const [
              SettingsOption(
                value: LooseleafDensity.comfortable,
                label: 'Comfortable',
                hint: 'Roomy hit boxes, the full hand.',
              ),
              SettingsOption(
                value: LooseleafDensity.compact,
                label: 'Compact',
                hint: 'Tighter rows for dense screens.',
              ),
              SettingsOption(
                value: LooseleafDensity.calm,
                label: 'Calm',
                hint: 'Hairlines, no wobble: for data and long forms.',
              ),
            ],
          ),
        ),
        const Separator(variant: SeparatorVariant.dashed),
        SettingsGroup(
          label: 'Ink',
          child: InkRadioGroup<LooseleafTier>(
            value: tier,
            onChanged: settings.setTier,
            semanticLabel: 'Ink',
            children: const [
              SettingsOption(
                value: LooseleafTier.lo,
                label: 'Lo',
                hint: 'Fewer points per stroke: light and quick.',
              ),
              SettingsOption(
                value: LooseleafTier.hi,
                label: 'Hi',
                hint: 'Richer strokes, more texture.',
              ),
            ],
          ),
        ),
        const Separator(variant: SeparatorVariant.dashed),
        SettingsGroup(
          label: 'Motion',
          child: InkRadioGroup<LooseleafMotion>(
            value: motion,
            onChanged: settings.setMotion,
            semanticLabel: 'Motion',
            children: const [
              SettingsOption(
                value: LooseleafMotion.system,
                label: 'Follow system',
                hint: 'Motion unless your device asks for less.',
              ),
              SettingsOption(
                value: LooseleafMotion.reduced,
                label: 'Reduced',
                hint: 'No animation, no per-word jitter.',
              ),
            ],
          ),
        ),
        const Separator(variant: SeparatorVariant.dashed),
        SettingsSwitch(
          label: 'Right to left',
          value: rightToLeft,
          onChanged: settings.setRightToLeft,
        ),
        SettingsSwitch(
          label: 'Things on the desk',
          value: clutter,
          onChanged: settings.setClutter,
        ),
      ],
    );
  }
}
