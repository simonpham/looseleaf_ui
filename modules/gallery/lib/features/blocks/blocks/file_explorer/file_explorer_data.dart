/// What a file is, with its icon and the word a screen reader says.
enum FileExplorerKind {
  folder('folder', 'Folder'),
  doc('file-text', 'Document'),
  pdf('file', 'PDF'),
  image('image', 'Image'),
  sheet('table', 'Spreadsheet'),
  audio('music', 'Audio'),
  video('video', 'Video'),
  code('file-code', 'Code'),
  archive('archive', 'Archive');

  const FileExplorerKind(this.icon, this.label);

  final String icon;
  final String label;
}

/// A file or folder in the cabinet. [parent] is a folder's id or a root's.
class FileExplorerNode {
  const FileExplorerNode({
    required this.id,
    required this.parent,
    required this.name,
    required this.kind,
    required this.modified,
    this.size,
  });

  final String id;
  final String parent;
  final String name;
  final FileExplorerKind kind;

  /// Bytes; null for folders.
  final double? size;

  /// An ISO day, `2026-09-25`.
  final String modified;

  bool get isFolder => kind == FileExplorerKind.folder;
}

/// A drawer of the cabinet.
typedef FileExplorerRoot = ({String id, String name});

const List<FileExplorerRoot> fileExplorerRoots = [
  (id: 'projects', name: 'Projects'),
  (id: 'receipts', name: 'Receipts'),
  (id: 'photos', name: 'Photos'),
  (id: 'music', name: 'Music'),
];

const double _kb = 1024;
const double _mb = 1024 * _kb;

