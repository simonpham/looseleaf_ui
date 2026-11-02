import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

final Map<String, Widget> _animated = {
  'Boil': Boil(builder: (context, frame, seed) => Text('$frame')),
  'Collapsible': const Collapsible(
    child: CollapsibleContent(child: Text('Hidden')),
  ),
  'Confetti': const Confetti(child: Text('Party')),
  'Dialog': const Dialog(
    content: DialogContent(
      showCloseButton: false,
      children: [DialogTitle(Text('Title'))],
    ),
    child: Text('Open'),
  ),
  'FlipCard': const FlipCard(
    label: 'Flip',
    children: [
      FlipCardFront(children: [Text('Front')]),
      FlipCardBack(children: [Text('Back')]),
    ],
  ),
  'Marquee': const Marquee(label: 'News', children: [Text('Headline')]),
  'PeelCorner': const PeelCorner(children: [Text('Under')]),
  'Progress': const Progress(value: 45),
  'Reveal': const Reveal(nib: true, child: Text('Revealed')),
  'Sheet': const Sheet(
    content: SheetContent(
      children: [
        SheetHeader(children: [SheetTitle(Text('Title'))]),
      ],
    ),
    child: Text('Open'),
  ),
  'Skeleton': const Skeleton(width: 48, height: 16),
  'Spinner': const Spinner(),
  'StampSurface': const StampSurface(child: SizedBox(width: 48, height: 48)),
  'Stepper': Stepper(value: 1, onChanged: (_) {}),
  'Typewriter': Typewriter('Dear diary'),
  'TypingIndicator': const TypingIndicator(),
};

void main() {
  for (final MapEntry(key: name, value: widget) in _animated.entries) {
    testWidgets('$name mounts and unmounts without a frame in between', (
      tester,
    ) async {
      await tester.pumpWidget(componentHost(widget));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }
}
