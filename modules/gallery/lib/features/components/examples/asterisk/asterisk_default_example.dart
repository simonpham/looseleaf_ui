import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AsteriskDefaultExample extends StatelessWidget {
  const AsteriskDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.interface(cssSize: 17),
      child: const Asterisk(child: Text('Free shipping')),
    );
  }
}
