import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class LabelTermsExample extends StatefulWidget {
  const LabelTermsExample({super.key});

  @override
  State<LabelTermsExample> createState() => _LabelTermsExampleState();
}

class _LabelTermsExampleState extends State<LabelTermsExample> {
  bool _accepted = false;

  void _toggle() => setState(() => _accepted = !_accepted);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: Spacing.d8,
    children: [
      Checkbox(
        value: _accepted,
        semanticLabel: 'Accept terms and conditions',
        onChanged: (accepted) => setState(() => _accepted = accepted),
      ),
      Label(
        onPressed: _toggle,
        child: const Text('Accept terms and conditions'),
      ),
    ],
  );
}
