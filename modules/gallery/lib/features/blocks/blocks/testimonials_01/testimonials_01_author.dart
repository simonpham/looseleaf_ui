import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Who said it: the name in bold ink, then their role.
class Testimonials01Author extends StatelessWidget {
  const Testimonials01Author(
    this.name,
    this.role, {
    super.key,
    this.cssSize = 15,
    this.cssLineHeight = 1.375,
  });

  /// The person.
  final String name;

  /// What they do, and where.
  final String role;

  /// The CSS font size of the line.
  final double cssSize;

  /// The CSS line height of the line.
  final double cssLineHeight;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.colors.ink,
            ),
          ),
          TextSpan(text: ', $role'),
        ],
      ),
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: cssSize,
        cssLineHeight: cssLineHeight,
        color: theme.colors.inkSoft,
      ),
    );
  }
}
