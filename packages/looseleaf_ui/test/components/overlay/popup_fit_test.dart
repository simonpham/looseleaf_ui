import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

import '../../support/overlay_host.dart';

const Widget _column = Column(children: [Text('One'), Text('Two')]);

Button _trigger() => Button(onPressed: () {}, child: const Text('Open'));

Future<double> _popupHeight(WidgetTester tester, Widget popup) async {
  tester.view.physicalSize = const Size(800, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(overlayHost(popup));
  await tester.pumpAndSettle();
  return tester.getSize(find.byType(PaperPopup).first).height;
}

void main() {
  testWidgets('a plain Column sizes a popover to its children', (
    tester,
  ) async {
    final height = await _popupHeight(
      tester,
      Popover(
        defaultOpen: true,
        content: const PopoverContent(seed: 'p', child: _column),
        child: _trigger(),
      ),
    );
    expect(height, lessThan(120));
  });

  testWidgets('a plain Column sizes a hover card to its children', (
    tester,
  ) async {
    final height = await _popupHeight(
      tester,
      HoverCard(
        defaultOpen: true,
        content: const HoverCardContent(seed: 'h', child: _column),
        child: _trigger(),
      ),
    );
    expect(height, lessThan(120));
  });

  testWidgets('a plain Column sizes a tooltip to its children', (
    tester,
  ) async {
    final height = await _popupHeight(
      tester,
      Tooltip(
        defaultOpen: true,
        content: const TooltipContent(seed: 't', child: _column),
        child: _trigger(),
      ),
    );
    expect(height, lessThan(120));
  });

  testWidgets('a Command in a popover sizes to its rows', (tester) async {
    final height = await _popupHeight(
      tester,
      Popover(
        defaultOpen: true,
        content: const PopoverContent(
          seed: 'p',
          padding: EdgeInsets.zero,
          child: Command(
            children: [
              CommandInput(placeholder: 'Filter...'),
              CommandList(
                children: [
                  CommandGroup(
                    children: [
                      CommandItem(value: 'a', child: Text('A')),
                      CommandItem(value: 'b', child: Text('B')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        child: _trigger(),
      ),
    );
    expect(height, lessThan(240));
  });

  testWidgets('dropdown menus, selects and sticker pickers size to rows', (
    tester,
  ) async {
    expect(
      await _popupHeight(
        tester,
        DropdownMenu(
          defaultOpen: true,
          content: const DropdownMenuContent(
            seed: 'm',
            children: [
              DropdownMenuItem(child: Text('One')),
              DropdownMenuItem(child: Text('Two')),
            ],
          ),
          child: _trigger(),
        ),
      ),
      lessThan(120),
    );
    expect(
      await _popupHeight(
        tester,
        const SizedBox(
          width: 190,
          child: Select(
            defaultOpen: true,
            content: SelectContent(
              position: SelectPosition.popper,
              seed: 's',
              children: [
                SelectItem(value: 'a', child: Text('A')),
                SelectItem(value: 'b', child: Text('B')),
              ],
            ),
            child: SelectTrigger(child: SelectValue()),
          ),
        ),
      ),
      lessThan(120),
    );
    expect(
      await _popupHeight(
        tester,
        StickerPicker(
          defaultOpen: true,
          content: const StickerPickerContent(seed: 'k'),
          child: _trigger(),
        ),
      ),
      lessThan(500),
    );
  });

  testWidgets('content taller than the overlay keeps to the overlay', (
    tester,
  ) async {
    final height = await _popupHeight(
      tester,
      Popover(
        defaultOpen: true,
        content: PopoverContent(
          seed: 'p',
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var i = 0; i < 80; i++) Text('Row $i'),
              ],
            ),
          ),
        ),
        child: _trigger(),
      ),
    );
    expect(height, lessThanOrEqualTo(900));
  });
}
