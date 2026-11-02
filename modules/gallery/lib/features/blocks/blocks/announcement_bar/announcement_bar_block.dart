import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/announcement_bar/announcement_bar.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A dismissible announcement on a taped kraft strip above the site
/// header. Dismissed, it leaves a link to bring it back; focus follows
/// whichever one is showing.
///
/// Mirrors upstream `src/blocks/announcement-bar/page.tsx`.
class AnnouncementBarBlock extends StatefulWidget {
  const AnnouncementBarBlock({super.key});

  @override
  State<AnnouncementBarBlock> createState() => _AnnouncementBarBlockState();
}

class _AnnouncementBarBlockState extends State<AnnouncementBarBlock> {
  final _strip = FocusNode(debugLabel: 'announcement');
  final _bringBack = FocusNode(debugLabel: 'bring back');
  bool _open = true;

  void _toggle(bool open) {
    setState(() => _open = open);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (open) {
        case true:
          _strip.requestFocus();
        case false:
          _bringBack.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _strip.dispose();
    _bringBack.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      switch (_open) {
        true => AnnouncementBarStrip(
          focusNode: _strip,
          message:
              'Penmark 2.0 is here: tape you can peel, and pages that turn.',
          onDismiss: () => _toggle(false),
        ),
        false => Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.d12,
            Spacing.d12,
            Spacing.d12,
            0,
          ),
          child: Center(
            child: Button(
              focusNode: _bringBack,
              variant: ButtonVariant.link,
              size: ButtonSize.sm,
              onPressed: () => _toggle(true),
              child: const Text('Bring the announcement back'),
            ),
          ),
        ),
      },
      const AnnouncementBarHeader(),
    ],
  );
}
