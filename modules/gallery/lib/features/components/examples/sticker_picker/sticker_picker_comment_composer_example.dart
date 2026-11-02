import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

typedef _Post = ({String who, String text, String? sticker});

class StickerPickerCommentComposerExample extends StatefulWidget {
  const StickerPickerCommentComposerExample({super.key});

  @override
  State<StickerPickerCommentComposerExample> createState() =>
      _StickerPickerCommentComposerExampleState();
}

class _StickerPickerCommentComposerExampleState
    extends State<StickerPickerCommentComposerExample> {
  static const _maxWidth = 512.0;

  final TextEditingController _text = TextEditingController();
  String? _sticker;
  List<String> _recent = const ['stamp-approved'];
  List<_Post> _posts = const [
    (
      who: 'Maya',
      text: 'The new cover reads much better.',
      sticker: 'stamp-approved',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _text.addListener(_onText);
  }

  @override
  void dispose() {
    _text
      ..removeListener(_onText)
      ..dispose();
    super.dispose();
  }

  void _onText() => setState(() {});

  bool get _canPost => _text.text.trim().isNotEmpty || _sticker != null;

  void _choose(String name) => setState(() {
    _sticker = name;
    _recent = [
      name,
      for (final recent in _recent)
        if (recent != name) recent,
    ].take(5).toList();
  });

  void _post() {
    if (!_canPost) return;
    setState(() {
      _posts = [
        ..._posts,
        (who: 'You', text: _text.text.trim(), sticker: _sticker),
      ];
      _sticker = null;
    });
    _text.clear();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Card(
      gap: Spacing.d12,
      padding: const EdgeInsets.all(Spacing.d16),
      children: [
        Semantics(
          label: 'Comments',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: [for (final post in _posts) _Comment(post: post)],
          ),
        ),
        Textarea(
          controller: _text,
          placeholder: 'Write a comment',
          semanticLabel: 'Comment',
        ),
        Row(
          spacing: Spacing.d8,
          children: [
            StickerPicker(
              value: _sticker,
              recent: _recent,
              onSelect: (sticker) => _choose(sticker.name),
              content: const StickerPickerContent(),
              child: StickerPickerTrigger.builder(
                builder: (context, popover) => Button(
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.icon,
                  semanticLabel: 'Add a sticker',
                  onPressed: popover.toggle,
                  child: const InkIcon('sparkles'),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: switch (_sticker) {
                  final sticker? => Semantics(
                    button: true,
                    label: 'Remove the sticker',
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => _sticker = null),
                        child: Sticker(sticker, size: Spacing.d40),
                      ),
                    ),
                  ),
                  null => const SizedBox.shrink(),
                },
              ),
            ),
            Button(
              onPressed: _post,
              disabled: !_canPost,
              child: const Text('Post'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Comment extends StatelessWidget {
  const _Comment({required this.post});

  static const _stampSize = 96.0;
  static const _stickerSize = 72.0;

  final _Post post;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: [
        Text(
          post.who,
          style: theme.typography.face(
            KevinSansFace.script,
            cssSize: 20,
            cssLineHeight: 1.25,
            color: theme.colors.inkYou,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d4,
            children: [
              if (post.text.isNotEmpty) Text(post.text),
              if (post.sticker case final sticker?)
                Sticker(
                  sticker,
                  size: switch (sticker.startsWith('stamp-')) {
                    true => _stampSize,
                    false => _stickerSize,
                  },
                  semanticLabel: sticker,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
