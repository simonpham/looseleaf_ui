/// Where a centred `InkPopup` sits in the window.
///
/// Mirrors the frame of upstream dialogs (`flex p-4 max-sm:p-0` around a
/// `m-auto` sheet) and its overrides.
enum PopupPlacement {
  /// In the middle, 16 px from the edges (`m-auto`).
  center,

  /// 12 % of the window down, 16 px from the sides (`mt-[12dvh] mb-auto`):
  /// a command palette.
  top,

  /// Flush on the bottom edge, as wide as the window (`max-sm:p-0
  /// max-sm:mb-0`): a dialog on a phone. The popup pads itself past the
  /// bottom safe area.
  phoneBottom,

  /// 8 px from the top, as wide as the window (`max-sm:mt-2`): a command
  /// palette on a phone.
  phoneTop;

  /// This placement on a phone-sized window: [top] stays at the top, the
  /// rest docks at the bottom.
  PopupPlacement get onPhone => switch (this) {
    PopupPlacement.top || PopupPlacement.phoneTop => PopupPlacement.phoneTop,
    PopupPlacement.center ||
    PopupPlacement.phoneBottom => PopupPlacement.phoneBottom,
  };
}
