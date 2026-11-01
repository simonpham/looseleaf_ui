import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/tabs/tabs_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Panels behind index-divider tabs: a [TabsList] of [TabsTrigger]s and a
/// [TabsContent] per tab, 12 apart, stacked (or side by side when
/// [orientation] is vertical).
///
/// Controlled with [value] and [onValueChange], or left to itself from
/// [defaultValue].
///
/// ```dart
/// Tabs(defaultValue: 'account', children: [
///   TabsList(children: [
///     TabsTrigger(value: 'account', child: Text('Account')),
///     TabsTrigger(value: 'password', child: Text('Password')),
///   ]),
///   TabsContent(value: 'account', child: AccountForm()),
///   TabsContent(value: 'password', child: PasswordForm()),
/// ])
/// ```
///
/// Mirrors `Tabs` in upstream `src/components/ui/tabs.tsx`.
class Tabs extends StatefulWidget {
  const Tabs({
    super.key,
    required this.children,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.orientation = TabsOrientation.horizontal,
    this.activationMode = TabsActivationMode.automatic,
  });

  final List<Widget> children;

  /// The open tab; null leaves it to the tabs.
  final String? value;

  /// The tab an uncontrolled [Tabs] opens with.
  final String? defaultValue;

  /// Called with the tab being opened.
  final ValueChanged<String>? onValueChange;

  final TabsOrientation orientation;
  final TabsActivationMode activationMode;

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  late String? _value = widget.defaultValue;

  void _select(String value) {
    if ((widget.value ?? _value) == value) return;
    setState(() => _value = value);
    widget.onValueChange?.call(value);
  }

  @override
  Widget build(BuildContext context) => TabsScope(
    value: widget.value ?? _value,
    orientation: widget.orientation,
    activationMode: widget.activationMode,
    select: _select,
    child: Flex(
      direction: switch (widget.orientation) {
        TabsOrientation.horizontal => Axis.vertical,
        TabsOrientation.vertical => Axis.horizontal,
      },
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: widget.children,
    ),
  );
}
