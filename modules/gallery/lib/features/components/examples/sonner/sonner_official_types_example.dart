import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SonnerOfficialTypesExample extends StatefulWidget {
  const SonnerOfficialTypesExample({super.key});

  @override
  State<SonnerOfficialTypesExample> createState() =>
      _SonnerOfficialTypesExampleState();
}

class _SonnerOfficialTypesExampleState
    extends State<SonnerOfficialTypesExample> {
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
    child: Wrap(
      spacing: Spacing.d8,
      runSpacing: Spacing.d8,
      children: [
        Button(
          variant: ButtonVariant.outline,
          onPressed: () => _toast('Event has been created'),
          child: const Text('Default'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () => _toast.success('Event has been created'),
          child: const Text('Success'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () =>
              _toast.info('Be at the area 10 minutes before the event time'),
          child: const Text('Info'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () =>
              _toast.warning('Event start time cannot be earlier than 8am'),
          child: const Text('Warning'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () => _toast.error('Event has not been created'),
          child: const Text('Error'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () => _toast.promise(
            Future.delayed(const Duration(seconds: 2), () => 'Event'),
            loading: 'Loading...',
            success: (name) => '$name has been created',
            error: (_) => 'Error',
          ),
          child: const Text('Promise'),
        ),
      ],
    ),
  );
}
