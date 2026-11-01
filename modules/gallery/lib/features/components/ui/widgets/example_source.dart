import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';

/// The code of an example or a block, read from the gallery's bundled
/// sources.
class ExampleSource extends StatefulWidget {
  const ExampleSource({
    super.key,
    required this.source,
    this.root = examplesRoot,
    this.label = 'examples',
  });

  /// The file under [root].
  final String source;

  /// The bundled folder [source] is relative to.
  final String root;

  /// The folder name shown before [source] in the title.
  final String label;

  static const String examplesRoot =
      'packages/gallery/lib/features/components/examples';

  @override
  State<ExampleSource> createState() => _ExampleSourceState();
}

class _ExampleSourceState extends State<ExampleSource> {
  late Future<String> _code = _load();

  Future<String> _load() =>
      rootBundle.loadString('${widget.root}/${widget.source}');

  @override
  void didUpdateWidget(ExampleSource oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) _code = _load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _code,
    builder: (context, snapshot) => switch (snapshot) {
      AsyncSnapshot(hasError: true) => const DocHint(
        'The source of this example is not bundled.',
      ),
      AsyncSnapshot(data: final code?) => DocCodeBlock(
        code: code,
        title: '${widget.label}/${widget.source}',
      ),
      _ => const SizedBox.shrink(),
    },
  );
}
