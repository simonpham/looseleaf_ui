import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SpinnerCustomExample extends StatelessWidget {
  const SpinnerCustomExample({super.key});

  @override
  Widget build(BuildContext context) => const _LoaderSpinner();
}

class _LoaderSpinner extends StatefulWidget {
  const _LoaderSpinner();

  @override
  State<_LoaderSpinner> createState() => _LoaderSpinnerState();
}

class _LoaderSpinnerState extends State<_LoaderSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _turn.stop();
      return;
    }
    if (!_turn.isAnimating) _turn.repeat();
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'Loading',
    child: RotationTransition(
      turns: _turn,
      child: const InkIcon('loader-circle'),
    ),
  );
}
