import 'package:looseleaf_ui/src/components/menu/menu.dart';

/// The slip a context menu opens: an [InkMenuContent].
///
/// Mirrors `ContextMenuContent` in upstream
/// `src/components/ui/context-menu.tsx`.
typedef ContextMenuContent = InkMenuContent;

/// Groups rows: an [InkMenuGroup].
typedef ContextMenuGroup = InkMenuGroup;

/// A typewriter heading: an [InkMenuLabel].
typedef ContextMenuLabel = InkMenuLabel;

/// A row: an [InkMenuItem].
typedef ContextMenuItem = InkMenuItem;

/// A toggle row with a pencil box: an [InkMenuCheckboxItem].
typedef ContextMenuCheckboxItem = InkMenuCheckboxItem;

/// Holds radio rows: an [InkMenuRadioGroup].
typedef ContextMenuRadioGroup = InkMenuRadioGroup;

/// One choice with a pencil ring: an [InkMenuRadioItem].
typedef ContextMenuRadioItem = InkMenuRadioItem;

/// A pencil rule between groups: an [InkMenuSeparator].
typedef ContextMenuSeparator = InkMenuSeparator;

/// Keys drawn as keycaps at a row's end: an [InkMenuShortcut].
typedef ContextMenuShortcut = InkMenuShortcut;

/// A nested menu: an [InkMenuSub].
typedef ContextMenuSub = InkMenuSub;

/// The row that opens a sub-menu: an [InkMenuSubTrigger].
typedef ContextMenuSubTrigger = InkMenuSubTrigger;

/// A sub-menu's slip: an [InkMenuSubContent].
typedef ContextMenuSubContent = InkMenuSubContent;
