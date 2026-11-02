import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ResizablePersistedExample extends StatefulWidget {
  const ResizablePersistedExample({super.key});

  @override
  State<ResizablePersistedExample> createState() =>
      _ResizablePersistedExampleState();
}

class _ResizablePersistedExampleState extends State<ResizablePersistedExample> {
  static const _maxWidth = Spacing.d448;
  static const _height = 160.0;
  static const _defaultLayout = [35.0, 65.0];

  List<double> _saved = _defaultLayout;
  int _resets = 0;
  bool _mounted = true;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final title = theme.typography.face(
      KevinSansFace.script,
      cssSize: 20,
      fontWeight: FontWeight.w600,
    );
    final [notes, canvas] = _saved;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          switch (_mounted) {
            true => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d12,
              children: [
                Paper(
                  stock: StockName.slip,
                  tilt: false,
                  seed: 'remembered',
                  child: SizedBox(
                    height: _height,
                    child: ResizablePanelGroup(
                      key: ValueKey(_resets),
                      onLayout: (layout) => _saved = layout,
                      children: [
                        ResizablePanel(
                          defaultSize: notes,
                          minSize: 15,
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.d16),
                            child: Text('Notes', style: title),
                          ),
                        ),
                        const ResizableHandle(
                          withHandle: true,
                          semanticLabel: 'Resize the notes',
                        ),
                        ResizablePanel(
                          defaultSize: canvas,
                          minSize: 30,
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.d16),
                            child: Text('Canvas', style: title),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                  onPressed: () => setState(() {
                    _saved = _defaultLayout;
                    _resets++;
                  }),
                  child: const Text('Reset to 35 / 65'),
                ),
              ],
            ),
            false => SizedBox(
              height: _height,
              child: Center(
                child: Text(
                  'Unmounted. Bring it back and it will remember.',
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ),
            ),
          },
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Button(
              size: ButtonSize.sm,
              onPressed: () => setState(() => _mounted = !_mounted),
              child: Text(switch (_mounted) {
                true => 'Unmount',
                false => 'Remount',
              }),
            ),
          ),
        ],
      ),
    );
  }
}
