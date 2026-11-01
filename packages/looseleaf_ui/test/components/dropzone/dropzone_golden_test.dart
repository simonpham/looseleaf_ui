import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/kevin_sans.dart';
import '../../support/overlay_host.dart';

const _photo = DropzoneFile(
  name: 'garden.png',
  size: 245760,
  type: 'image/png',
);
const _notes = DropzoneFile(
  name: 'field-notes.pdf',
  size: 1887436,
  type: 'application/pdf',
);
const _archive = DropzoneFile(
  name: 'sketches.zip',
  size: 9437184,
  type: 'application/zip',
);
const _song = DropzoneFile(name: 'song.mp3', size: 4096, type: 'audio/mpeg');

Widget _zone(
  String seed, {
  bool dragOver = false,
  bool invalid = false,
  bool disabled = false,
  Set<InkState> states = const {},
}) => SizedBox(
  width: 300,
  child: Dropzone(
    accept: const ['image/*', '.pdf'],
    maxSize: 5 * 1024 * 1024,
    dragOver: dragOver,
    invalid: invalid,
    disabled: disabled,
    child: DropzoneArea(
      seed: seed,
      forcedStates: states,
      children: const [DropzoneIcon(), DropzoneTitle(), DropzoneDescription()],
    ),
  ),
);

Widget _panel(Widget child) => RepaintBoundary(
  child: ColoredBox(
    color: const LooseleafThemeData().colors.paper,
    child: Padding(
      padding: const EdgeInsets.all(Spacing.d24),
      child: child,
    ),
  ),
);

void main() {
  setUpAll(() async {
    await TestWidgetsFlutterBinding.ensureInitialized().runAsync(() async {
      await InkTextures.instance.load();
      await loadKevinSans();
    });
  });

  testWidgets('dropzone-states in the light theme', (tester) async {
    tester.view.physicalSize = const Size(1400, 1700);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      overlayHost(
        _panel(
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d24,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d16,
                children: [
                  _zone('rest'),
                  _zone('over', dragOver: true),
                  _zone('focus', states: const {InkState.focused}),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                spacing: Spacing.d16,
                children: [
                  _zone('invalid', invalid: true),
                  _zone('disabled', disabled: true),
                  SizedBox(
                    width: 300,
                    child: Dropzone(
                      accept: const ['image/*', '.pdf', '.zip'],
                      maxSize: 5 * 1024 * 1024,
                      initialFiles: const [_photo, _notes, _archive],
                      child: Builder(
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: Spacing.d12,
                          children: [
                            const DropzoneRejections(),
                            DropzoneList(
                              itemBuilder: (context, file, index) =>
                                  switch (index) {
                                    0 => DropzoneItem(
                                      file: file,
                                      status: DropzoneUploadStatus.done,
                                    ),
                                    1 => DropzoneItem(
                                      file: file,
                                      status: DropzoneUploadStatus.uploading,
                                      progress: 45,
                                    ),
                                    _ => DropzoneItem(
                                      file: file,
                                      status: DropzoneUploadStatus.error,
                                      error: 'The upload failed.',
                                    ),
                                  },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    tester.state<DropzoneState>(find.byType(Dropzone).last).add(const [_song]);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('../goldens/dropzone-states.png'),
    );
  });
}
