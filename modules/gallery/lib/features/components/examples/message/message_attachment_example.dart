import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = Spacing.d384;

class MessageAttachmentExample extends StatelessWidget {
  const MessageAttachmentExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.d16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d32,
        children: [
          const Message(
            align: ChatAlign.end,
            children: [
              MessageContent(
                children: [
                  Attachment(
                    orientation: AttachmentOrientation.vertical,
                    children: [
                      AttachmentMedia(
                        variant: AttachmentMediaVariant.image,
                        child: Sticker(
                          'laptop-open',
                          size: Spacing.d80,
                          semanticLabel: 'Workspace',
                        ),
                      ),
                    ],
                  ),
                  Bubble(
                    children: [
                      BubbleContent(
                        child: Text(
                          "Here's the image. Can you add it to the PDF? Use it "
                          'for the cover page.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Message(
            children: [
              MessageContent(
                children: [
                  const Bubble(
                    variant: BubbleVariant.muted,
                    children: [
                      BubbleContent(
                        child: Text(
                          "Done. Here's the PDF with the image added as the "
                          'cover page.',
                        ),
                      ),
                    ],
                  ),
                  Attachment(
                    children: [
                      const AttachmentMedia(child: InkIcon('file-text')),
                      const AttachmentContent(
                        children: [
                          AttachmentTitle(child: Text('sales-dashboard.pdf')),
                          AttachmentDescription(child: Text('PDF · 2.4 MB')),
                        ],
                      ),
                      AttachmentActions(
                        children: [
                          Tooltip(
                            content: const TooltipContent(
                              child: Text('Download'),
                            ),
                            child: AttachmentAction(
                              size: ButtonSize.iconSm,
                              variant: ButtonVariant.secondary,
                              semanticLabel: 'Download',
                              onPressed: () {},
                              child: const InkIcon('download'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const Message(
            align: ChatAlign.end,
            children: [
              MessageContent(
                children: [
                  Bubble(
                    children: [
                      BubbleContent(child: Text('Thanks. Looks good.')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
