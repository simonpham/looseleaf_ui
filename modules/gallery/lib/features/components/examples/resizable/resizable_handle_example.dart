import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ResizableHandleExample extends StatelessWidget {
  const ResizableHandleExample({super.key});

  static const _maxWidth = Spacing.d448;
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
            ResizablePanel(defaultSize: 25, child: _Pane('Sidebar')),
            ResizableHandle(
              withHandle: true,
              semanticLabel: 'Resize the sidebar',
            ),
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
