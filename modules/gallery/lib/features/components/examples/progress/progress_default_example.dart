import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ProgressDefaultExample extends StatefulWidget {
  const ProgressDefaultExample({super.key});

  @override
  State<ProgressDefaultExample> createState() => _ProgressDefaultExampleState();
}

class _ProgressDefaultExampleState extends State<ProgressDefaultExample> {
  double _value = 13;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(milliseconds: 600),
      () => setState(() => _value = 66),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SizedBox(
      width: math.max(constraints.maxWidth * 0.6, Spacing.d192),
      child: Progress(value: _value, semanticLabel: 'Chapter progress'),
    ),
  );
}
