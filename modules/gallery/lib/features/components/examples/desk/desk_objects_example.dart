import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DeskObjectsExample extends StatelessWidget {
  const DeskObjectsExample({super.key});

  static const _minHeight = 416.0;
  static const _maxWidth = 448.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minHeight),
      child: Desk(
        objects: DeskObject.values,
        seed: 'objects',
        padding: const EdgeInsets.fromLTRB(
          Spacing.d32,
          Spacing.d64,
          Spacing.d32,
          Spacing.d96,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Paper(
              seed: 'mid',
              padding: const EdgeInsets.all(Spacing.d32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d12,
                children: [
                  Text(
                    'A tidy desk',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 30,
                      cssLineHeight: 1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Everything lying around is behind the paper, hidden on small screens, and gone in calm density.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
