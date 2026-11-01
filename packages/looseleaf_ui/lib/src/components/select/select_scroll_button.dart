import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A chevron at one end of a scrolling [SelectContent] that scrolls the
/// list a row at a time while the pointer rests on it. Shared by
/// [SelectScrollUpButton] and [SelectScrollDownButton].
class SelectScrollButton extends StatefulWidget {
  const SelectScrollButton({super.key, required this.up});

  /// Scrolls towards the start when true, the end when false.
  final bool up;

  @override
  State<SelectScrollButton> createState() => _SelectScrollButtonState();
}

class _SelectScrollButtonState extends State<SelectScrollButton> {
  static const Duration _tick = Duration(milliseconds: 50);

  Timer? _timer;

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(_tick, (_) => _scroll());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _scroll() {
    if (!mounted) return _stop();
    final scroll = Select.of(context).scroll;
    if (!scroll.hasClients) return;
    final position = scroll.position;
    final step = SelectMetrics.itemHeight.of(context);
    final target = switch (widget.up) {
      true => math.max(0.0, position.pixels - step),
      false => math.min(position.maxScrollExtent, position.pixels + step),
    };
    scroll.jumpTo(target);
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ExcludeSemantics(
      child: MouseRegion(
        onEnter: (_) => _start(),
        onExit: (_) => _stop(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _scroll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: SelectMetrics.scrollButtonPadding,
            ),
            child: Center(
              child: InkIcon(
                switch (widget.up) {
                  true => 'chevron-up',
                  false => 'chevron-down',
                },
                size: SelectMetrics.chevron,
                color: theme.colors.inkSoft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
