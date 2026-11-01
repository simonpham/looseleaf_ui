import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The milky veil of a developing photo: the photo stock's white over the
/// picture, clearing after half a second. Runs once per mount; gone at once
/// where motion is reduced or the density is calm.
///
/// Mirrors the `develop` span of `PolaroidImage` in upstream
/// `src/components/ui/polaroid.tsx`.
class PolaroidVeil extends StatefulWidget {
  const PolaroidVeil({super.key});

  /// Upstream's `delay-500`.
  static const Duration delay = Duration(milliseconds: 500);

  /// `--ll-dur-soak`.
  static const Duration soak = Duration(milliseconds: 520);

  @override
  State<PolaroidVeil> createState() => _PolaroidVeilState();
}

class _PolaroidVeilState extends State<PolaroidVeil>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clear = AnimationController(
    vsync: this,
    duration: PolaroidVeil.soak,
  );
  Timer? _wait;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final theme = LooseleafTheme.of(context);
    if (InkMotion.reducedIn(context) ||
        theme.density == LooseleafDensity.calm) {
      _clear.value = 1;
      return;
    }
    _wait = Timer(PolaroidVeil.delay, () => unawaited(_clear.forward()));
  }

  @override
  void dispose() {
    _wait?.cancel();
    _clear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = LooseleafTheme.of(context).colors.photo;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _clear,
        builder: (context, _) {
          if (_clear.value >= 1) return const SizedBox.expand();
          return ColoredBox(
            color: photo.withValues(alpha: photo.a * (1 - _clear.value)),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}
