import 'package:looseleaf_ui/src/components/menu/menu.dart';

/// The slip a menubar menu drops: an [InkMenuContent].
///
/// Mirrors `MenubarContent` in upstream
/// `src/components/ui/menubar.tsx`.
typedef MenubarContent = InkMenuContent;

/// Groups rows: an [InkMenuGroup].
typedef MenubarGroup = InkMenuGroup;

/// A typewriter heading: an [InkMenuLabel].
typedef MenubarLabel = InkMenuLabel;

/// A row: an [InkMenuItem].
typedef MenubarItem = InkMenuItem;

/// A toggle row with a pencil box: an [InkMenuCheckboxItem].
typedef MenubarCheckboxItem = InkMenuCheckboxItem;

/// Holds radio rows: an [InkMenuRadioGroup].
typedef MenubarRadioGroup = InkMenuRadioGroup;

/// One choice with a pencil ring: an [InkMenuRadioItem].
typedef MenubarRadioItem = InkMenuRadioItem;

/// A pencil rule between groups: an [InkMenuSeparator].
typedef MenubarSeparator = InkMenuSeparator;

/// Keys drawn as keycaps at a row's end: an [InkMenuShortcut].
typedef MenubarShortcut = InkMenuShortcut;

/// A nested menu: an [InkMenuSub].
typedef MenubarSub = InkMenuSub;

/// The row that opens a sub-menu: an [InkMenuSubTrigger].
typedef MenubarSubTrigger = InkMenuSubTrigger;

/// A sub-menu's slip: an [InkMenuSubContent].
typedef MenubarSubContent = InkMenuSubContent;
