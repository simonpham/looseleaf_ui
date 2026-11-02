import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A small right-aligned number field inside a table cell; it keeps its
/// own text while it is typed in and follows [value] otherwise.
class Dashboard01NumberCell extends StatefulWidget {
  const Dashboard01NumberCell({
    super.key,
    required this.value,
    required this.semanticLabel,
    required this.onChanged,
  });

  static const double _width = 64;

  final String value;
  final String semanticLabel;
  final ValueChanged<String> onChanged;

  @override
  State<Dashboard01NumberCell> createState() => _Dashboard01NumberCellState();
}

class _Dashboard01NumberCellState extends State<Dashboard01NumberCell> {
  late final _text = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(Dashboard01NumberCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _text.text) _text.text = widget.value;
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerEnd,
    child: SizedBox(
      width: Dashboard01NumberCell._width,
      child: Input(
        controller: _text,
        semanticLabel: widget.semanticLabel,
        textAlign: TextAlign.end,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: widget.onChanged,
      ),
    ),
  );
}
