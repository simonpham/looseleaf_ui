import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PaperEdgesExample extends StatelessWidget {
  const PaperEdgesExample({super.key});

  static const _wide = 672.0;
  static const _edges = [
    (edge: EdgeSpec.all(EdgeKind.cut), seed: 'cut', name: 'cut'),
    (edge: EdgeSpec.all(EdgeKind.torn), seed: 'torn', name: 'torn'),
    (edge: EdgeSpec.all(EdgeKind.deckle), seed: 'deckle', name: 'deckle'),
    (edge: EdgeSpec.all(EdgeKind.crimp), seed: 'crimp', name: 'crimp'),
    (edge: EdgeSpec.all(EdgeKind.zig), seed: 'zig', name: 'zig'),
    (edge: EdgeSpec.all(EdgeKind.perf), seed: 'perf', name: 'perf'),
    (edge: EdgeSpec.all(EdgeKind.scallop), seed: 'scallop', name: 'scallop'),
    (
      edge: EdgeSpec(bottom: EdgeKind.torn),
      seed: 'one-side',
      name: 'torn below',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final caption = LooseleafTheme.of(context).typography.face(
      KevinSansFace.script,
      cssSize: 20,
      cssLineHeight: 1,
      fontWeight: FontWeight.w700,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth >= _wide) {
          true => 4,
          false => 2,
        };
        final width =
            (constraints.maxWidth - Spacing.d4 - Spacing.d32 * (columns - 1)) /
            columns;
        return Padding(
          padding: const EdgeInsets.all(Spacing.d8),
          child: Wrap(
            spacing: Spacing.d32,
            runSpacing: Spacing.d32,
            children: [
              for (final item in _edges)
                SizedBox(
                  width: width - Spacing.d12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d8,
                    children: [
                      Paper(
                        edge: item.edge,
                        seed: item.seed,
                        child: const SizedBox(height: Spacing.d80),
                      ),
                      Text(item.name, style: caption),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
