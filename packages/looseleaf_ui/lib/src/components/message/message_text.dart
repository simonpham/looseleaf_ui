import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/message/message_caret.dart';
import 'package:looseleaf_ui/src/components/message/message_word.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A message's words, written by hand: each word sits a fraction of a
/// pixel off the line and a touch lighter or darker ([jitter]), seeded so
/// it stays put. While [streaming], the words that arrive after the first
/// build soak in (dark and blurred, then dry) and a felt-tip caret rides
/// after the last word.
///
/// Text in a right-to-left script is not split: it shows as one run, with
/// the caret, and no per-word wobble or soak. Screen readers read [text]
/// as ordinary text.
///
/// ```dart
/// MessageText(reply, streaming: !done, seed: 'reply-1')
/// ```
///
/// Mirrors `MessageText` in upstream `src/components/ui/message.tsx`.
class MessageText extends StatefulWidget {
  const MessageText(
    this.text, {
    super.key,
    this.streaming = false,
    this.jitter = true,
    this.seed,
  });

  final String text;

  /// Soaks new words in and shows the caret.
  final bool streaming;

  /// Sets each word slightly off the line and in a slightly different ink.
  final bool jitter;

  /// Pins the jitter; a per-State id when null.
  final String? seed;

  static final RegExp _words = RegExp(r'(\s+)');
  static final RegExp _rtlScript = RegExp(
    '[֐-ࣿיִ-﷿ﹰ-﻿]',
  );

  /// [text] split like upstream's `text.split(/(\s+)/)`: words at even
  /// indexes, the whitespace between them at odd ones.
  static List<String> split(String text) {
    final parts = <String>[];
    var start = 0;
    for (final match in _words.allMatches(text)) {
      parts
        ..add(text.substring(start, match.start))
        ..add(match[0] ?? '');
      start = match.end;
    }
    parts.add(text.substring(start));
    return parts;
  }

  /// Whether [text] holds a right-to-left script.
  static bool isBidi(String text) => _rtlScript.hasMatch(text);

  /// Word [index]'s jitter: a vertical nudge in px and an ink strength.
  ///
  /// Mirrors `jitterOf` in upstream `src/components/ui/message.tsx`.
  static ({double dy, double ink}) jitterOf(String seed, int index) {
    final rng = Rng('$seed:$index');
    final dy = (rng() * 2 - 1) * 0.6;
    final ink = 0.88 + rng() * 0.12;
    return (
      dy: double.parse(JsMath.toFixed(dy, 2)),
      ink: double.parse(JsMath.toFixed(ink, 2)),
    );
  }

  @override
  State<MessageText> createState() => _MessageTextState();
}

class _MessageTextState extends State<MessageText> with InkSeed {
  int? _settled;

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final style = DefaultTextStyle.of(context).style;
    final theme = LooseleafTheme.of(context);
    if (MessageText.isBidi(text)) {
      return Semantics(
        label: text,
        child: ExcludeSemantics(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: text),
                if (widget.streaming) _caret(style),
              ],
            ),
          ),
        ),
      );
    }
    final parts = MessageText.split(text);
    var last = parts.length - 1;
    while (last > 0 && (parts[last].isEmpty || last.isOdd)) {
      last--;
    }
    _settled ??= _trimmedLength(parts);
    final settled = _settled ?? 0;
    final jitterK = switch (theme.density) {
      LooseleafDensity.calm => 0.0,
      _ => 1.0,
    };
    final seed = inkSeed(widget.seed);
    final spans = <InlineSpan>[];
    var word = 0;
    for (final (i, part) in parts.indexed) {
      if (part.isEmpty) continue;
      if (i.isOdd) {
        spans.add(TextSpan(text: part));
        continue;
      }
      final n = word++;
      final jitter = switch (widget.jitter) {
        true => MessageText.jitterOf(seed, n),
        false => (dy: 0.0, ink: 1.0),
      };
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: MessageWord(
            key: ValueKey(i),
            word: part,
            dy: jitter.dy * jitterK,
            ink: 1 - (1 - jitter.ink) * jitterK,
            soak: widget.streaming && i >= settled,
          ),
        ),
      );
      if (widget.streaming && i == last) spans.add(_caret(style));
    }
    return Semantics(
      label: text,
      child: ExcludeSemantics(child: Text.rich(TextSpan(children: spans))),
    );
  }

  static int _trimmedLength(List<String> parts) {
    var end = parts.length;
    while (end > 0 && parts[end - 1].isEmpty) {
      end--;
    }
    return end;
  }

  WidgetSpan _caret(TextStyle style) => WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: MessageCaret(fontSize: style.fontSize ?? Spacing.d16),
  );
}
