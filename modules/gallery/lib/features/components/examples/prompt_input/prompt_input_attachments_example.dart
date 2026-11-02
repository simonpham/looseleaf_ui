import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PromptInputAttachmentsExample extends StatefulWidget {
  const PromptInputAttachmentsExample({super.key});

  @override
  State<PromptInputAttachmentsExample> createState() =>
      _PromptInputAttachmentsExampleState();
}

typedef _File = ({int id, String name, String size});

class _PromptInputAttachmentsExampleState
    extends State<PromptInputAttachmentsExample> {
  static const _maxWidth = 576.0;
  static const _picks = [
    (name: 'garden-plan.png', size: '840 KB'),
    (name: 'seed-list.txt', size: '3 KB'),
    (name: 'sketch.jpg', size: '1.1 MB'),
  ];

  List<_File> _files = const [
    (id: 1, name: 'field-notes.pdf', size: '2.4 MB'),
  ];
  int _next = 2;

  void _pick() {
    final picked = _picks[_next % _picks.length];
    setState(() {
      _files = [..._files, (id: _next, name: picked.name, size: picked.size)];
      _next++;
    });
  }

  void _remove(int id) => setState(
    () => _files = [
      for (final file in _files)
        if (file.id != id) file,
    ],
  );

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.d8,
          0,
          Spacing.d8,
          Spacing.d12,
        ),
        child: PromptInput(
          seed: 'attach',
          allowEmpty: _files.isNotEmpty,
          onSubmit: (_) => setState(() => _files = const []),
          children: [
            PromptInputAttachments(
              children: [
                for (final file in _files)
                  Attachment(
                    key: ValueKey(file.id),
                    size: AttachmentSize.sm,
                    seed: file.name,
                    children: [
                      const AttachmentMedia(child: InkIcon('file-text')),
                      AttachmentContent(
                        children: [
                          AttachmentTitle(child: Text(file.name)),
                          AttachmentDescription(child: Text(file.size)),
                        ],
                      ),
                      AttachmentActions(
                        children: [
                          _RemoveFile(
                            name: file.name,
                            onRemove: () => _remove(file.id),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
            const PromptInputBody(
              child: PromptInputTextarea(
                placeholder: 'Say something about them...',
              ),
            ),
            PromptInputFooter(
              children: [
                PromptInputTools(
                  children: [
                    PromptInputButton(
                      size: ButtonSize.iconSm,
                      semanticLabel: 'Attach a file',
                      onPressed: _pick,
                      child: const InkIcon('paperclip'),
                    ),
                  ],
                ),
                const PromptInputSubmit(),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _RemoveFile extends StatelessWidget {
  const _RemoveFile({required this.name, required this.onRemove});

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final model = PromptInputModel.of(context);
    return AttachmentAction(
      semanticLabel: 'Remove $name',
      onPressed: () {
        onRemove();
        model.focus();
      },
      child: const InkIcon('x'),
    );
  }
}
