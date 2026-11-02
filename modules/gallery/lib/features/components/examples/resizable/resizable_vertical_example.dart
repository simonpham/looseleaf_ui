import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ResizableVerticalExample extends StatelessWidget {
  const ResizableVerticalExample({super.key});

  static const _maxWidth = 384.0;
  static const _height = 288.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final muted = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Paper(
        stock: StockName.slip,
        tilt: false,
        seed: 'vertical',
        child: SizedBox(
          height: _height,
          child: ResizablePanelGroup(
            axis: Axis.vertical,
            children: [
              const ResizablePanel(
                defaultSize: 20,
                minSize: 10,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.d16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'Header',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const ResizableHandle(semanticLabel: 'Resize the header'),
              ResizablePanel(
                defaultSize: 55,
                minSize: 30,
                maxSize: 70,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.d24),
                  child: Center(
                    child: Text(
                      'The middle keeps between 30% and 70%.',
                      textAlign: TextAlign.center,
                      style: muted,
                    ),
                  ),
                ),
              ),
              const ResizableHandle(semanticLabel: 'Resize the footer'),
              ResizablePanel(
                defaultSize: 25,
                minSize: 10,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.d16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('Footer', style: muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
