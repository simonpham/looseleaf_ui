import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Two pages side by side once there is room for both, stacked otherwise
/// (upstream's `@2xl:grid-cols-2`).
class PageTwoUp extends StatelessWidget {
  const PageTwoUp({super.key, required this.first, required this.second});

  static const double _sideBySideFrom = 672;

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Spacing.d8),
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _sideBySideFrom) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d40,
            children: [first, second],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d40,
            children: [
              Expanded(child: first),
              Expanded(child: second),
            ],
          ),
        );
      },
    ),
  );
}
