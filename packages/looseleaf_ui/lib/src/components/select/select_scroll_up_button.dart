import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';

/// The chevron at the top of a scrolled [SelectContent]; resting the
/// pointer on it scrolls up.
///
/// Mirrors `SelectScrollUpButton` in upstream `src/components/ui/select.tsx`.
class SelectScrollUpButton extends StatelessWidget {
  const SelectScrollUpButton({super.key});

  @override
  Widget build(BuildContext context) => const SelectScrollButton(up: true);
}
