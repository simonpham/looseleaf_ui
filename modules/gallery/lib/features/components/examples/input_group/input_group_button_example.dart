import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class InputGroupButtonExample extends StatefulWidget {
  const InputGroupButtonExample({super.key});

  @override
  State<InputGroupButtonExample> createState() =>
      _InputGroupButtonExampleState();
}

class _InputGroupButtonExampleState extends State<InputGroupButtonExample> {
  static const _profile = 'https://x.com/shadcn';

  final _link = TextEditingController(text: _profile);
  Timer? _reset;
  bool _copied = false;
  bool _favorite = false;

  void _copy() {
    unawaited(Clipboard.setData(const ClipboardData(text: _profile)));
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(
      const Duration(seconds: 2),
      () => setState(() => _copied = false),
    );
  }

  @override
  void dispose() {
    _reset?.cancel();
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d24,
        children: [
          InputGroup(
            children: [
              InputGroupInput(
                controller: _link,
                readOnly: true,
                semanticLabel: 'Profile link',
              ),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: InputGroupButton(
                  size: InputGroupButtonSize.iconXs,
                  semanticLabel: 'Copy',
                  onPressed: _copy,
                  child: InkIcon(switch (_copied) {
                    true => 'check',
                    false => 'copy',
                  }),
                ),
              ),
            ],
          ),
          InputGroup(
            children: [
              InputGroupAddon(
                child: Popover(
                  content: PopoverContent(
                    align: OverlayAlign.start,
                    child: DefaultTextStyle.merge(
                      style: theme.typography.interface(cssSize: 14),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d4,
                        children: [
                          Text(
                            'Your connection is not secure.',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'You should not enter any sensitive information on this site.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: PopoverTrigger.builder(
                    builder: (context, popover) => InputGroupButton(
                      variant: ButtonVariant.secondary,
                      size: InputGroupButtonSize.iconXs,
                      semanticLabel: 'Connection details',
                      onPressed: popover.toggle,
                      child: const InkIcon('info'),
                    ),
                  ),
                ),
              ),
              const InputGroupAddon(
                child: InputGroupText(child: Text('https://')),
              ),
              const InputGroupInput(semanticLabel: 'Address'),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: Semantics(
                  toggled: _favorite,
                  child: InputGroupButton(
                    size: InputGroupButtonSize.iconXs,
                    semanticLabel: 'Favorite',
                    onPressed: () => setState(() => _favorite = !_favorite),
                    child: InkIcon(
                      'star',
                      color: switch (_favorite) {
                        true => theme.colors.inkYou,
                        false => null,
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          InputGroup(
            children: [
              const InputGroupInput(
                placeholder: 'Type to search...',
                semanticLabel: 'Search',
              ),
              InputGroupAddon(
                align: InputGroupAlign.inlineEnd,
                child: InputGroupButton(
                  variant: ButtonVariant.secondary,
                  onPressed: () {},
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
