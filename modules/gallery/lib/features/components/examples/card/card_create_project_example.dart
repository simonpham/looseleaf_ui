import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-[350px]`.
const _maxWidth = 350.0;

const _frameworks = {
  'next': 'Next.js',
  'sveltekit': 'SvelteKit',
  'astro': 'Astro',
  'nuxt': 'Nuxt.js',
};

class CardCreateProjectExample extends StatefulWidget {
  const CardCreateProjectExample({super.key});

  @override
  State<CardCreateProjectExample> createState() =>
      _CardCreateProjectExampleState();
}

class _CardCreateProjectExampleState extends State<CardCreateProjectExample> {
  final _name = TextEditingController();
  String? _framework;
  String _status = '';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _deploy() {
    final name = switch (_name.text) {
      '' => 'untitled',
      final text => text,
    };
    setState(
      () => _status = 'Deploying "$name" on ${_framework ?? 'no framework'}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            seed: 'create',
            children: [
              const CardHeader(
                children: [
                  CardTitle(Text('Create project')),
                  CardDescription(
                    Text('Deploy your new project in one click.'),
                  ),
                ],
              ),
              CardContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d24,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d12,
                      children: [
                        const Label(child: Text('Name')),
                        Input(
                          controller: _name,
                          placeholder: 'Name of your project',
                          semanticLabel: 'Name',
                          onSubmitted: (_) => _deploy(),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d12,
                      children: [
                        const Label(child: Text('Framework')),
                        Select(
                          value: _framework,
                          onChanged: (value) =>
                              setState(() => _framework = value),
                          content: SelectContent(
                            position: SelectPosition.popper,
                            children: [
                              for (final MapEntry(:key, :value)
                                  in _frameworks.entries)
                                SelectItem(value: key, child: Text(value)),
                            ],
                          ),
                          child: const SelectTrigger(
                            child: SelectValue(placeholder: 'Select'),
                          ),
                        ),
                      ],
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: Spacing.d24),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _status,
                          style: theme.typography.interface(
                            cssSize: 14,
                            color: theme.colors.inkMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CardFooter(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Button(
                    variant: ButtonVariant.outline,
                    onPressed: () =>
                        setState(() => _status = 'Nothing deployed.'),
                    child: const Text('Cancel'),
                  ),
                  Button(onPressed: _deploy, child: const Text('Deploy')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
