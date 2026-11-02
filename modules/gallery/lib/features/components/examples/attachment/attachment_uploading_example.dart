import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class AttachmentUploadingExample extends StatefulWidget {
  const AttachmentUploadingExample({super.key});

  @override
  State<AttachmentUploadingExample> createState() =>
      _AttachmentUploadingExampleState();
}

class _AttachmentUploadingExampleState
    extends State<AttachmentUploadingExample> {
  static const _maxWidth = Spacing.d384;
  static const _tick = Duration(milliseconds: 220);

  var _value = 0;
  Timer? _timer;

  bool get _done => _value >= 100;

  @override
  void initState() {
    super.initState();
    _upload();
  }

  void _upload() {
    _timer?.cancel();
    setState(() => _value = 0);
    _timer = Timer.periodic(_tick, (timer) {
      if (_done) {
        timer.cancel();
        return;
      }
      setState(() => _value = math.min(100, _value + 7));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.d16,
          Spacing.d12,
          Spacing.d16,
          Spacing.d16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d16,
          children: [
            SizedBox(
              width: double.infinity,
              child: Attachment(
                state: switch (_done) {
                  true => AttachmentState.done,
                  false => AttachmentState.uploading,
                },
                seed: 'live',
                children: [
                  const AttachmentMedia(child: InkIcon('file-code')),
                  AttachmentContent(
                    children: [
                      const AttachmentTitle(child: Text('tags-list.tsx')),
                      AttachmentDescription(
                        child: Text(switch (_done) {
                          true => 'Uploaded',
                          false => 'Uploading $_value %',
                        }),
                      ),
                      if (!_done)
                        AttachmentProgress(
                          value: _value.toDouble(),
                          semanticLabel: 'Upload progress',
                        ),
                    ],
                  ),
                  if (_done)
                    AttachmentTrigger(
                      semanticLabel: 'Open tags-list.tsx',
                      onPressed: _upload,
                    ),
                  AttachmentActions(
                    children: [
                      AttachmentAction(
                        semanticLabel: switch (_done) {
                          true => 'Remove tags-list.tsx',
                          false => 'Cancel upload',
                        },
                        onPressed: () {},
                        child: const InkIcon('x'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Button(
              variant: ButtonVariant.ghost,
              size: ButtonSize.sm,
              onPressed: _upload,
              child: const Text('Upload again'),
            ),
          ],
        ),
      ),
    ),
  );
}
