import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = Spacing.d384;

class ToggleFollowButtonExample extends StatefulWidget {
  const ToggleFollowButtonExample({super.key});

  @override
  State<ToggleFollowButtonExample> createState() =>
      _ToggleFollowButtonExampleState();
}

class _ToggleFollowButtonExampleState extends State<ToggleFollowButtonExample> {
  bool _following = false;
  bool _muted = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Card(
            seed: 'follow',
            children: [
              const CardHeader(
                children: [
                  CardTitle(Text('Field notes')),
                  CardDescription(
                    Text(
                      'Sketches, half-thoughts and pressed flowers, twice a month.',
                    ),
                  ),
                ],
              ),
              CardContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d16,
                  children: [
                    Wrap(
                      spacing: Spacing.d12,
                      runSpacing: Spacing.d12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Toggle(
                          variant: ToggleVariant.outline,
                          value: _following,
                          onChanged: (value) =>
                              setState(() => _following = value),
                          semanticLabel: 'Follow Field notes',
                          leading: const InkIcon('bell'),
                          child: Text(switch (_following) {
                            true => 'Following',
                            false => 'Follow',
                          }),
                        ),
                        Toggle(
                          value: _muted,
                          onChanged: (value) => setState(() => _muted = value),
                          disabled: !_following,
                          semanticLabel: 'Mute new posts',
                          leading: const InkIcon('eye-off'),
                          child: const Text('Mute'),
                        ),
                      ],
                    ),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        switch ((_following, _muted)) {
                          (false, _) => 'You will not hear about new notes.',
                          (true, true) => 'Following, with new notes muted.',
                          (true, false) =>
                            'You will get an email for every new note.',
                        },
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
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
}
