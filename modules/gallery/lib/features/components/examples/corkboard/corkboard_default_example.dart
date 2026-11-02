import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CorkboardDefaultExample extends StatelessWidget {
  const CorkboardDefaultExample({super.key});

  static const _maxWidth = 672.0;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Corkboard(
      height: 360,
      children: [
        CorkboardNote(
          id: 'mum',
          x: 20,
          y: 26,
          child: Text('Call mum about Sunday'),
        ),
        CorkboardNote(
          id: 'ink',
          x: 250,
          y: 40,
          stock: StockName.stickyPink,
          rotate: 2.5,
          child: Text('Buy more ink!! (the blue felt)'),
        ),
        CorkboardNote(
          id: 'tape',
          x: 130,
          y: 190,
          stock: StockName.stickyGreen,
          pinned: false,
          rotate: -2,
          child: Text('Tape it up before Friday'),
        ),
      ],
    ),
  );
}
