import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ResizablePanelsExample extends StatelessWidget {
  const ResizablePanelsExample({super.key});

  static const _maxWidth = 448.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Paper(
      stock: StockName.slip,
      tilt: false,
      seed: 'panels',
      child: SizedBox(
        height: Spacing.d256,
        child: ResizablePanelGroup(
          children: [
            ResizablePanel(defaultSize: 50, minSize: 20, child: _Pane('One')),
            ResizableHandle(
              withHandle: true,
              semanticLabel: 'Resize the first panel',
            ),
            ResizablePanel(
              defaultSize: 50,
              minSize: 20,
              child: ResizablePanelGroup(
                axis: Axis.vertical,
                children: [
                  ResizablePanel(
                    defaultSize: 25,
                    minSize: 10,
                    child: _Pane('Two'),
                  ),
                  ResizableHandle(
                    withHandle: true,
                    semanticLabel: 'Resize the second panel',
                  ),
                  ResizablePanel(
                    defaultSize: 75,
                    minSize: 10,
                    child: _Pane('Three'),
                  ),
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
        style: LooseleafTheme.of(context).typography.face(
          KevinSansFace.script,
          cssSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
