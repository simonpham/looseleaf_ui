import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';

/// The chevron at the bottom of a [SelectContent] with more below;
/// resting the pointer on it scrolls down.
///
/// Mirrors `SelectScrollDownButton` in upstream
/// `src/components/ui/select.tsx`.
class SelectScrollDownButton extends StatelessWidget {
  const SelectScrollDownButton({super.key});

  @override
  Widget build(BuildContext context) => const SelectScrollButton(up: false);
}
