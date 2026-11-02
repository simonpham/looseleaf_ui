import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ResizableDemoExample extends StatelessWidget {
  const ResizableDemoExample({super.key});

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
          children: [
            ResizablePanel(defaultSize: 50, child: _Pane('One')),
            ResizableHandle(
              semanticLabel: 'Resize the first panel',
            ),
            ResizablePanel(
              defaultSize: 50,
              child: ResizablePanelGroup(
                axis: Axis.vertical,
                children: [
                  ResizablePanel(defaultSize: 25, child: _Pane('Two')),
                  ResizableHandle(
                    semanticLabel: 'Resize the second panel',
                  ),
                  ResizablePanel(defaultSize: 75, child: _Pane('Three')),
                ],
              ),
            ),
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
