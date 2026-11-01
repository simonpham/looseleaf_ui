import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The same controls in each density, side by side.
class DensitySamples extends StatelessWidget {
  const DensitySamples({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Wrap(
      spacing: Spacing.d40,
      runSpacing: Spacing.d32,
      children: [
        for (final density in LooseleafDensity.values)
          LooseleafTheme(
            data: theme.copyWith(density: density),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d12,
              children: [
                Text(
                  density.name,
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.colors.inkYou,
                  ),
                ),
                Button(
                  onPressed: () {},
                  seed: 'density-button',
                  child: const Text('Save changes'),
                ),
                Button(
                  variant: ButtonVariant.outline,
                  onPressed: () {},
                  seed: 'density-outline',
                  child: const Text('Cancel'),
                ),
                Checkbox(
                  value: true,
                  onChanged: (_) {},
                  seed: 'density-check',
                  label: const Text('Remember me'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
