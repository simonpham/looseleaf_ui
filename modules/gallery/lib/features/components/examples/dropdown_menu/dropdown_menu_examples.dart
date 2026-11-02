import 'package:gallery/features/components/examples/dropdown_menu/dropdown_menu.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/dropdown-menu/`.
const dropdownMenuExamples = <GalleryExample>[
  GalleryExample(
    title: 'Account menu',
    description: 'The shadcn demo on a slip: a typewriter label, rows with drawn icons and keycaps, a disabled row, a sub-menu, and a destructive row last.',
    height: 460,
    source: 'dropdown_menu/dropdown_menu_account_example.dart',
    builder: DropdownMenuAccountExample.new,
  ),
  GalleryExample(
    title: 'Ticks and dots',
    description: 'Checkbox rows are a pencil box with a felt tick written over it; radio rows are a ring with a bold dot. Both are controlled here, and the rows keep the menu open so you can tick several.',
    height: 420,
    source: 'dropdown_menu/dropdown_menu_ticks_and_dots_example.dart',
    builder: DropdownMenuTicksAndDotsExample.new,
  ),
  GalleryExample(
    title: 'Other paper',
    description: 'The slip is a Paper, so it can be cut from any stock and held down with tape. A sticky note with a taped corner for quick actions; the destructive row hatches when you reach it.',
    stage: ExampleStage.desk,
    height: 340,
    source: 'dropdown_menu/dropdown_menu_slips_example.dart',
    builder: DropdownMenuSlipsExample.new,
  ),
  GalleryExample(
    title: 'Row actions (composed)',
    description: 'A real use: a list of notebooks, each row with an ellipsis button that opens its own menu. Choosing Rename or Move to trash changes the list, so you can see the handlers run.',
    height: 430,
    source: 'dropdown_menu/dropdown_menu_row_actions_example.dart',
    builder: DropdownMenuRowActionsExample.new,
  ),
  GalleryExample(
    title: 'Checkboxes',
    description: 'shadcn\'s dropdown-menu-checkboxes: three controlled rows, the middle one disabled. The state is a boolean that you own; the menu stays open while you tick.',
    height: 300,
    source: 'dropdown_menu/dropdown_menu_checkboxes_example.dart',
    builder: DropdownMenuCheckboxesExample.new,
  ),
  GalleryExample(
    title: 'Radio group',
    description: 'shadcn\'s dropdown-menu-radio-group: one value for the whole group, value and onChanged. The chosen row carries the drawn dot.',
    height: 300,
    source: 'dropdown_menu/dropdown_menu_radio_group_example.dart',
    builder: DropdownMenuRadioGroupExample.new,
  ),
  GalleryExample(
    title: 'Opening dialogs from a menu',
    description: 'shadcn\'s dropdown-menu-dialog: the dialogs live beside the menu, not inside it, and onSelect flips their open state. modal: false on the menu keeps the page interactive while it closes, so focus lands in the dialog.',
    height: 460,
    source: 'dropdown_menu/dropdown_menu_dialog_example.dart',
    builder: DropdownMenuDialogExample.new,
  ),
];
