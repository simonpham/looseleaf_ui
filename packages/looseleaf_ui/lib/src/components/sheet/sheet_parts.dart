import 'package:looseleaf_ui/src/components/dialog/dialog.dart';

/// The control that opens a [Sheet]; a [DialogTrigger] (use
/// `SheetTrigger.builder` around your own `Button`).
///
/// Mirrors `SheetTrigger` in upstream `src/components/ui/sheet.tsx`.
typedef SheetTrigger = DialogTrigger;

/// Anything that closes the nearest [Sheet]; a [DialogClose].
///
/// Mirrors `SheetClose` in upstream `src/components/ui/sheet.tsx`.
typedef SheetClose = DialogClose;

/// A sheet's name, in the script face at 27 px.
///
/// Mirrors `SheetTitle` in upstream `src/components/ui/sheet.tsx`.
typedef SheetTitle = DialogTitle;

/// What a sheet is for, in small muted ink.
///
/// Mirrors `SheetDescription` in upstream `src/components/ui/sheet.tsx`.
typedef SheetDescription = DialogDescription;

/// How a [SheetContent] is bound along its inner edge (the one facing the
/// page).
enum SheetBinding {
  /// A wire spiral through punched holes.
  spiral,

  /// Three reinforced punched holes.
  holes,

  /// A perforated edge, as if torn off a pad along the dots.
  perf,

  /// A torn edge.
  torn,

  /// A plain cut edge.
  none,
}
