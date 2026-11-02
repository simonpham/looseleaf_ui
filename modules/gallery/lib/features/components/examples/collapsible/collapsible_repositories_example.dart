import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CollapsibleRepositoriesExample extends StatefulWidget {
  const CollapsibleRepositoriesExample({super.key});

  @override
  State<CollapsibleRepositoriesExample> createState() =>
      _CollapsibleRepositoriesExampleState();
}

class _CollapsibleRepositoriesExampleState
    extends State<CollapsibleRepositoriesExample> {
  static const _width = 350.0;

  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SizedBox(
      width: _width,
      child: Collapsible(
        open: _open,
        onOpenChange: (open) => setState(() => _open = open),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d8,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.d4),
              child: Row(
                spacing: Spacing.d16,
                children: [
                  Expanded(
                    child: Text(
                      'Starred this week: 3',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) => Button(
                      variant: ButtonVariant.ghost,
                      size: ButtonSize.iconSm,
                      semanticLabel: 'Toggle',
                      onPressed: Collapsible.of(context).toggle,
                      child: const InkIcon('chevrons-up-down'),
                    ),
                  ),
                ],
              ),
            ),
            const _Repo(
              seed: 'r1',
              stock: StockName.stickyYellow,
              name: 'radix-ui/primitives',
            ),
            const CollapsibleContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d8,
                children: [
                  _Repo(
                    seed: 'r2',
                    stock: StockName.stickyBlue,
                    name: 'tailwindlabs/tailwindcss',
                  ),
                  _Repo(
                    seed: 'r3',
                    stock: StockName.stickyGreen,
                    name: 'shadcn-ui/ui',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Repo extends StatelessWidget {
  const _Repo({required this.seed, required this.stock, required this.name});

  final String seed;
  final StockName stock;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.d4),
      child: Paper(
        stock: stock,
        seed: seed,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d12,
          vertical: Spacing.d8,
        ),
        child: Text(name, style: theme.typography.mono(cssSize: 14)),
      ),
    );
  }
}
