import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A settings section: its title and a line of help, beside the controls
/// on a wide page and above them on a narrow one.
class SettingsBillingSection extends StatelessWidget {
  const SettingsBillingSection({
    super.key,
    required this.title,
    required this.description,
    required this.children,
  });

  static const double _besideFrom = 672;
  static const double _headingWidth = 208;

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d4,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: theme.typography.face(
              KevinSansFace.script,
              cssSize: 25.6,
              cssLineHeight: 1,
              fontWeight: FontWeight.w700,
              color: theme.colors.ink,
            ),
          ),
        ),
        Text(
          description,
          style: theme.typography.interface(
            cssSize: 14,
            color: theme.colors.inkSoft,
          ),
        ),
      ],
    );
    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: children,
    );
    return Semantics(
      container: true,
      label: title,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _besideFrom) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d16,
              children: [heading, controls],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d40,
            children: [
              SizedBox(width: _headingWidth, child: heading),
              Expanded(child: controls),
            ],
          );
        },
      ),
    );
  }
}
