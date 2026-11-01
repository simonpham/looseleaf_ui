import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/message_scroller/message_scroller_types.dart';

enum _Mode { followingBottom, freeScrolling, anchoredToMessage }

class _Entry {
  _Entry({required this.context, required this.id, required this.anchor});

  final BuildContext context;
  String? id;
  bool anchor;
}

typedef _Placed = ({Object owner, _Entry entry, double top, double height});

/// Runs a chat transcript's scrolling: it opens at [defaultPosition],
/// follows the newest message while [autoScroll] is on and you are at the
/// end, puts each new reply (a scroll anchor) at the top with a peek of
/// the message before it, keeps your place when older messages are
/// prepended, and lets go the moment you scroll toward the start.
///
/// [scrollable] says whether there is more toward each end (the fades and
/// the jump buttons read it); [visibility] says which messages are in view.
/// A [MessageScrollerProvider] creates one when it is not given one.
///
/// Mirrors the `Controller` of upstream
/// `src/lib/message-scroller-primitive.tsx`, measured with Flutter's
/// render boxes and driven by its [ScrollController].
class MessageScrollerController {
  MessageScrollerController({
    bool autoScroll = false,
    this.defaultPosition = MessageScrollerPosition.end,
    this.edgeThreshold = 8,
    this.previousItemPeek = 64,
    this.scrollMargin = 0,
    this.preserveScrollOnPrepend = true,
  }) : _autoScroll = autoScroll,
       _mode = switch (autoScroll) {
         true => _Mode.followingBottom,
         false => _Mode.freeScrolling,
       };

  static const double _eps = 0.5;
  static const Duration _smooth = Duration(milliseconds: 360);

  /// Where the transcript opens.
  MessageScrollerPosition defaultPosition;

  /// How close to an end counts as at it, in px.
  double edgeThreshold;

  /// How much of the previous message stays in view above a new reply.
  double previousItemPeek;

  /// Room kept above a message scrolled to.
  double scrollMargin;

  /// Keeps the message you read in place when older ones are prepended.
  bool preserveScrollOnPrepend;

  /// Whether jumps glide; reduced motion turns it off.
  bool reducedMotion = false;

  /// The content's padding after the last message.
  double contentEndPadding = 0;

  /// The viewport's focus, which the jump buttons hand the keyboard to.
  FocusNode? viewportFocusNode;

  /// Drives the viewport.
  final ScrollController scrollController = ScrollController();

  /// The room added after the last message so a reply can reach the top.
  final ValueNotifier<double> spacer = ValueNotifier(0);

  final ValueNotifier<MessageScrollerScrollable> _scrollable = ValueNotifier(
    const MessageScrollerScrollable(),
  );
  final ValueNotifier<MessageScrollerVisibility> _visibility = ValueNotifier(
    const MessageScrollerVisibility(),
  );

  /// Whether there is more toward each end; while following the newest
  /// message, the end reads as reached.
  ValueListenable<MessageScrollerScrollable> get scrollable => _scrollable;

  /// The messages in view and the anchor being read.
  ValueListenable<MessageScrollerVisibility> get visibility => _visibility;

  bool _autoScroll;
  _Mode _mode;
  BuildContext? _content;
  final Map<Object, _Entry> _entries = {};
  final Set<Object> _fresh = {};
  final Set<Object> _handled = {};
  int _itemCount = 0;
  Object? _firstItem;
  bool _appliedDefault = false;
  double _lastTop = 0;
  double _lastSet = double.nan;
  _Entry? _anchored;
  ({_Entry entry, double top})? _prepend;
  ({String id, MessageScrollerAlign align, double? margin, bool animate})?
  _pending;
  bool _changeScheduled = false;
  bool _disposed = false;

  /// Whether new messages are followed.
  bool get autoScroll => _autoScroll;
  set autoScroll(bool on) {
    _autoScroll = on;
    if (on) {
      if (_mode == _Mode.freeScrolling && !_compute().end) {
        _mode = _Mode.followingBottom;
      }
      return;
    }
    if (_mode == _Mode.followingBottom) _mode = _Mode.freeScrolling;
  }

  ScrollPosition? get _position => switch (scrollController.hasClients) {
    true => scrollController.position,
    false => null,
  };

  double get _viewport => _position?.viewportDimension ?? 0;
  double get _pixels => _position?.pixels ?? 0;

  RenderBox? _box(BuildContext? context) {
    if (context == null || !context.mounted) return null;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box;
  }

