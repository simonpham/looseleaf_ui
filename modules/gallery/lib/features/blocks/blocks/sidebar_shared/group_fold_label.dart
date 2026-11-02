import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A group label in ink that folds its [Collapsible] open and shut, with
/// the highlighter under it on hover.
class GroupFoldLabel extends StatefulWidget {
  const GroupFoldLabel({super.key, required this.title});

  final String title;

  @override
  State<GroupFoldLabel> createState() => _GroupFoldLabelState();
}

class _GroupFoldLabelState extends State<GroupFoldLabel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: CollapsibleTrigger(
        child: SidebarSwipe(
          on: _hovered,
          child: SidebarGroupLabel(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(color: theme.colors.ink),
                  ),
                ),
                const CollapsibleIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
