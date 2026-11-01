import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/models/models.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';

class BlockPage extends StatelessWidget {
  const BlockPage({super.key, required this.doc, required this.block});

  final BlockDoc doc;
  final GalleryBlock block;

  @override
  Widget build(BuildContext context) =>
      DocPage(title: doc.title, children: [block.builder()]);
}
