import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SonnerDemoExample extends StatefulWidget {
  const SonnerDemoExample({super.key});

  @override
  State<SonnerDemoExample> createState() => _SonnerDemoExampleState();
}

class _SonnerDemoExampleState extends State<SonnerDemoExample> {
  final _toasts = ToastController();
  late final _toast = Sonner(_toasts);
  final _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _portal.show();
  }

  @override
  void dispose() {
    _toasts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _portal,
    overlayLocation: OverlayChildLocation.rootOverlay,
    overlayChildBuilder: (context) => Toaster(
      controller: _toasts,
      child: const SizedBox.expand(),
    ),
    child: Button(
      variant: ButtonVariant.outline,
      onPressed: () => _toast(
        'Event has been created',
        description: 'Sunday, December 03, 2023 at 9:00 AM',
        action: ToastButton(
          label: 'Undo',
          onPressed: () => _toast('Event removed'),
        ),
      ),
      child: const Text('Show Toast'),
    ),
  );
}
