import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StickerOnACardExample extends StatelessWidget {
  const StickerOnACardExample({super.key});

  static const _maxWidth = 384.0;
  static const _textMaxWidth = 256.0;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      IndexCard(
        seed: 'order-4471',
        maxWidth: _maxWidth,
        children: [
          const IndexCardHeader(children: [IndexCardTitle(Text('Order 4471'))]),
          IndexCardContent(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _textMaxWidth),
                child: const Text(
                  'Two notebooks, a pack of felt tips and one very small pencil.',
                ),
              ),
              const Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: Spacing.d48),
                    child: Text('Track parcel'),
                  ),
                  Positioned(
                    top: -Spacing.d4,
                    left: 0,
                    child: Sticker('cursor-click', size: 40, rotate: -6),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      const Positioned(
        top: -Spacing.d20,
        right: -Spacing.d16,
        child: Sticker('done', size: 64, rotate: 9),
      ),
    ],
  );
}
