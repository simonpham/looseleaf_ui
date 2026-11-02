import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Stands in for the app's file picker: each browse picks the next file.
const _picks = [
  DropzoneFile(name: 'field-notes.pdf', size: 412000, type: 'application/pdf'),
  DropzoneFile(name: 'garden.jpg', size: 1250000, type: 'image/jpeg'),
  DropzoneFile(name: 'upload-fail.png', size: 690000, type: 'image/png'),
];

typedef _Upload = ({double progress, DropzoneUploadStatus status});

class DropzoneAttachWithProgressExample extends StatefulWidget {
  const DropzoneAttachWithProgressExample({super.key});

  @override
  State<DropzoneAttachWithProgressExample> createState() =>
      _DropzoneAttachWithProgressExampleState();
}

class _DropzoneAttachWithProgressExampleState
    extends State<DropzoneAttachWithProgressExample> {
  static const _maxWidth = Spacing.d512;

  int _next = 0;
  List<DropzoneFile> _files = const [];
  final _uploads = <DropzoneFile, _Upload>{};
  final _timers = <DropzoneFile, Timer>{};

  bool get _busy => _files.any(
    (file) => _uploads[file]?.status == DropzoneUploadStatus.uploading,
  );

  Future<List<DropzoneFile>?> _browse() async => [
    _picks[_next++ % _picks.length],
  ];

  void _change(List<DropzoneFile> files) {
    for (final file in [..._timers.keys]) {
      if (files.contains(file)) continue;
      _timers.remove(file)?.cancel();
    }
    for (final file in files) {
      if (_uploads.containsKey(file)) continue;
      _uploads[file] = (progress: 0, status: DropzoneUploadStatus.uploading);
      _timers[file] = Timer.periodic(
        const Duration(milliseconds: 240),
        (_) => _tick(file),
      );
    }
    setState(() => _files = files);
  }

  void _tick(DropzoneFile file) {
    final progress = math.min(
      100.0,
      (_uploads[file]?.progress ?? 0) + 8 + file.size % 7,
    );
    final status = switch ((progress >= 100, file.name.contains('fail'))) {
      (false, _) => DropzoneUploadStatus.uploading,
      (true, true) => DropzoneUploadStatus.error,
      (true, false) => DropzoneUploadStatus.done,
    };
    if (progress >= 100) _timers.remove(file)?.cancel();
    setState(() => _uploads[file] = (progress: progress, status: status));
  }

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        seed: 'attach',
        tape: PaperTape.top,
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Attach to this note')),
              CardDescription(
                Text(
                  'Photos and PDFs, up to 3 MB each. A file with "fail" in its name will fail.',
                ),
              ),
            ],
          ),
          CardContent(
            child: Dropzone(
              accept: const ['image/*', '.pdf'],
              maxSize: 3 * 1024 * 1024,
              files: _files,
              onFilesChange: _change,
              onBrowse: _browse,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d12,
                children: [
                  const DropzoneArea(
                    minHeight: Spacing.d128,
                    children: [
                      DropzoneIcon(),
                      DropzoneTitle(),
                      DropzoneDescription(),
                    ],
                  ),
                  const DropzoneRejections(),
                  DropzoneList(
                    itemBuilder: (context, file, index) {
                      final upload = _uploads[file];
                      final status =
                          upload?.status ?? DropzoneUploadStatus.idle;
                      return DropzoneItem(
                        file: file,
                        status: status,
                        progress: upload?.progress,
                        error: switch (status) {
                          DropzoneUploadStatus.error =>
                            'The upload failed. Remove it and try again.',
                          _ => null,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          CardFooter(
            divider: true,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(
                  switch ((_files.isEmpty, _busy)) {
                    (true, _) => 'Nothing attached.',
                    (false, true) => 'Sending...',
                    (false, false) => '${_files.length} attached.',
                  },
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkMuted,
                  ),
                ),
              ),
              Button(
                disabled: _files.isEmpty || _busy,
                onPressed: () {},
                child: const Text('Save note'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
