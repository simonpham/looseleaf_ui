import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ResizableVerticalDemoExample extends StatelessWidget {
  const ResizableVerticalDemoExample({super.key});

  static const _maxWidth = 448.0;
  static const _height = 200.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Paper(
      stock: StockName.slip,
      tilt: false,
      child: SizedBox(
        height: _height,
        child: ResizablePanelGroup(
          axis: Axis.vertical,
          children: [
            ResizablePanel(defaultSize: 25, child: _Pane('Header')),
            ResizableHandle(semanticLabel: 'Resize the header'),
            ResizablePanel(defaultSize: 75, child: _Pane('Content')),
          ],
        ),
      ),
    ),
  );
}

class _Pane extends StatelessWidget {
  const _Pane(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: Spacing.d24),
    child: Center(
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