  List<_Placed> _placed() {
    final content = _box(_content);
    if (content == null) return const [];
    final placed = <_Placed>[];
    for (final MapEntry(key: owner, value: entry) in _entries.entries) {
      final box = _box(entry.context);
      if (box == null) continue;
      placed.add((
        owner: owner,
        entry: entry,
        top: box.localToGlobal(Offset.zero, ancestor: content).dy,
        height: box.size.height,
      ));
    }
    placed.sort((a, b) => a.top.compareTo(b.top));
    return placed;
  }

  _Placed? _place(_Entry entry) =>
      _placed().where((p) => identical(p.entry, entry)).firstOrNull;

  double _contentEnd([List<_Placed>? placed]) {
    final last = (placed ?? _placed()).lastOrNull;
    if (last == null) return 0;
    return last.top + last.height + contentEndPadding;
  }

  MessageScrollerScrollable _compute() {
    final position = _position;
    if (position == null) return const MessageScrollerScrollable();
    return MessageScrollerScrollable(
      start: position.pixels > edgeThreshold,
      end: _contentEnd() - position.pixels - _viewport > edgeThreshold,
    );
  }

  void _commit() {
    final shown = _compute();
    _scrollable.value = switch (_mode) {
      _Mode.followingBottom => MessageScrollerScrollable(start: shown.start),
      _ => shown,
    };
  }

