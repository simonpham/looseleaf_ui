import 'package:looseleaf_ink/looseleaf_ink.dart';

/// One rubber stamp impression on a [StampSurface]: what was stamped, where
/// (as fractions of the surface), and the strike that left it.
///
/// [id] is the slot: striking the same id again replaces the impression
/// with a fresh [press]. Impressions are plain data, so a list of them can
/// be saved ([toJson]) and restored ([StampImpression.fromJson]); restored
/// impressions are simply on the page, without the thump.
///
/// Mirrors `StampImpression` in upstream `src/components/ui/stamp-button.tsx`.
class StampImpression {
  const StampImpression({
    required this.id,
    required this.x,
    required this.y,
    this.press = 0,
    this.turn = 0,
    this.seed = '',
    this.name,
    this.text,
    this.shape,
    this.ink,
    this.sub,
    this.ring,
    this.w,
    this.h,
    this.size,
    this.ghost,
    this.dashed,
  });

  /// Reads an impression written by [toJson].
  factory StampImpression.fromJson(Map<String, Object?> json) =>
      StampImpression(
        id: json['id'] as String? ?? 'stamp',
        press: (json['press'] as num?)?.toInt() ?? 0,
        x: (json['x'] as num?)?.toDouble() ?? 0.5,
        y: (json['y'] as num?)?.toDouble() ?? 0.5,
        turn: (json['turn'] as num?)?.toDouble() ?? 0,
        seed: json['seed'] as String? ?? '',
        name: json['name'] as String?,
        text: json['text'] as String?,
        shape: StampShape.values
            .where((shape) => shape.id == json['shape'])
            .firstOrNull,
        ink: switch (json['ink']) {
          'red' => StampPadInk.red,
          'ink-you' => StampPadInk.inkYou,
          'green' => StampPadInk.green,
          'ink' => StampPadInk.ink,
          _ => null,
        },
        sub: json['sub'] as String?,
        ring: json['ring'] as String?,
        w: (json['w'] as num?)?.toDouble(),
        h: (json['h'] as num?)?.toDouble(),
        size: (json['size'] as num?)?.toDouble(),
        ghost: json['ghost'] as bool?,
        dashed: json['dashed'] as bool?,
      );

  /// The slot; a new strike with the same id replaces this one.
  final String id;

  /// How many times this slot has been struck.
  final int press;

  /// The center, as a fraction of the surface's width.
  final double x;

  /// The center, as a fraction of the surface's height.
  final double y;

  /// The hand's turn, in degrees.
  final double turn;

  /// The impression's drawing seed.
  final String seed;

  /// A stamp preset's name; see `Stamp.name`.
  final String? name;
  final String? text;
  final StampShape? shape;
  final StampPadInk? ink;
  final String? sub;
  final String? ring;
  final double? w;
  final double? h;
  final double? size;
  final bool? ghost;
  final bool? dashed;

  /// Identifies this strike: the slot and its press.
  String get key => '$id#$press';

  /// The upstream object, ready for `jsonEncode`.
  Map<String, Object?> toJson() => {
    'id': id,
    'press': press,
    'x': x,
    'y': y,
    'turn': turn,
    'seed': seed,
    'name': ?name,
    'text': ?text,
    'shape': ?shape?.id,
    'ink': ?switch (ink) {
      StampPadInk.red => 'red',
      StampPadInk.inkYou => 'ink-you',
      StampPadInk.green => 'green',
      StampPadInk.ink => 'ink',
      null => null,
    },
    'sub': ?sub,
    'ring': ?ring,
    'w': ?w,
    'h': ?h,
    'size': ?size,
    'ghost': ?ghost,
    'dashed': ?dashed,
  };

  /// This impression struck again: [press], position, ghost, turn and seed
  /// replaced.
  StampImpression struck({
    required int press,
    required double x,
    required double y,
    required bool? ghost,
    required double turn,
    required String seed,
  }) => StampImpression(
    id: id,
    press: press,
    x: x,
    y: y,
    turn: turn,
    seed: seed,
    name: name,
    text: text,
    shape: shape,
    ink: ink,
    sub: sub,
    ring: ring,
    w: w,
    h: h,
    size: size,
    ghost: ghost,
    dashed: dashed,
  );
}
