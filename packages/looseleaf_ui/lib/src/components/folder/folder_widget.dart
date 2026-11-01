import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/folder/folder.dart';
import 'package:looseleaf_ui/src/components/tabs/tabs.dart';

/// A manila file folder that is also a set of tabs: a row of paper
/// [FolderTabs] standing on a sheet of the same [stock]. The open tab is the
/// folder's own paper and runs down into the body ([FolderContent]); the
/// others stand a little lower and darker. As wide as it may, up to
/// [maxWidth].
///
/// Controlled with [value] and [onValueChange], or left to itself from
/// [defaultValue]. The tabs are always horizontal.
///
/// ```dart
/// Folder(
///   defaultValue: 'inbox',
///   children: [
///     FolderTabs(semanticLabel: 'Mail', children: [
///       FolderTab(value: 'inbox', child: Text('Inbox')),
///       FolderTab(value: 'drafts', child: Text('Drafts')),
///     ]),
///     FolderContent(value: 'inbox', child: Text('Three letters.')),
///     FolderContent(value: 'drafts', child: Text('Two drafts.')),
///   ],
/// )
/// ```
///
/// Mirrors `Folder` in upstream `src/components/ui/folder.tsx`.
class Folder extends StatefulWidget {
  const Folder({
    super.key,
    required this.children,
    this.value,
    this.defaultValue,
    this.onValueChange,
    this.activationMode = TabsActivationMode.automatic,
    this.stock = StockName.kraft,
    this.maxWidth = defaultMaxWidth,
  });

  /// Upstream's `max-w-2xl`.
  static const double defaultMaxWidth = 672;

  /// The [FolderTabs], then the [FolderContent]s.
  final List<Widget> children;

  /// The open tab; null leaves it to the folder.
  final String? value;

  /// The tab an uncontrolled folder opens with.
  final String? defaultValue;

  /// Called with the tab being opened.
  final ValueChanged<String>? onValueChange;

  /// Whether arrowing onto a tab opens it.
  final TabsActivationMode activationMode;

  /// What tabs and body are made of: kraft (manila), a sticky yellow,
  /// paper, index card…
  final StockName stock;

  /// The largest width.
  final double maxWidth;

  @override
  State<Folder> createState() => _FolderState();
}

class _FolderState extends State<Folder> {
  late String? _value = widget.defaultValue;

  void _select(String value) {
    if ((widget.value ?? _value) == value) return;
    setState(() => _value = value);
    widget.onValueChange?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    // Built upwards so the tabs paint over the body they run into.
    return FolderScope(
      value: widget.value ?? _value,
      stock: widget.stock,
      activationMode: widget.activationMode,
      select: _select,
      child: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: math.min(widget.maxWidth, constraints.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            verticalDirection: VerticalDirection.up,
            children: widget.children.reversed.toList(),
          ),
        ),
      ),
    );
  }
}