  void _afterLayout(VoidCallback run) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) run();
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  bool _setSpacer(double height) {
    final next = math.max(0, height).ceilToDouble();
    if (next == spacer.value) return false;
    spacer.value = next;
    return true;
  }

  void _scrollTo(double top, {bool animate = false}) {
    final position = _position;
    if (position == null) return;
    final target = math.min(math.max(0.0, top), position.maxScrollExtent);
    if ((position.pixels - target).abs() <= _eps) {
      _commit();
      return;
    }
    _lastSet = target;
    if (animate && !reducedMotion) {
      unawaited(
        position.animateTo(target, duration: _smooth, curve: Curves.easeInOut),
      );
      return;
    }
    position.jumpTo(target);
  }

  void _scrollWhenLaidOut(bool spacerChanged, VoidCallback scroll) {
    if (spacerChanged) {
      _afterLayout(scroll);
      return;
    }
    scroll();
  }

  /// Scrolls to the newest message; following resumes when [autoScroll]
  /// is on. False before the viewport is laid out.
  bool scrollToEnd({bool animate = false}) {
    if (_position == null) return false;
    final changed = _setSpacer(0);
    _anchored = null;
    _mode = switch (_autoScroll) {
      true => _Mode.followingBottom,
      false => _Mode.freeScrolling,
    };
    _scrollWhenLaidOut(
      changed,
      () => _scrollTo(_contentEnd() - _viewport, animate: animate),
    );
    _scheduleVisibility();
    return true;
  }

  /// Scrolls to the first message and stops following.
  bool scrollToStart({bool animate = false}) {
    if (_position == null) return false;
    final changed = _setSpacer(0);
    _anchored = null;
    _mode = _Mode.freeScrolling;
    _scrollWhenLaidOut(changed, () => _scrollTo(0, animate: animate));
    _scheduleVisibility();
    return true;
  }

  /// Scrolls to the [MessageScrollerItem] with `messageId` [id]. Before
  /// any message is shown, the jump waits for it. False when no such
  /// message is shown.
  bool scrollToMessage(
    String id, {
    MessageScrollerAlign align = MessageScrollerAlign.start,
    double? scrollMargin,
    bool animate = false,
  }) {
    final entry = _entries.values.where((e) => e.id == id).firstOrNull;
    if (entry != null) {
      _appliedDefault = true;
      _pending = null;
      return _scrollToEntry(
        entry,
        align: align,
        margin: scrollMargin ?? this.scrollMargin,
        animate: animate,
      );
    }
    if (_itemCount == 0) {
      _pending = (
        id: id,
        align: align,
        margin: scrollMargin,
        animate: animate,
      );
      _appliedDefault = true;
      return true;
    }
    return false;
  }

  double _targetFor(_Placed item, MessageScrollerAlign align, double margin) {
    final viewport = _viewport;
    return switch (align) {
      MessageScrollerAlign.start => item.top - margin,
      MessageScrollerAlign.center =>
        item.top - (viewport - item.height) / 2 - margin,
      MessageScrollerAlign.end => item.top + item.height - viewport + margin,
      MessageScrollerAlign.nearest => _nearest(item, margin),
    };
  }

  double _nearest(_Placed item, double margin) {
    final from = _pixels;
    final to = from + _viewport;
    if (item.top >= from && item.top + item.height <= to) return from;
    if (item.top < from) return item.top - margin;
    return item.top + item.height - _viewport + margin;
  }

  bool _scrollToEntry(
    _Entry entry, {
    MessageScrollerAlign align = MessageScrollerAlign.start,
    double? margin,
    bool animate = false,
    bool keepPreviousPeek = false,
  }) {
    final placed = _placed();
    final item = placed.where((p) => identical(p.entry, entry)).firstOrNull;
    if (_position == null || item == null) return false;
    final peek = switch (keepPreviousPeek) {
      true => previousItemPeek,
      false => 0.0,
    };
    final target = math.max(
      0.0,
      _targetFor(item, align, (margin ?? scrollMargin) + peek),
    );
    final changed = _setSpacer(target + _viewport - _contentEnd(placed));
    _mode = switch (keepPreviousPeek) {
      true => _Mode.anchoredToMessage,
      false => _Mode.freeScrolling,
    };
    _anchored = switch (keepPreviousPeek) {
      true => entry,
      false => null,
    };
    _scrollWhenLaidOut(changed, () {
      _scrollTo(target, animate: animate);
      _snapshot();
    });
    _scheduleVisibility();
    return true;
  }

  void _flushPending() {
    final pending = _pending;
    if (pending == null) return;
    final entry = _entries.values.where((e) => e.id == pending.id).firstOrNull;
    if (entry == null) return;
    final done = _scrollToEntry(
      entry,
      align: pending.align,
      margin: pending.margin,
      animate: pending.animate,
    );
    if (done) _pending = null;
  }

  bool _applyDefault(List<_Placed> placed) {
    if (_appliedDefault || placed.isEmpty) return false;
    final done = switch (defaultPosition) {
      MessageScrollerPosition.start => scrollToStart(),
      MessageScrollerPosition.end => scrollToEnd(),
      MessageScrollerPosition.lastAnchor => _toLastAnchor(placed),
    };
    if (done) _appliedDefault = true;
    return done;
  }

  bool _toLastAnchor(List<_Placed> placed) {
    final last = placed.where((p) => p.entry.anchor).lastOrNull;
    if (last == null || _contentEnd(placed) - last.top <= _viewport) {
      return scrollToEnd();
    }
    return _scrollToEntry(last.entry, keepPreviousPeek: true);
  }

  void _snapshot() {
    final pixels = _pixels;
    final item = _placed().where((p) => p.top + p.height > pixels).firstOrNull;
    if (item == null || item.top - pixels >= _viewport) {
      _prepend = null;
      return;
    }
    _prepend = (entry: item.entry, top: item.top - pixels);
  }

  bool _restorePrepend() {
    final prepend = _prepend;
    final position = _position;
    if (prepend == null || position == null) return false;
    final item = _place(prepend.entry);
    if (item == null) return false;
    final delta = item.top - position.pixels - prepend.top;
    if (delta.abs() <= _eps) return false;
    position.jumpTo(position.pixels + delta);
    _lastSet = position.pixels;
    _snapshot();
    _commit();
    _scheduleVisibility();
    return true;
  }

  void _handleContentChange() {
    if (_box(_content) == null || _position == null) return;
    _flushPending();
    final placed = _placed();
    final before = _itemCount;
    final first = _firstItem;
    final fresh = {..._fresh};
    _fresh.clear();
    _itemCount = placed.length;
    _firstItem = placed.firstOrNull?.owner;
    if (before == 0) {
      if (!_applyDefault(placed)) _commit();
      _snapshot();
      _scheduleVisibility();
      return;
    }
    final at = placed.indexWhere((p) => p.owner == first);
    if (preserveScrollOnPrepend && at > 0) {
      _restorePrepend();
      _commit();
      return;
    }
    final anchors = [
      for (final p in placed)
        if (fresh.contains(p.owner) &&
            p.entry.anchor &&
            !_handled.contains(p.owner))
          p,
    ];
    if (anchors.isNotEmpty) {
      _handled.addAll([for (final p in anchors) p.owner]);
      final following = _mode == _Mode.followingBottom && _autoScroll;
      if (following && anchors.length > 1) {
        scrollToEnd();
        return;
      }
      _scrollToEntry(anchors.last.entry, keepPreviousPeek: true);
      return;
    }
    if (_mode == _Mode.followingBottom && _autoScroll) {
      scrollToEnd();
      return;
    }
    _commit();
    _snapshot();
    _scheduleVisibility();
  }

  /// Re-measures after the viewport or the messages change size.
  void handleResize() {
    if (_mode == _Mode.followingBottom && _autoScroll) {
      scrollToEnd();
      return;
    }
    final anchored = _anchored;
    final item = switch (anchored) {
      null => null,
      final entry => _place(entry),
    };
    if (item != null && _mode == _Mode.anchoredToMessage) {
      final target = math.max(
        0.0,
        _targetFor(
          item,
          MessageScrollerAlign.start,
          scrollMargin + previousItemPeek,
        ),
      );
      final had = spacer.value;
      final changed = _setSpacer(target + _viewport - _contentEnd());
      if (_autoScroll && had > 0 && spacer.value == 0) {
        scrollToEnd();
        return;
      }
      if (spacer.value > 0 && (_pixels - target).abs() > _eps) {
        _scrollWhenLaidOut(changed, () => _scrollTo(target));
      }
    }
    _commit();
    _scheduleVisibility();
  }

  /// Follows a scroll of the viewport.
  void handleScroll() {
    final position = _position;
    if (position == null) return;
    final s = _compute();
    final up = position.pixels < _lastTop - _eps;
    _lastTop = position.pixels;
    final ours = (position.pixels - _lastSet).abs() <= 1.5;
    if (_autoScroll && !s.end && _mode != _Mode.anchoredToMessage) {
      _mode = _Mode.followingBottom;
    } else if (_mode == _Mode.followingBottom && s.end && up && !ours) {
      _mode = _Mode.freeScrolling;
    }
    _snapshot();
    _commit();
    _scheduleVisibility();
  }

  /// The reader scrolls toward [toward] (null: either way): following and
  /// anchoring stop, except a push toward the end while following.
  void userIntent([MessageScrollerDirection? toward]) {
    if (_mode == _Mode.followingBottom) {
      if (toward != MessageScrollerDirection.end) {
        _mode = _Mode.freeScrolling;
      }
      return;
    }
    if (_mode == _Mode.anchoredToMessage) _mode = _Mode.freeScrolling;
  }

  void _scheduleVisibility() {
    _afterLayout(() => _visibility.value = _computeVisibility());
  }

  MessageScrollerVisibility _computeVisibility() {
    if (_position == null) return const MessageScrollerVisibility();
    final pixels = _pixels;
    final viewport = _viewport;
    final line = scrollMargin + previousItemPeek;
    final placed = _placed();
    final visible = <String>[];
    String? current;
    var first = placed.length;
    for (final (i, p) in placed.indexed) {
      final top = p.top - pixels;
      if (top + p.height <= line) continue;
      if (first == placed.length) first = i;
      if (top >= viewport) break;
      final id = p.entry.id;
      if (id == null) continue;
      visible.add(id);
      if (p.entry.anchor && top <= line + _eps) current = id;
    }
    for (var i = first - 1; i >= 0 && current == null; i--) {
      final entry = placed[i].entry;
      if (entry.anchor && entry.id != null) current = entry.id;
    }
    return MessageScrollerVisibility(
      currentAnchorId: current,
      visibleMessageIds: visible,
    );
  }

  void _scheduleContentChange() {
    if (_changeScheduled) return;
    _changeScheduled = true;
    _afterLayout(() {
      _changeScheduled = false;
      _handleContentChange();
    });
  }

  /// Connects the content; for [MessageScrollerContent].
  void attachContent(BuildContext context) {
    _content = context;
    _scheduleContentChange();
  }

  /// Disconnects the content.
  void detachContent(BuildContext context) {
    if (_content == context) _content = null;
  }

  /// Registers a message; for [MessageScrollerItem].
  void attachItem(
    Object owner,
    BuildContext context, {
    String? id,
    bool anchor = false,
  }) {
    _entries[owner] = _Entry(context: context, id: id, anchor: anchor);
    _fresh.add(owner);
    _scheduleContentChange();
  }

  /// Updates a registered message's id and anchor.
  void updateItem(Object owner, {String? id, bool anchor = false}) {
    final entry = _entries[owner];
    if (entry == null) return;
    entry
      ..id = id
      ..anchor = anchor;
    _scheduleVisibility();
  }

  /// Unregisters a message.
  void detachItem(Object owner) {
    final entry = _entries.remove(owner);
    _fresh.remove(owner);
    _handled.remove(owner);
    if (identical(entry, _anchored)) _anchored = null;
    _scheduleContentChange();
  }

  void dispose() {
    _disposed = true;
    scrollController.dispose();
    spacer.dispose();
    _scrollable.dispose();
    _visibility.dispose();
  }
}
