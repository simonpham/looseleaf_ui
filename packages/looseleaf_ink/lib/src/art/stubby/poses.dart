import 'package:looseleaf_ink/src/art/model/model.dart';
import 'package:looseleaf_ink/src/art/stubby/accessories.dart';
import 'package:looseleaf_ink/src/art/stubby/body.dart';
import 'package:looseleaf_ink/src/art/stubby/face.dart';
import 'package:looseleaf_ink/src/art/stubby/pose.dart';
import 'package:looseleaf_ink/src/art/stubby/xf.dart';
import 'package:looseleaf_ink/src/core/core.dart';

Pt _tipAt(double rot, double dx) {
  final a = (rot * JsMath.pi) / 180;
  return (
    32.4 + 63.2 * bodyK * JsMath.sin(a) + dx,
    67.4 - 63.2 * bodyK * JsMath.cos(a),
  );
}

/// Stubby writing, animation [frame] 0 to 2.
///
/// Mirrors `writeDef` in `src/lib/ink/art/mascots/props.ts`.
ArtDef writeDef(int frame) {
  final rot = const [11.0, 13.0, 15.0][frame];
  final dx = const [-9.4, -8.6, -7.8][frame];
  final t = _tipAt(rot, dx);
  return pose(
    PoseSpec(
      face: const Face(eyes: EyeKind.squint, mouth: MouthKind.tongue),
      turn: Xf(rot: rot, dx: dx),
      acc: scribble(t.x + 1.8, t.y + 2.4, const [0.42, 0.72, 1.0][frame]),
      tags: const ['busy', 'loading', 'progress', 'typing', 'draw'],
    ),
  );
}

/// Stubby waving, animation [frame] 0 to 2.
///
/// Mirrors `waveDef` in `src/lib/ink/art/mascots/props.ts`.
ArtDef waveDef(int frame) => pose(
  PoseSpec(
    face: const Face(
      eyes: EyeKind.dot,
      look: (1.2, -0.6),
      mouth: MouthKind.grin,
    ),
    turn: Xf(rot: const [-7.0, -9.5, -5.5][frame]),
    acc: waveMarks(frame),
    tags: const ['hello', 'welcome', 'greet', 'hi'],
  ),
);

/// Stubby celebrating, animation [frame] 0 or 1.
///
/// Mirrors `celebrateDef` in `src/lib/ink/art/mascots/props.ts`.
ArtDef celebrateDef(int frame) {
  final turn = switch (frame) {
    0 => const Xf(k: 0.93, dy: -2.6, rot: 3),
    _ => const Xf(sx: 1.04, sy: 0.95, rot: -1),
  };
  return pose(
    PoseSpec(
      face: const Face(eyes: EyeKind.happy, mouth: MouthKind.grin),
      turn: turn,
      acc: confetti(frame),
      hi: xf(confettiHi, Xf(dy: frame * 2.4)),
      tags: const ['success', 'done', 'yay', 'hooray', 'all done'],
    ),
  );
}

