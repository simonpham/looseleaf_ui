import 'package:flutter/widgets.dart';
import 'package:gallery/features/settings/view_models/view_models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';
import 'package:provider/provider.dart';

/// Puts the settings' [LooseleafTheme], text direction and default text
/// style above [child].
class ThemeFrame extends StatelessWidget {
  const ThemeFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.select<SettingsViewModel, LooseleafThemeData>(
      (model) => model.theme,
    );
    return LooseleafTheme(
      data: theme,
      child: Directionality(
        textDirection: theme.textDirection,
        child: DefaultTextStyle(
          style: theme.typography.interface(color: theme.colors.ink),
          child: child,
        ),
      ),
    );
  }
}
