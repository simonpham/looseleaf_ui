import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AttachmentPrintsExample extends StatelessWidget {
  const AttachmentPrintsExample({super.key});

  static const _maxWidth = 672.0;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final prints = [
      ('harbour.jpg', '1.8 MB', 'sun', colors.sky.withValues(alpha: 0.45)),
      (
        'sketch-04.png',
        '620 KB',
        'flower',
        colors.lemon.withValues(alpha: 0.5),
      ),
      (
        'mushrooms.jpg',
        '2.1 MB',
        'mushroom',
        colors.bubblegum.withValues(alpha: 0.4),
      ),
      ('night.jpg', '980 KB', 'star', colors.grass.withValues(alpha: 0.4)),
    ];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: AttachmentGroup(
          children: [
            for (final (name, size, doodle, tint) in prints)
              Attachment(
                orientation: AttachmentOrientation.vertical,
                seed: name,
                children: [
                  AttachmentMedia(
                    variant: AttachmentMediaVariant.image,
                    color: tint,
                    child: Doodle(doodle, size: 64, seed: name),
                  ),
                  AttachmentContent(
                    children: [
                      AttachmentTitle(child: Text(name)),
                      AttachmentDescription(child: Text(size)),
                    ],
                  ),
                  AttachmentTrigger(
                    semanticLabel: 'Open $name',
                    onPressed: () {},
                  ),
                  AttachmentActions(
                    children: [
                      AttachmentAction(
                        semanticLabel: 'Remove $name',
                        onPressed: () {},
                        child: const InkIcon('x'),
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
}
