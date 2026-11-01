import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/component_host.dart';

class _Probe extends StatelessWidget {
  const _Probe({required this.log});

  final List<(int, LooseleafKnobs, String)> log;

  @override
  Widget build(BuildContext context) {
    log.add((
      BoilScope.frameOf(context),
      LooseleafTheme.of(context).knobs,
      BoilScope.seedOf(context, 'base'),
    ));
    return const SizedBox(width: 10, height: 10);
  }
}

void main() {
  testWidgets('cycles frames, multiplying knobs and reseeding', (
    tester,
  ) async {
    final log = <(int, LooseleafKnobs, String)>[];
    await tester.pumpWidget(componentHost(Boil(child: _Probe(log: log))));
    expect(log.last.$1, 0);
    expect(log.last.$2, const LooseleafKnobs());
    expect(log.last.$3, 'base');
    await tester.pump(const Duration(milliseconds: 170));
    await tester.pump();
    expect(log.last.$1, 1);
    final boil = boilKnobs(1);
    expect(log.last.$2.wobble, boil.wobble);
    expect(log.last.$3, 'base~1');
    await tester.pump(const Duration(milliseconds: 170));
    await tester.pump();
    expect(log.last.$1, 2);
    await tester.pump(const Duration(milliseconds: 170));
    await tester.pump();
    expect(log.last.$1, 0);
  });

  testWidgets('builder gets the frame and a seed helper', (tester) async {
    final seeds = <String>[];
    await tester.pumpWidget(
      componentHost(
        Boil(
          frames: 2,
          builder: (context, frame, seed) {
            seeds.add(seed('s'));
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 170));
    await tester.pump();
    expect(seeds, containsAllInOrder(['s', 's~1']));
  });

  for (final (name, theme) in [
    (
      'reduced motion',
      const LooseleafThemeData(motion: LooseleafMotion.reduced),
    ),
    ('calm density', const LooseleafThemeData(density: LooseleafDensity.calm)),
  ]) {
    testWidgets('$name holds it still', (tester) async {
      final log = <(int, LooseleafKnobs, String)>[];
      await tester.pumpWidget(
        componentHost(
          Boil(child: _Probe(log: log)),
          theme: theme,
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(log.map((entry) => entry.$1), everyElement(0));
    });
  }

  testWidgets('active false holds it still', (tester) async {
    final log = <(int, LooseleafKnobs, String)>[];
    await tester.pumpWidget(
      componentHost(Boil(active: false, child: _Probe(log: log))),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(log.map((entry) => entry.$1), everyElement(0));
  });
}
