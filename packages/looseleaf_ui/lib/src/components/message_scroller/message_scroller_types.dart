import 'package:flutter/foundation.dart';

/// Where a [MessageScrollerController] opens: at the first message, the
/// newest, or the last scroll anchor (the start of the newest reply).
///
/// Mirrors `MessageScrollerDefaultScrollPosition` in upstream
/// `src/lib/message-scroller-primitive.tsx`.
enum MessageScrollerPosition { start, end, lastAnchor }

/// How a message is placed when scrolled to.
///
/// Mirrors `MessageScrollerScrollAlign` upstream.
enum MessageScrollerAlign { start, center, end, nearest }

/// Which end a [MessageScrollerButton] jumps to.
enum MessageScrollerDirection { start, end }

/// Whether there is more to scroll toward each end.
///
/// Mirrors `MessageScrollerScrollable` upstream.
@immutable
class MessageScrollerScrollable {
  const MessageScrollerScrollable({this.start = false, this.end = false});

  final bool start;
  final bool end;

  /// Whether there is more toward [direction].
  bool toward(MessageScrollerDirection direction) => switch (direction) {
    MessageScrollerDirection.start => start,
    MessageScrollerDirection.end => end,
  };

  @override
  bool operator ==(Object other) =>
      other is MessageScrollerScrollable &&
      other.start == start &&
      other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'MessageScrollerScrollable(start: $start, end: $end)';
}

/// Which messages are in view, and the scroll anchor being read.
///
/// Mirrors `MessageScrollerVisibilityState` upstream.
@immutable
class MessageScrollerVisibility {
  const MessageScrollerVisibility({
    this.currentAnchorId,
    this.visibleMessageIds = const [],
  });

  /// The anchor at or above the reading line.
  final String? currentAnchorId;

  /// The ids of the messages in view, in order.
  final List<String> visibleMessageIds;

  @override
  bool operator ==(Object other) =>
      other is MessageScrollerVisibility &&
      other.currentAnchorId == currentAnchorId &&
      listEquals(other.visibleMessageIds, visibleMessageIds);

  @override
  int get hashCode =>
      Object.hash(currentAnchorId, Object.hashAll(visibleMessageIds));
}
