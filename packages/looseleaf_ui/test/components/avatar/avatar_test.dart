import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import 'portrait.dart';

void main() {
  testWidgets('sizes are 24, 32, 40 and 56', (tester) async {
    for (final (size, side) in [
      (AvatarSize.sm, 24.0),
      (AvatarSize.regular, 32.0),
      (AvatarSize.lg, 40.0),
      (AvatarSize.xl, 56.0),
    ]) {
      await tester.pumpWidget(
        componentHost(
          Avatar(
            size: size,
            children: const [AvatarFallback(name: 'Jo')],
          ),
        ),
      );
      expect(tester.getSize(find.byType(Avatar)), Size(side, side));
    }
  });

  testWidgets('dimension sets any side, size-12', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Avatar(
          dimension: Spacing.d48,
          children: [AvatarFallback(child: Text('LR'))],
        ),
      ),
    );
    expect(tester.getSize(find.byType(Avatar)), const Size.square(48));
  });

  testWidgets('the fallback shows initials, reads the name and keeps a tone', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      componentHost(
        const Avatar(children: [AvatarFallback(name: 'Mika Kobayashi')]),
      ),
    );
    expect(find.text('MK'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(AvatarFallback)),
      matchesSemantics(label: 'Mika Kobayashi'),
    );
    final disc = tester
        .widgetList<InkSurface>(find.byType(InkSurface))
        .firstWhere(
          (surface) => surface.source.id.startsWith('avatar-fallback'),
        );
    expect(
      disc.source.paramsKey,
      contains(avatarTone('Mika Kobayashi').name),
    );
    expect(disc.seed, 'Mika Kobayashi');
    handle.dispose();
  });

  testWidgets('the fallback gives way once the image loads', (tester) async {
    final image = await tester.runAsync(
      () => portrait(const Color(0xFFF6C9A0), const Color(0xFFC98A68)),
    );
    await tester.pumpWidget(
      componentHost(
        Avatar(
          children: [
            if (image != null) AvatarImage(image: image),
            const AvatarFallback(name: 'Ada Lovelace'),
          ],
        ),
      ),
    );
    expect(find.text('AL'), findsOneWidget);
    await tester.runAsync(() async {
      await precacheImage(
        image ?? MemoryImage(Uint8List(0)),
        tester.element(find.byType(Avatar)),
      );
    });
    await tester.pumpAndSettle();
    expect(find.text('AL'), findsNothing);
  });

  testWidgets('ring none draws no ring', (tester) async {
    await tester.pumpWidget(
      componentHost(const Avatar(ring: null, children: [AvatarFallback()])),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is InkSurface && widget.source.id.startsWith('avatar-ring'),
      ),
      findsNothing,
    );
  });

  testWidgets('the badge sits on the bottom end corner', (tester) async {
    await tester.pumpWidget(
      componentHost(
        const Avatar(
          size: AvatarSize.lg,
          children: [
            AvatarFallback(name: 'Sam'),
            AvatarBadge(status: AvatarStatus.online),
          ],
        ),
      ),
    );
    final badge = tester.getRect(find.byType(AvatarBadge));
    final avatar = tester.getRect(find.byType(Avatar));
    expect(badge.size, const Size(12, 12));
    expect(badge.bottomRight, avatar.bottomRight);
  });

  testWidgets('a group overlaps its avatars and sizes the count', (
    tester,
  ) async {
    await tester.pumpWidget(
      componentHost(
        const AvatarGroup(
          size: AvatarSize.lg,
          children: [
            Avatar(children: [AvatarFallback(name: 'A')]),
            Avatar(children: [AvatarFallback(name: 'B')]),
            AvatarGroupCount(child: Text('+3')),
          ],
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(AvatarGroup)),
      const Size(3 * 40 - 2 * 8, 40),
    );
    expect(tester.getSize(find.byType(AvatarGroupCount)), const Size(40, 40));
  });
}
