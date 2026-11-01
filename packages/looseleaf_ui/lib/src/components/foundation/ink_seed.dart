import 'package:flutter/widgets.dart';

/// Gives a component its drawing seed, like upstream `useInkSeed`
/// (`src/lib/ink/react/hooks.ts`): the `seed` prop when one is given,
/// otherwise an id made once per [State], the way `useId()` is per mount.
///
/// The same seed always draws the same strokes; pass a `seed` to keep a
/// drawing stable across remounts (goldens, lists that rebuild).
mixin InkSeed<T extends StatefulWidget> on State<T> {
  static int _next = 0;

  late final String _generated = '«ll${(_next++).toRadixString(36)}»';

  /// [seed], or this state's generated id when [seed] is null.
  String inkSeed(String? seed) => seed ?? _generated;
}
