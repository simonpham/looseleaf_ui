import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TearOffDefaultExample extends StatelessWidget {
  const TearOffDefaultExample({super.key});

  static const _stubWidth = 128.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final title = theme.typography.face(
      KevinSansFace.script,
      cssSize: 30,
      cssLineHeight: 1,
    );
    final small = theme.typography.interface(cssSize: 14);
    return TearOff(
      children: [
        TearOffBody(
          width: Spacing.d256,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Studio night', style: title),
              const SizedBox(height: Spacing.d8),
              Text('Friday, doors at 7', style: small),
              const SizedBox(height: Spacing.d12),
              Text(
                'admit one, keep this half',
                style: small.copyWith(color: theme.colors.pencilText),
              ),
            ],
          ),
        ),
        TearOffStub(
          width: _stubWidth,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 0,
          padding: const EdgeInsets.fromLTRB(
            Spacing.d16,
            Spacing.d14,
            Spacing.d16,
            Spacing.d8,
          ),
          label: 'Tear off the 10% off coupon',
          children: [
            Text(
              '10% off',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 30,
                cssLineHeight: 1,
              ),
            ),
            Text(
              'your next visit',
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: 14,
                cssLineHeight: 30 / 14,
                color: theme.colors.pencilText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
