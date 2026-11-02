import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A slip with three buttons that toss a success, an error and an undoable
/// toast. The toasts go to a toaster of their own, laid over the whole
/// window.
///
/// Mirrors upstream `src/docs/content/home/toast-card.tsx`.
class ToastSlipCard extends StatefulWidget {
  const ToastSlipCard({super.key});

  /// Upstream's `max-w-sm`.
  static const double maxWidth = 384;

  @override
  State<ToastSlipCard> createState() => _ToastSlipCardState();
}

class _ToastSlipCardState extends State<ToastSlipCard> {
  final ToastController _toasts = ToastController();
  late final Sonner _toast = Sonner(_toasts);
  final OverlayPortalController _portal = OverlayPortalController();

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
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return RootOverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) => Toaster(
        controller: _toasts,
        closeButton: true,
        child: const SizedBox.expand(),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: ToastSlipCard.maxWidth),
        child: Paper(
          stock: StockName.slip,
          tape: PaperTape.top,
          seed: 'home-toast',
          padding: const EdgeInsets.fromLTRB(
            Spacing.d20,
            Spacing.d28,
            Spacing.d20,
            Spacing.d20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toss a toast',
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 30,
                  cssLineHeight: 1,
                  fontWeight: FontWeight.w700,
                  color: theme.colors.ink,
                ),
              ),
              const SizedBox(height: Spacing.d4),
              Text(
                'Each kind is its own paper, so the meaning is not only a color.',
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.inkMuted,
                ),
              ),
              const SizedBox(height: Spacing.d16),
              Wrap(
                spacing: Spacing.d8,
                runSpacing: Spacing.d8,
                children: [
                  Button(
                    size: ButtonSize.sm,
                    seed: 'home-toast-saved',
                    onPressed: () => _toast.success(
                      'Notebook saved',
                      description: 'All 48 pages are safe.',
                    ),
                    child: const Text('Saved'),
                  ),
                  Button(
                    size: ButtonSize.sm,
                    variant: ButtonVariant.outline,
                    seed: 'home-toast-oops',
                    onPressed: () => _toast.error(
                      'Could not sync',
                      description: 'You are offline. We will try again.',
                    ),
                    child: const Text('Oops'),
                  ),
                  Button(
                    size: ButtonSize.sm,
                    variant: ButtonVariant.outline,
                    seed: 'home-toast-delete',
                    onPressed: () => _toast(
                      'Page deleted',
                      action: ToastButton(
                        label: 'Undo',
                        onPressed: () => _toast.info('The page is back'),
                      ),
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
