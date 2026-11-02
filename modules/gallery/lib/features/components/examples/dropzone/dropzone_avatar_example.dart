import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Stands in for the app's file picker.
const _pick = DropzoneFile(
  name: 'me-at-the-beach.png',
  size: 420000,
  type: 'image/png',
  preview: AssetImage(
    'lib/features/components/examples/dropzone/portrait.png',
    package: 'gallery',
  ),
);

class DropzoneAvatarExample extends StatelessWidget {
  const DropzoneAvatarExample({super.key});

  static const _width = Spacing.d288;
  static const _minHeight = Spacing.d224;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _width,
    child: Dropzone(
      multiple: false,
      accept: const ['image/png', 'image/jpeg'],
      maxSize: 1024 * 1024,
      onBrowse: () async => [_pick],
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minHeight),
        child: const DropzoneArea(children: [_Content()]),
      ),
    ),
  );
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final files = Dropzone.of(context).files;
    if (files.firstOrNull case final file?) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d12,
        children: [
          _Preview(file),
          DropzoneDescription(
            child: Text('${file.name} (drop another to replace it)'),
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const DropzoneIcon(),
        DropzoneTitle(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Drop a photo or '),
                TextSpan(
                  text: 'browse',
                  style: TextStyle(
                    color: theme.colors.inkYou,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.wavy,
                    decorationColor: theme.colors.inkYou,
                  ),
                ),
              ],
            ),
          ),
        ),
        const DropzoneDescription(),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview(this.file);

  final DropzoneFile file;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -0.05,
    child: SizedBox.square(
      dimension: Spacing.d96,
      child: Paper(
        stock: StockName.photo,
        tilt: false,
        padding: const EdgeInsets.all(Spacing.d4),
        child: switch (file.preview) {
          final ImageProvider image => Image(
            image: image,
            fit: BoxFit.cover,
            semanticLabel: 'Preview of ${file.name}',
          ),
          null => Center(child: Text(file.name)),
        },
      ),
    ),
  );
}
