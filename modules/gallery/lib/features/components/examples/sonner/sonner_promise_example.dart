import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SonnerPromiseExample extends StatefulWidget {
  const SonnerPromiseExample({super.key});

  @override
  State<SonnerPromiseExample> createState() => _SonnerPromiseExampleState();
}

class _SonnerPromiseExampleState extends State<SonnerPromiseExample> {
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

  Future<String> _save({required bool ok}) =>
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!ok) throw StateError('offline');
        return 'Field notes';
      });

  @override
  Widget build(BuildContext context) => RootOverlayPortal(
    controller: _portal,
    overlayChildBuilder: (context) => Toaster(
      controller: _toasts,
      child: const SizedBox.expand(),
    ),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: Spacing.d8,
      runSpacing: Spacing.d8,
      children: [
        Button(
          onPressed: () => _toast.promise(
            _save(ok: true),
            loading: 'Saving notebook…',
            success: (name) => '$name saved',
            error: (_) => 'Could not save',
          ),
          child: const Text('Save (succeeds)'),
        ),
        Button(
          variant: ButtonVariant.outline,
          onPressed: () => _toast.promise(
            _save(ok: false),
            loading: 'Saving notebook…',
            success: (_) => 'Saved',
            error: (error) => switch (error) {
              StateError(:final message) => 'Could not save: $message',
              _ => 'Could not save',
            },
          ),
          child: const Text('Save (fails)'),
        ),
      ],
    ),
  );
}
