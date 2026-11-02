import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SonnerTypesExample extends StatefulWidget {
  const SonnerTypesExample({super.key});

  @override
  State<SonnerTypesExample> createState() => _SonnerTypesExampleState();
}

class _SonnerTypesExampleState extends State<SonnerTypesExample> {
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
      closeButton: true,
      child: const SizedBox.expand(),
    ),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: Spacing.d8,
      runSpacing: Spacing.d8,
      children: [
        Button(
          variant: ButtonVariant.outline,
          onPressed: () =>
              _toast('Event created', description: 'Saturday, 10:00 am'),
          child: const Text('Default'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () => _toast.success(
            'Notebook saved',
            description: 'All 48 pages are safe.',
          ),
          child: const Text('Success'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () => _toast.error(
            'Could not sync',
            description: 'You are offline. We will try again.',
          ),
          child: const Text('Error'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () => _toast.warning(
            'Storage almost full',
            description: '92% of your 1 GB is used.',
          ),
          child: const Text('Warning'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () => _toast.info('A new version is ready'),
          child: const Text('Info'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () =>
              _toast.loading('Uploading photo…', description: 'IMG_2043.jpg'),
          child: const Text('Loading'),
        ),
      ],
    ),
  );
}
