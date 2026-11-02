import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ProgressDemoExample extends StatefulWidget {
  const ProgressDemoExample({super.key});

  @override
  State<ProgressDemoExample> createState() => _ProgressDemoExampleState();
}

class _ProgressDemoExampleState extends State<ProgressDemoExample> {
  double _progress = 13;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(milliseconds: 500),
      () => setState(() => _progress = 66),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    widthFactor: 0.6,
    child: Progress(value: _progress, semanticLabel: 'Progress'),
  );
}