/// Builds Stubby's 15 poses from code; the same as the `mascot` catalog.
///
/// Mirrors `poses` in `src/lib/ink/art/mascots/poses.ts`.
Map<String, ArtDef> buildMascotPoses() => {
  'idle': pose(
    const PoseSpec(
      face: Face(eyes: EyeKind.dot, mouth: MouthKind.smile),
      tags: ['default', 'stand', 'hello'],
    ),
  ),
  'wave': waveDef(0),
  'think': pose(
    PoseSpec(
      face: const Face(
        eyes: EyeKind.dot,
        look: (-1.4, -1.2),
        mouth: MouthKind.flat,
        brows: BrowKind.one,
      ),
      turn: const Xf(rot: -5),
      acc: thoughtCloud,
      tags: const ['thinking', 'hmm', 'idea', 'ponder'],
    ),
  ),
  'write': writeDef(2),
  'sketch': pose(
    PoseSpec(
      face: const Face(eyes: EyeKind.wink, mouth: MouthKind.smile),
      turn: const Xf(rot: 6, dx: -4),
      acc: dashedFrame,
      tags: const ['draw', 'placeholder', 'measure', 'plan'],
    ),
  ),
  'celebrate': celebrateDef(0),
  'oops': pose(
    PoseSpec(
      face: const Face(eyes: EyeKind.wide, mouth: MouthKind.wavy, blush: false),
      turn: const Xf(rot: 7),
      tip: PencilTip.snapped,
      acc: sweatDrop,
      tags: const ['error', 'sorry', 'broke', 'uh oh'],
    ),
  ),
  'shrug': pose(
    PoseSpec(
      face: const Face(
        eyes: EyeKind.dot,
        mouth: MouthKind.wavy,
        brows: BrowKind.shrug,
      ),
      turn: const Xf(rot: -5, sx: 1.02, sy: 0.97),
      acc: questions,
      tags: const ['not found', 'unsure', 'dunno', 'lost'],
    ),
  ),
  'sleep': pose(
    PoseSpec(
      face: const Face(eyes: EyeKind.closed, mouth: MouthKind.yawn),
      turn: const Xf(rot: -10),
      acc: zzz,
      tags: const ['quiet', 'idle', 'nap', 'zzz'],
    ),
  ),
  'peek': pose(
    const PoseSpec(
      face: Face(eyes: EyeKind.dot, look: (2, 0), mouth: MouthKind.smile),
      peek: true,
      tags: ['hide', 'edge', 'coming soon', 'curious'],
    ),
  ),
  'point': pose(
    PoseSpec(
      face: const Face(
        eyes: EyeKind.dot,
        look: (1.8, -0.4),
        mouth: MouthKind.smile,
      ),
      turn: const Xf(rot: 3, dx: -5),
      acc: pointArrow,
      tags: const ['look', 'here', 'tour', 'hint'],
    ),
  ),
  'carry': pose(
    PoseSpec(
      face: const Face(eyes: EyeKind.squint, mouth: MouthKind.o),
      turn: const Xf(rot: -4, dx: -5),
      acc: parcel,
      tags: const ['upload', 'file', 'move', 'heavy'],
    ),
  ),
  'halt': pose(
    PoseSpec(
      face: const Face(
        eyes: EyeKind.dot,
        mouth: MouthKind.flat,
        brows: BrowKind.worry,
      ),
      turn: const Xf(rot: -3),
      acc: stopSign,
      tags: const ['stop', 'denied', 'forbidden', 'locked'],
    ),
  ),
  'search': pose(
    PoseSpec(
      face: const Face(eyes: EyeKind.lens, mouth: MouthKind.o),
      turn: const Xf(rot: -3),
      acc: magnifier,
      tags: const ['find', 'look', 'zoom', 'no results'],
    ),
  ),
  'unplug': pose(
    PoseSpec(
      face: const Face(
        eyes: EyeKind.dot,
        look: (0.8, 1.6),
        mouth: MouthKind.frown,
        brows: BrowKind.worry,
      ),
      turn: const Xf(rot: -4, sy: 0.96),
      acc: cableCut,
      tags: const ['offline', 'disconnected', 'network', 'cable'],
    ),
  ),
};

/// Builds Stubby's animation frames from code; the same as `mascotFrames`
/// in the catalog.
///
/// Mirrors `frames` in `src/lib/ink/art/mascots/props.ts`.
Map<String, ArtDef> buildMascotFrames() => {
  'write-1': writeDef(0),
  'write-2': writeDef(1),
  'write-3': writeDef(2),
  'wave-1': waveDef(0),
  'wave-2': waveDef(1),
  'wave-3': waveDef(2),
  'celebrate-1': celebrateDef(0),
  'celebrate-2': celebrateDef(1),
};
