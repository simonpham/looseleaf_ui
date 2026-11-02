import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ConfettiDefaultExample extends StatelessWidget {
  const ConfettiDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => ConfettiTrigger(
    builder: (context, burst) => Button(
      size: ButtonSize.lg,
      onPressed: burst,
      child: const Text('Celebrate'),
    ),
  );
}
