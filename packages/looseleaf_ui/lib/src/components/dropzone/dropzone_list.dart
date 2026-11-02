import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_file.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_item.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_scope.dart';

/// Builds the row of a kept file.
typedef DropzoneItemBuilder =
    Widget Function(
      BuildContext context,
      DropzoneFile file,
      int index,
    );

/// The kept files, a [DropzoneItem] each (or [itemBuilder]'s rows);
/// nothing while there are none.
///
/// Mirrors `DropzoneList` in upstream `src/components/ui/dropzone.tsx`.
class DropzoneList extends StatelessWidget {
  const DropzoneList({
    super.key,
    this.itemBuilder,
    this.semanticLabel = 'Selected files',
  });

  final DropzoneItemBuilder? itemBuilder;

  /// The list's accessible name.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final files = DropzoneScope.of(context).state.files;
    if (files.isEmpty) return const SizedBox.shrink();
    final builder = itemBuilder;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, file) in files.indexed)
            KeyedSubtree(
              key: ValueKey(
                '${file.name}-${file.size}-${file.lastModified}-$index',
              ),
              child: switch (builder) {
                final build? => build(context, file, index),
                null => DropzoneItem(file: file),
              },
            ),
        ],
      ),
    );
  }
}
