import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The profile photo: a big avatar (initials without a photo), a button to
/// pick one through [onPick] and one to remove it.
class SettingsProfilePhoto extends StatefulWidget {
  const SettingsProfilePhoto({
    super.key,
    required this.name,
    required this.onPhoto,
    this.photo,
    this.onPick,
  });

  static const double _side = 80;

  final String name;
  final ImageProvider? photo;
  final ValueChanged<ImageProvider?> onPhoto;

  /// Asks for a picture; a throw shows its message. Without it, the upload
  /// button does nothing.
  final Future<ImageProvider?> Function()? onPick;

  @override
  State<SettingsProfilePhoto> createState() => _SettingsProfilePhotoState();
}

class _SettingsProfilePhotoState extends State<SettingsProfilePhoto> {
  var _error = '';

  Future<void> _pick() async {
    final pick = widget.onPick;
    if (pick == null) return;
    try {
      final picked = await pick();
      if (picked == null || !mounted) return;
      setState(() => _error = '');
      widget.onPhoto(picked);
    } on Object catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final photo = widget.photo;
    return Row(
      spacing: Spacing.d20,
      children: [
        Avatar(
          size: AvatarSize.xl,
          dimension: SettingsProfilePhoto._side,
          seed: 'profile-photo',
          children: [
            if (photo != null) AvatarImage(image: photo),
            AvatarFallback(
              name: switch (widget.name) {
                '' => 'You',
                final name => name,
              },
            ),
          ],
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d8,
            children: [
              Text(
                'Photo',
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 15,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
              Wrap(
                spacing: Spacing.d8,
                runSpacing: Spacing.d8,
                children: [
                  Button(
                    variant: ButtonVariant.outline,
                    size: ButtonSize.sm,
                    onPressed: () => unawaited(_pick()),
                    child: Text(switch (photo) {
                      null => 'Upload a photo',
                      _ => 'Choose another',
                    }),
                  ),
                  if (photo != null)
                    Button(
                      variant: ButtonVariant.ghost,
                      size: ButtonSize.sm,
                      onPressed: () {
                        setState(() => _error = '');
                        widget.onPhoto(null);
                      },
                      child: const Text('Remove'),
                    ),
                ],
              ),
              Text(
                'JPG, PNG or GIF, up to 2 MB. Without one you get your initials.',
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.inkSoft,
                ),
              ),
              if (_error.isNotEmpty)
                Text(
                  _error,
                  style: theme.typography
                      .interface(cssSize: 14, color: theme.colors.red)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
