import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/models/models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The surface an example is shown on: dot-grid paper (plain paper for
/// [ExampleLayout.full]) or the desk, laid out per [layout].
///
/// Mirrors `Stage` in upstream `src/docs/kit/Stage.tsx`.
class PreviewStage extends StatelessWidget {
  const PreviewStage({
    super.key,
    this.layout = ExampleLayout.center,
    this.stage = ExampleStage.paper,
    this.height,
    this.seed,
    required this.child,
  });

  final ExampleLayout layout;
  final ExampleStage stage;
  final double? height;
  final String? seed;
  final Widget child;

  static const double _centerMinHeight = 176;
  static const double _stackMaxWidth = 576;

  @override
  Widget build(BuildContext context) {
    final minHeight =
        height ??
        switch (layout) {
          ExampleLayout.center => _centerMinHeight,
          _ => 0.0,
        };
    final inner = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: switch (layout) {
        ExampleLayout.center => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d24,
            vertical: Spacing.d40,
          ),
          child: Center(child: child),
        ),
        ExampleLayout.stack => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d24,
            vertical: Spacing.d32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _stackMaxWidth),
              child: SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: child,
                ),
              ),
            ),
          ),
        ),
        ExampleLayout.full => child,
      },
    );
    return switch (stage) {
      ExampleStage.desk => Desk(seed: seed, child: inner),
      ExampleStage.paper => Paper(
        stock: switch (layout) {
          ExampleLayout.full => StockName.paper,
          _ => StockName.dotGrid,
        },
        tilt: false,
        shadow: PaperShadow.slip,
        seed: seed,
        child: inner,
      ),
    };
  }
}