const List<FileExplorerNode> fileExplorerNodes = [
  FileExplorerNode(
    id: 'f1',
    parent: 'projects',
    name: 'Autumn drop',
    kind: FileExplorerKind.folder,
    modified: '2026-09-25',
  ),
  FileExplorerNode(
    id: 'f2',
    parent: 'projects',
    name: 'Journal',
    kind: FileExplorerKind.folder,
    modified: '2026-09-22',
  ),
  FileExplorerNode(
    id: 'n1',
    parent: 'projects',
    name: 'brand-guide.pdf',
    kind: FileExplorerKind.pdf,
    size: 5.8 * _mb,
    modified: '2026-09-02',
  ),
  FileExplorerNode(
    id: 'n2',
    parent: 'projects',
    name: 'notes-2026.txt',
    kind: FileExplorerKind.doc,
    size: 18 * _kb,
    modified: '2026-09-24',
  ),
  FileExplorerNode(
    id: 'n3',
    parent: 'f1',
    name: 'price-tags.pdf',
    kind: FileExplorerKind.pdf,
    size: 1.2 * _mb,
    modified: '2026-09-27',
  ),
  FileExplorerNode(
    id: 'n4',
    parent: 'f1',
    name: 'sticker-sheet-v3.png',
    kind: FileExplorerKind.image,
    size: 3.4 * _mb,
    modified: '2026-09-25',
  ),
  FileExplorerNode(
    id: 'n5',
    parent: 'f1',
    name: 'newsletter-draft.doc',
    kind: FileExplorerKind.doc,
    size: 48 * _kb,
    modified: '2026-09-25',
  ),
  FileExplorerNode(
    id: 'n6',
    parent: 'f1',
    name: 'launch-plan.xlsx',
    kind: FileExplorerKind.sheet,
    size: 96 * _kb,
    modified: '2026-09-21',
  ),
  FileExplorerNode(
    id: 'n7',
    parent: 'f2',
    name: 'why-the-margin.md',
    kind: FileExplorerKind.doc,
    size: 7 * _kb,
    modified: '2026-09-22',
  ),
  FileExplorerNode(
    id: 'n8',
    parent: 'f2',
    name: 'cover-sketches.zip',
    kind: FileExplorerKind.archive,
    size: 12.4 * _mb,
    modified: '2026-09-10',
  ),
  FileExplorerNode(
    id: 'f3',
    parent: 'receipts',
    name: '2026',
    kind: FileExplorerKind.folder,
    modified: '2026-09-30',
  ),
  FileExplorerNode(
    id: 'n9',
    parent: 'receipts',
    name: 'invoice-118.pdf',
    kind: FileExplorerKind.pdf,
    size: 210 * _kb,
    modified: '2026-09-18',
  ),
  FileExplorerNode(
    id: 'n10',
    parent: 'receipts',
    name: 'washi-tape-order.pdf',
    kind: FileExplorerKind.pdf,
    size: 134 * _kb,
    modified: '2026-09-14',
  ),
  FileExplorerNode(
    id: 'n11',
    parent: 'f3',
    name: 'september.pdf',
    kind: FileExplorerKind.pdf,
    size: 322 * _kb,
    modified: '2026-09-25',
  ),
  FileExplorerNode(
    id: 'n12',
    parent: 'f3',
    name: 'august.pdf',
    kind: FileExplorerKind.pdf,
    size: 290 * _kb,
    modified: '2026-08-31',
  ),
  FileExplorerNode(
    id: 'n13',
    parent: 'f3',
    name: 'july.pdf',
    kind: FileExplorerKind.pdf,
    size: 305 * _kb,
    modified: '2026-07-31',
  ),
  FileExplorerNode(
    id: 'f4',
    parent: 'photos',
    name: 'Notebooks',
    kind: FileExplorerKind.folder,
    modified: '2026-09-24',
  ),
  FileExplorerNode(
    id: 'f5',
    parent: 'photos',
    name: 'Studio',
    kind: FileExplorerKind.folder,
    modified: '2026-09-12',
  ),
  FileExplorerNode(
    id: 'n14',
    parent: 'photos',
    name: 'ada-birthday.jpg',
    kind: FileExplorerKind.image,
    size: 2.9 * _mb,
    modified: '2026-09-26',
  ),
  FileExplorerNode(
    id: 'n15',
    parent: 'f4',
    name: 'notebook-01.jpg',
    kind: FileExplorerKind.image,
    size: 3.1 * _mb,
    modified: '2026-09-24',
  ),
  FileExplorerNode(
    id: 'n16',
    parent: 'f4',
    name: 'notebook-02.jpg',
    kind: FileExplorerKind.image,
    size: 2.8 * _mb,
    modified: '2026-09-24',
  ),
  FileExplorerNode(
    id: 'n17',
    parent: 'f4',
    name: 'notebook-03.jpg',
    kind: FileExplorerKind.image,
    size: 3.4 * _mb,
    modified: '2026-09-24',
  ),
  FileExplorerNode(
    id: 'n18',
    parent: 'f5',
    name: 'kiln-day.jpg',
    kind: FileExplorerKind.image,
    size: 4.2 * _mb,
    modified: '2026-09-10',
  ),
  FileExplorerNode(
    id: 'n19',
    parent: 'f5',
    name: 'desk-in-the-morning.jpg',
    kind: FileExplorerKind.image,
    size: 3.7 * _mb,
    modified: '2026-09-12',
  ),
  FileExplorerNode(
    id: 'n20',
    parent: 'music',
    name: 'Sunday morning.mp3',
    kind: FileExplorerKind.audio,
    size: 6.1 * _mb,
    modified: '2026-08-16',
  ),
  FileExplorerNode(
    id: 'n21',
    parent: 'music',
    name: 'Field recording, rain.wav',
    kind: FileExplorerKind.audio,
    size: 41 * _mb,
    modified: '2026-09-03',
  ),
  FileExplorerNode(
    id: 'n22',
    parent: 'music',
    name: 'kiln-playlist.m3u',
    kind: FileExplorerKind.code,
    size: 2 * _kb,
    modified: '2026-09-10',
  ),
  FileExplorerNode(
    id: 'n23',
    parent: 'music',
    name: 'studio-tour.mov',
    kind: FileExplorerKind.video,
    size: 212 * _mb,
    modified: '2026-09-19',
  ),
];

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// `5.8 MB`, `18 KB`, `212 MB`: one decimal under 100 MB, like upstream.
String fileExplorerSize(double bytes) {
  if (bytes < _kb) return '${bytes.round()} B';
  if (bytes < _mb) return '${(bytes / _kb).round()} KB';
  final mb = bytes / _mb;
  if (mb >= 100) return '${mb.round()} MB';
  final tenths = (mb * 10).round();
  if (tenths % 10 == 0) return '${tenths ~/ 10} MB';
  return '${tenths / 10} MB';
}

/// `Sep 25`, with the year only when it is not 2026.
String fileExplorerDay(String iso) {
  final [year, month, day] = iso.split('-');
  final name = _months.elementAtOrNull(int.parse(month) - 1) ?? month;
  final suffix = switch (year) {
    '2026' => '',
    _ => ', $year',
  };
  return '$name ${int.parse(day)}$suffix';
}

/// [id] and every node under it.
Set<String> fileExplorerWithDescendants(
  List<FileExplorerNode> list,
  String id,
) {
  final out = {id};
  var grew = true;
  while (grew) {
    grew = false;
    for (final node in list) {
      if (out.contains(node.id) || !out.contains(node.parent)) continue;
      out.add(node.id);
      grew = true;
    }
  }
  return out;
}

/// How many nodes sit directly in [id].
int fileExplorerCountIn(List<FileExplorerNode> list, String id) =>
    list.where((node) => node.parent == id).length;
