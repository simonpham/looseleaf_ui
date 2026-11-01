import 'dart:typed_data';

import 'package:looseleaf_ink/src/core/core.dart';

final ByteData _bits = ByteData(8);

const double _two54 = 1.80143985094819840000e+16;
const double _ivln10 = 4.34294481903251816668e-01;
const double _log10_2hi = 3.01029995663611771306e-01;
const double _log10_2lo = 3.69423907715893078616e-13;

/// `Math.log10` as V8 computes it (fdlibm `e_log10.c`).
double jsLog10(double v) {
  var x = v;
  _bits.setFloat64(0, x, Endian.little);
  var hx = _bits.getInt32(4, Endian.little);
  final lx = _bits.getUint32(0, Endian.little);
  var k = 0;
  if (hx < 0x00100000) {
    if (((hx & 0x7FFFFFFF) | lx) == 0) return double.negativeInfinity;
    if (hx < 0) return double.nan;
    k -= 54;
    x *= _two54;
    _bits.setFloat64(0, x, Endian.little);
    hx = _bits.getInt32(4, Endian.little);
  }
  if (hx >= 0x7FF00000) return x + x;
  if (hx == 0x3FF00000 && lx == 0) return 0;
  k += (hx >> 20) - 1023;
  final i = switch (k < 0) {
    true => 1,
    false => 0,
  };
  hx = (hx & 0x000FFFFF) | ((0x3FF - i) << 20);
  final y = (k + i).toDouble();
  _bits.setInt32(4, hx, Endian.little);
  final z =
      y * _log10_2lo + _ivln10 * JsMath.log(_bits.getFloat64(0, Endian.little));
  return z + y * _log10_2hi;
}

// Integer exponents where V8's `10 ** e` is one ulp below (-1) or above
// (+1) the correctly rounded `1e<e>`.
const Map<int, int> _pow10Ulps = {
  -57: 1,
  -39: 1,
  -32: -1,
  -29: 1,
  -24: 1,
  -23: 1,
  -21: 1,
  -20: 1,
  -17: -1,
  -5: -1,
  -4: -1,
  26: -1,
  29: 1,
  34: 1,
  36: -1,
  39: 1,
  42: -1,
  49: 1,
  58: 1,
};

/// `10 ** e`, as V8 computes it (bit for bit for integer `e` in
/// `[-60, 60]`).
double jsPow10(double e) {
  if (e != e.truncateToDouble() || e.abs() > 60) return JsMath.pow(10, e);
  final k = e.toInt();
  final exact = double.parse('1e$k');
  final ulps = _pow10Ulps[k] ?? 0;
  if (ulps == 0) return exact;
  _bits.setFloat64(0, exact, Endian.little);
  _bits.setInt64(0, _bits.getInt64(0, Endian.little) + ulps, Endian.little);
  return _bits.getFloat64(0, Endian.little);
}
