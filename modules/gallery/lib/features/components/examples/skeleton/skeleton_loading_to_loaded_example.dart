import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SkeletonLoadingToLoadedExample extends StatefulWidget {
  const SkeletonLoadingToLoadedExample({super.key});

  @override
  State<SkeletonLoadingToLoadedExample> createState() =>
      _SkeletonLoadingToLoadedExampleState();
}

class _SkeletonLoadingToLoadedExampleState
    extends State<SkeletonLoadingToLoadedExample> {
  static const _notes = [
    (
      title: 'Snail on a leaf',
      body: 'Three tries to get the shell to spiral the right way.',
    ),
    (
      title: 'Teapot, three ways',
      body: 'The third one leaks. The second one is a hat.',
    ),
  ];

  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _loading = true);
    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 2200),
      () => setState(() => _loading = false),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384),
        child: Card(
          seed: 'loaded',
          children: [
            CardHeader(
              children: [
                const CardTitle(Text('Recent pages')),
                CardDescription(
                  Text(switch (_loading) {
                    true => 'Finding your pages...',
                    false => 'Two pages, newest first.',
                  }),
                ),
              ],
            ),
            CardContent(
              child: Semantics(
                container: true,
                liveRegion: !_loading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d16,
                  children: [
                    for (final note in _notes)
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: Spacing.d52,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: Spacing.d4,
                          children: switch (_loading) {
                            true => const [
                              FractionallySizedBox(
                                widthFactor: 0.4,
                                child: Skeleton(height: Spacing.d16),
                              ),
                              Skeleton(height: Spacing.d14),
                            ],
                            false => [
                              Text(
                                note.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                note.body,
                                style: theme.typography.face(
                                  KevinSansFace.hand,
                                  cssSize: 15,
                                  cssLineHeight: 1.375,
                                  color: theme.colors.inkMuted,
                                ),
                              ),
                            ],
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            CardFooter(
              divider: true,
              children: [
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                  onPressed: _load,
                  child: const Text('Reload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
