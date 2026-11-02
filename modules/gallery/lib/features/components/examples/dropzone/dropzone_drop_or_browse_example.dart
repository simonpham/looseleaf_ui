import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Stands in for the app's file picker: each browse picks the next file.
const _picks = [
  DropzoneFile(name: 'pressed-flowers.png', size: 840000, type: 'image/png'),
  DropzoneFile(name: 'reading-list.pdf', size: 210000, type: 'application/pdf'),
  DropzoneFile(name: 'sketch.jpg', size: 1400000, type: 'image/jpeg'),
  DropzoneFile(name: 'scan.png', size: 3200000, type: 'image/png'),
  DropzoneFile(name: 'garden.jpg', size: 960000, type: 'image/jpeg'),
  DropzoneFile(name: 'kitchen.png', size: 520000, type: 'image/png'),
  DropzoneFile(name: 'desk.jpg', size: 700000, type: 'image/jpeg'),
];

class DropzoneDropOrBrowseExample extends StatefulWidget {
  const DropzoneDropOrBrowseExample({super.key});

  @override
  State<DropzoneDropOrBrowseExample> createState() =>
      _DropzoneDropOrBrowseExampleState();
}

class _DropzoneDropOrBrowseExampleState
    extends State<DropzoneDropOrBrowseExample> {
  static const _maxWidth = Spacing.d512;

  int _next = 0;

  Future<List<DropzoneFile>?> _browse() async => [
    _picks[_next++ % _picks.length],
  ];

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Dropzone(
      accept: const ['image/*'],
      maxSize: 2 * 1024 * 1024,
      maxFiles: 4,
      onBrowse: _browse,
    ),
  );
}
