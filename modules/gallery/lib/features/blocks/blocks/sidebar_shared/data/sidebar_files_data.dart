/// A file, or a folder when it has [children].
class FileNode {
  const FileNode(this.name, [this.children]);

  final String name;
  final List<FileNode>? children;
}

/// A changed file and its git state letter.
class FileChange {
  const FileChange(this.file, this.state);

  final String file;

  /// `M` modified, `U` untracked.
  final String state;

  /// The state spelled out for screen readers.
  String get stateName => switch (state) {
    'M' => 'modified',
    'U' => 'untracked',
    _ => state,
  };
}

const fileChanges = [
  FileChange('README.md', 'M'),
  FileChange('api/hello/route.ts', 'U'),
  FileChange('app/layout.tsx', 'M'),
];

const fileTree = [
  FileNode('app', [
    FileNode('api', [
      FileNode('hello', [FileNode('route.ts')]),
    ]),
    FileNode('page.tsx'),
    FileNode('layout.tsx'),
    FileNode('blog', [FileNode('page.tsx')]),
  ]),
  FileNode('components', [
    FileNode('ui', [FileNode('button.tsx'), FileNode('card.tsx')]),
    FileNode('header.tsx'),
    FileNode('footer.tsx'),
  ]),
  FileNode('lib', [FileNode('util.ts')]),
  FileNode('public', [FileNode('favicon.ico'), FileNode('pencil.svg')]),
  FileNode('.eslintrc.json'),
  FileNode('.gitignore'),
  FileNode('next.config.js'),
  FileNode('tailwind.config.js'),
  FileNode('package.json'),
  FileNode('README.md'),
];
