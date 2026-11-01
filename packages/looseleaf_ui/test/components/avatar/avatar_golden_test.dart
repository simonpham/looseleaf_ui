import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';
import '../../support/kevin_sans.dart';
import 'portrait.dart';

void main() {
  late MemoryImage warm;
  late MemoryImage cool;

  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
      warm = await portrait(const Color(0xFFF6C9A0), const Color(0xFFC98A68));
      cool = await portrait(const Color(0xFFB8D4EA), const Color(0xFF6F97BE));
    });
  });

  testWidgets('avatar-avatars in the light theme', (tester) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      componentHost(
        goldenPanel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: Spacing.d24,
                children: [
                  Avatar(
                    size: AvatarSize.sm,
                    seed: 'a1',
                    children: [
                      AvatarImage(image: warm),
                      const AvatarFallback(name: 'Ada Lovelace'),
                    ],
                  ),
                  Avatar(
                    seed: 'a2',
                    children: [
                      AvatarImage(image: cool),
                      const AvatarFallback(name: 'Jo Okafor'),
                      const AvatarBadge(
                        status: AvatarStatus.online,
                        seed: 'b2',
                      ),
                    ],
                  ),
                  const Avatar(
                    size: AvatarSize.lg,
                    seed: 'a3',
                    children: [
                      AvatarFallback(name: 'Mika Kobayashi'),
                      AvatarBadge(status: AvatarStatus.away, seed: 'b3'),
                    ],
                  ),
                  const Avatar(
                    size: AvatarSize.xl,
                    seed: 'a4',
                    children: [
                      AvatarFallback(name: 'Sam Reyes'),
                      AvatarBadge(status: AvatarStatus.busy, seed: 'b4'),
                    ],
                  ),
                  const Avatar(
                    size: AvatarSize.lg,
                    ring: AvatarRing.marker,
                    seed: 'a5',
                    children: [AvatarFallback(name: 'Lena Fischer')],
                  ),
                  const Avatar(
                    size: AvatarSize.lg,
                    ring: AvatarRing.you,
                    seed: 'a6',
                    children: [AvatarFallback(name: 'Tomas Berg')],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final tone in AvatarTone.values)
                    Padding(
                      padding: const EdgeInsets.only(right: Spacing.d12),
                      child: Avatar(
                        ring: null,
                        children: [
                          AvatarFallback(
                            tone: tone,
                            seed: tone.name,
                            child: Text(tone.name.substring(0, 2)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              AvatarGroup(
                children: [
                  Avatar(
                    seed: 'g1',
                    children: [
                      AvatarImage(image: warm),
                      const AvatarFallback(name: 'Ada Lovelace'),
                    ],
                  ),
                  const Avatar(
                    seed: 'g2',
                    children: [AvatarFallback(name: 'Jo Okafor')],
                  ),
                  Avatar(
                    seed: 'g3',
                    children: [
                      AvatarImage(image: cool),
                      const AvatarFallback(name: 'Mika Kobayashi'),
                    ],
                  ),
                  const Avatar(
                    seed: 'g4',
                    children: [AvatarFallback(name: 'Sam Reyes')],
                  ),
                  const AvatarGroupCount(seed: 'gc', child: Text('+3')),
                ],
              ),
              const AvatarGroup(
                size: AvatarSize.lg,
                children: [
                  Avatar(
                    seed: 'h1',
                    children: [AvatarFallback(name: 'Priya Nair')],
                  ),
                  Avatar(
                    seed: 'h2',
                    children: [AvatarFallback(name: 'Tomas Berg')],
                  ),
                  Avatar(
                    seed: 'h3',
                    children: [AvatarFallback(name: 'Lena Fischer')],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      final context = tester.element(find.byType(Column).first);
      await precacheImage(warm, context);
      await precacheImage(cool, context);
    });
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/avatar-avatars.png'),
    );
  });
}
