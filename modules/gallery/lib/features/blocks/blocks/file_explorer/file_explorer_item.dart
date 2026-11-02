import 'package:gallery/features/blocks/blocks/file_explorer/file_explorer.dart';

/// What the listing is sorted by.
enum FileExplorerSortKey {
  name('Name'),
  modified('Last changed'),
  size('Size');

  const FileExplorerSortKey(this.label);

  final String label;
}

/// Rows in a table, or cards in a grid.
enum FileExplorerView { list, grid }

/// A node as listed: a folder also knows how many items it holds.
class FileExplorerItem {
  const FileExplorerItem(this.node, {this.items = 0});

  final FileExplorerNode node;
  final int items;

  String get id => node.id;
  String get name => node.name;
  bool get isFolder => node.isFolder;

  /// `4 items` for a folder, `5.8 MB · Sep 2` for a file.
  String get meta => switch (isFolder) {
    true =>
      '$items ${switch (items) {
        1 => 'item',
        _ => 'items',
      }}',
    false =>
      '${fileExplorerSize(node.size ?? 0)} · ${fileExplorerDay(node.modified)}',
  };

  /// What a screen reader hears after the name.
  String get spoken => switch (isFolder) {
    true => ', folder, $meta',
    false =>
      ', ${node.kind.label}, ${fileExplorerSize(node.size ?? 0)}, changed ${fileExplorerDay(node.modified)}',
  };
}

/// Folders first, then by [key]; ties fall back to the name.
List<FileExplorerNode> fileExplorerSort(
  Iterable<FileExplorerNode> list,
  FileExplorerSortKey key,
) {
  int byName(FileExplorerNode a, FileExplorerNode b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());
  return [...list]..sort((a, b) {
    if (a.isFolder != b.isFolder) {
      return switch (a.isFolder) {
        true => -1,
        false => 1,
      };
    }
    final first = switch (key) {
      FileExplorerSortKey.name => 0,
      FileExplorerSortKey.modified => b.modified.compareTo(a.modified),
      FileExplorerSortKey.size => (b.size ?? 0).compareTo(a.size ?? 0),
    };
    if (first != 0) return first;
    return byName(a, b);
  });
}
