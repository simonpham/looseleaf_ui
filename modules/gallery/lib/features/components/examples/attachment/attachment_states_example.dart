import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AttachmentStatesExample extends StatelessWidget {
  const AttachmentStatesExample({super.key});

  static const _maxWidth = 320.0;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.d16,
          Spacing.d12,
          Spacing.d16,
          Spacing.d16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d24,
          children: [
            Attachment(
              seed: 'done',
              children: [
                const AttachmentMedia(child: InkIcon('file-text')),
                const AttachmentContent(
                  children: [
                    AttachmentTitle(child: Text('field-notes.pdf')),
                    AttachmentDescription(child: Text('2.4 MB · pdf')),
                  ],
                ),
                AttachmentActions(
                  children: [
                    AttachmentAction(
                      semanticLabel: 'Remove field-notes.pdf',
                      onPressed: () {},
                      child: const InkIcon('x'),
                    ),
                  ],
                ),
              ],
            ),
            Attachment(
              state: AttachmentState.uploading,
              seed: 'uploading',
              children: [
                const AttachmentMedia(child: InkIcon('file-code')),
                const AttachmentContent(
                  children: [
                    AttachmentTitle(child: Text('tags-list.tsx')),
                    AttachmentDescription(child: Text('Uploading 42 %')),
                    AttachmentProgress(
                      value: 42,
                      semanticLabel: 'Upload progress',
                    ),
                  ],
                ),
                AttachmentActions(
                  children: [
                    AttachmentAction(
                      semanticLabel: 'Cancel upload',
                      onPressed: () {},
                      child: const InkIcon('x'),
                    ),
                  ],
                ),
              ],
            ),
            const Attachment(
              state: AttachmentState.processing,
              seed: 'processing',
              children: [
                AttachmentMedia(child: InkIcon('file')),
                AttachmentContent(
                  children: [
                    AttachmentTitle(child: Text('recipes.csv')),
                    AttachmentDescription(child: Text('Reading the rows')),
                    AttachmentProgress(semanticLabel: 'Processing'),
                  ],
                ),
              ],
            ),
            Attachment(
              state: AttachmentState.error,
              seed: 'error',
              children: [
                const AttachmentMedia(child: InkIcon('archive')),
                const AttachmentContent(
                  children: [
                    AttachmentTitle(child: Text('holiday-photos.zip')),
                    AttachmentDescription(child: Text('Too large. Max 25 MB')),
                  ],
                ),
                AttachmentActions(
                  children: [
                    AttachmentAction(
                      semanticLabel: 'Try again',
                      onPressed: () {},
                      child: const InkIcon('rotate-cw'),
                    ),
                  ],
                ),
              ],
            ),
            const Attachment(
              state: AttachmentState.idle,
              seed: 'idle',
              children: [
                AttachmentMedia(child: InkIcon('upload')),
                AttachmentContent(
                  children: [
                    AttachmentTitle(child: Text('Add a file')),
                    AttachmentDescription(child: Text('or drop it here')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
