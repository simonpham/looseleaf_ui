import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// The intent an [InkActivation] key sends to its component.
///
/// Its own type, so an app-wide `Enter → ActivateIntent` shortcut does not
/// reach a [InkActivation.toggle] component.
class InkActivateIntent extends Intent {
  const InkActivateIntent();
}

/// Which keys activate a focused component.
enum InkActivation {
  /// Enter and Space, like a native `<button>`. Also answers Flutter's
  /// [ActivateIntent] and [ButtonActivateIntent].
  button,

  /// Space only, like Radix toggles (checkbox, switch): Enter is left to the
  /// surrounding form.
  toggle;

  /// The keys that send [InkActivateIntent].
  Map<ShortcutActivator, Intent> get shortcuts => switch (this) {
    InkActivation.button => const {
      SingleActivator(LogicalKeyboardKey.enter): InkActivateIntent(),
      SingleActivator(LogicalKeyboardKey.numpadEnter): InkActivateIntent(),
      SingleActivator(LogicalKeyboardKey.space): InkActivateIntent(),
    },
    InkActivation.toggle => const {
      SingleActivator(LogicalKeyboardKey.space): InkActivateIntent(),
    },
  };

  /// The actions that call [onActivate].
  Map<Type, Action<Intent>> actions(VoidCallback onActivate) {
    Object? invoke(Intent intent) {
      onActivate();
      return null;
    }

    return {
      InkActivateIntent: CallbackAction<InkActivateIntent>(onInvoke: invoke),
      if (this == InkActivation.button) ...{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: invoke),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
          onInvoke: invoke,
        ),
      },
    };
  }
}
