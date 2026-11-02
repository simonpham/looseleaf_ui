import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_notifications/settings_notifications.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "What goes where": a row per kind of news, a checkbox per channel.
/// Rows the mode does not send are faded and locked.
class SettingsNotificationsTable extends StatelessWidget {
  const SettingsNotificationsTable({
    super.key,
    required this.prefs,
    required this.onChanged,
    this.invalid = false,
  });

  static const double _wideFrom = 576;
  static const double _narrowColumn = 72;
  static const double _wideColumn = 96;
  static const double _faded = 0.6;

  final NotifyPrefs prefs;
  final ValueChanged<NotifyPrefs> onChanged;

  /// Draws the live boxes in red pencil.
  final bool invalid;

  String _note(NotifyEvent event) {
    if (event.enabledIn(prefs.mode)) return event.help;
    if (prefs.muted) return 'Muted above.';
    return 'Only about you, so not sent in “Just me”.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final column = switch (constraints.maxWidth >= _wideFrom) {
          true => _wideColumn,
          false => _narrowColumn,
        };
        return Semantics(
          container: true,
          label: 'What goes where',
          child: InkTable(
            columnWidths: {
              for (var i = 1; i <= NotifyChannel.values.length; i++)
                i: FixedColumnWidth(column),
            },
            header: TableHeader(
              rows: [
                InkTableRow(
                  cells: [
                    const TableHead(child: Text('News')),
                    for (final channel in NotifyChannel.values)
                      TableHead(
                        child: Text(
                          channel.label,
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            body: TableBody(
              rows: [
                for (final event in NotifyEvent.values)
                  _row(event, event.enabledIn(prefs.mode), theme),
              ],
            ),
          ),
        );
      },
    );
  }

  InkTableRow _row(NotifyEvent event, bool live, LooseleafThemeData theme) {
    final opacity = switch (live) {
      true => 1.0,
      false => _faded,
    };
    return InkTableRow(
      cells: [
        InkTableCell(
          wrap: true,
          child: Opacity(
            opacity: opacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  _note(event),
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
        for (final channel in NotifyChannel.values)
          InkTableCell(
            child: Opacity(
              opacity: opacity,
              child: Center(
                child: Checkbox(
                  value: prefs.sends(event, channel),
                  disabled: !live,
                  invalid: invalid && live,
                  semanticLabel:
                      '${event.label} by ${channel.label.toLowerCase()}',
                  onChanged: (send) =>
                      onChanged(prefs.toggle(event, channel, send)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
