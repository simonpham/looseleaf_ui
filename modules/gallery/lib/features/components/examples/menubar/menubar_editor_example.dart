import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

enum _EditorPaper { ruled, graph, none }

class MenubarEditorExample extends StatefulWidget {
  const MenubarEditorExample({super.key});

  @override
  State<MenubarEditorExample> createState() => _MenubarEditorExampleState();
}

class _MenubarEditorExampleState extends State<MenubarEditorExample> {
  static const _maxWidth = 448.0;
  static const _minPageHeight = 160.0;

  bool _bold = false;
  bool _italic = false;
  _EditorPaper _paper = _EditorPaper.ruled;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          Menubar(
            seed: 'editor',
            children: [
              MenubarMenu(
                trigger: const MenubarTrigger(child: Text('Format')),
                content: MenubarContent(
                  children: [
                    const MenubarLabel(child: Text('Text')),
                    MenubarCheckboxItem(
                      value: _bold,
                      onChanged: (value) => setState(() => _bold = value),
                      trailing: const MenubarShortcut('⌘B'),
                      child: const Text('Bold'),
                    ),
                    MenubarCheckboxItem(
                      value: _italic,
                      onChanged: (value) => setState(() => _italic = value),
                      trailing: const MenubarShortcut('⌘I'),
                      child: const Text('Italic'),
                    ),
                  ],
                ),
              ),
              MenubarMenu(
                trigger: const MenubarTrigger(child: Text('Paper')),
                content: MenubarContent(
                  children: [
                    MenubarRadioGroup(
                      value: _paper.name,
                      onChanged: (value) => setState(
                        () => _paper = _EditorPaper.values.byName(value),
                      ),
                      children: const [
                        MenubarRadioItem(value: 'ruled', child: Text('Ruled')),
                        MenubarRadioItem(value: 'graph', child: Text('Graph')),
                        MenubarRadioItem(value: 'none', child: Text('Plain')),
                      ],
                    ),
                    const MenubarSeparator(),
                    const MenubarLabel(child: Text('Shown under your writing')),
                  ],
                ),
              ),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minPageHeight),
            child: Paper(
              stock: switch (_paper) {
                _EditorPaper.graph => StockName.graph,
                _ => StockName.paper,
              },
              rules: switch (_paper) {
                _EditorPaper.ruled => RuleName.ruled,
                _EditorPaper.graph => RuleName.graph,
                _EditorPaper.none => RuleName.none,
              },
              seed: 'editor-page',
              padding: switch (_paper) {
                _EditorPaper.ruled => const EdgeInsetsDirectional.fromSTEB(
                  Spacing.d56,
                  Spacing.d16,
                  Spacing.d24,
                  Spacing.d24,
                ),
                _ => const EdgeInsets.all(Spacing.d24),
              },
              child: Text(
                'Things to buy: ink, a good eraser, tape.',
                style: theme.typography
                    .interface(cssSize: 18)
                    .copyWith(
                      fontWeight: switch (_bold) {
                        true => FontWeight.w700,
                        false => FontWeight.w400,
                      },
                      fontStyle: switch (_italic) {
                        true => FontStyle.italic,
                        false => FontStyle.normal,
                      },
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
