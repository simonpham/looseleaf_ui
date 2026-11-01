import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The display settings, upstream `SettingsProvider` and the desk knob:
/// density, ink tier, motion, direction and the things on the desk.
class SettingsViewModel extends ChangeNotifier {
  LooseleafDensity _density = LooseleafDensity.comfortable;
  LooseleafTier _tier = LooseleafTier.lo;
  LooseleafMotion _motion = LooseleafMotion.system;
  TextDirection _direction = TextDirection.ltr;
  bool _clutter = true;

  LooseleafDensity get density => _density;
  LooseleafTier get tier => _tier;
  LooseleafMotion get motion => _motion;
  TextDirection get direction => _direction;

  /// Whether coffee and clips lie on the desk.
  bool get clutter => _clutter;

  /// The theme these settings draw with.
  LooseleafThemeData get theme => LooseleafThemeData(
    density: _density,
    tier: _tier,
    motion: _motion,
    textDirection: _direction,
  );

  void setDensity(LooseleafDensity density) {
    _density = density;
    notifyListeners();
  }

  void setTier(LooseleafTier tier) {
    _tier = tier;
    notifyListeners();
  }

  void setMotion(LooseleafMotion motion) {
    _motion = motion;
    notifyListeners();
  }

  void setRightToLeft(bool rightToLeft) {
    _direction = switch (rightToLeft) {
      true => TextDirection.rtl,
      false => TextDirection.ltr,
    };
    notifyListeners();
  }

  void setClutter(bool clutter) {
    _clutter = clutter;
    notifyListeners();
  }
}
