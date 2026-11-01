import 'dart:async';

import 'package:flutter/services.dart' as services;
import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/copy_button.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A slip of code: a file name header with a copy button over monospace
/// lines that scroll sideways. Mirrors `DocCodeBlock` in `src/docs/kit/DocCodeBlock.tsx`.
class DocCodeBlock extends StatelessWidget {
  const DocCodeBlock({super.key, required this.code, this.title = 'dart'});

  final String code;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final trimmed = code.trimRight();
    return Paper(
      stock: StockName.slip,
      tilt: false,
      shadow: PaperShadow.slip,
      seed: 'code:$title',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: Spacing.d16,
              end: Spacing.d8,
              top: Spacing.d6,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.stamp(
                      cssSize: 13,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
                CopyButton(
                  onCopy: () => unawaited(
                    services.Clipboard.setData(
                      services.ClipboardData(text: trimmed),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Separator(variant: SeparatorVariant.dashed),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(Spacing.d16),
            child: Text(
              trimmed,
              style: theme.typography.mono(
                cssSize: 13.5,
                cssLineHeight: 1.6,
                color: theme.colors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
