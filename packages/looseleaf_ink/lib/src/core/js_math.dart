import 'dart:math' as math;
import 'dart:typed_data';

/// JavaScript number semantics the engine relies on, so Dart draws the same
/// bits as V8: `Math.round`, `Math.hypot`, `Math.imul`, `>>> 0`, `String(n)`
/// and the fdlibm transcendental functions behind V8's `Math.*`
/// (`src/base/ieee754.cc`, a port of FreeBSD msun).
abstract final class JsMath {
  static final ByteData _bits = ByteData(8);

  static int _hi(double x) {
    _bits.setFloat64(0, x, Endian.little);
    return _bits.getInt32(4, Endian.little);
  }

  static int _lo(double x) {
    _bits.setFloat64(0, x, Endian.little);
    return _bits.getUint32(0, Endian.little);
  }

  static double _words(int hi, int lo) {
    _bits.setInt32(4, hi.toSigned(32), Endian.little);
    _bits.setUint32(0, lo & 0xFFFFFFFF, Endian.little);
    return _bits.getFloat64(0, Endian.little);
  }

  static double _withLo(double x, int lo) => _words(_hi(x), lo);

  static double _withHi(double x, int hi) => _words(hi, _lo(x));

  /// `Math.PI`.
  static const double pi = math.pi;

  /// `Math.sqrt` (exact in both runtimes).
  static double sqrt(double x) => math.sqrt(x);

  /// `Number.prototype.toFixed`.
  static String toFixed(double v, int digits) {
    if (!v.isFinite) return numberToString(v);
    return v.toStringAsFixed(digits);
  }

  /// JavaScript's `v || fallback` for numbers: 0 and NaN are falsy.
  static double or(double v, double fallback) {
    if (v == 0 || v.isNaN) return fallback;
    return v;
  }

  /// `Math.round`: halves round toward +∞.
  static double round(double x) {
    if (!x.isFinite) return x;
    final floor = x.floorToDouble();
    if (x - floor >= 0.5) return floor + 1;
    return floor;
  }

  /// [round] as an int, for finite values.
  static int roundInt(double x) => round(x).toInt();

  /// `Math.hypot` as V8 computes it: normalized Kahan sum.
  static double hypot(double a, double b) {
    if (a.isNaN || b.isNaN) {
      if (a.isInfinite || b.isInfinite) return double.infinity;
      return double.nan;
    }
    final x = a.abs(), y = b.abs();
    final max = math.max(x, y);
    if (max == double.infinity) return double.infinity;
    if (max == 0) return 0;
    var sum = 0.0, compensation = 0.0;
    for (final v in [x, y]) {
      final n = v / max;
      final summand = n * n - compensation;
      final preliminary = sum + summand;
      compensation = (preliminary - sum) - summand;
      sum = preliminary;
    }
    return math.sqrt(sum) * max;
  }

  /// `Math.imul` on 32-bit values, returned as an unsigned 32-bit int.
  static int imul(int a, int b) =>
      ((a & 0xFFFFFFFF) * (b & 0xFFFFFFFF)) & 0xFFFFFFFF;

  /// `v >>> 0` for any JS number.
  static int toUint32(double v) {
    if (!v.isFinite) return 0;
    return (v.truncateToDouble() % 4294967296.0).toInt();
  }

  /// `String(v)` for a JS number.
  static String numberToString(num v) {
    if (v is int) return v.toString();
    final d = v.toDouble();
    if (d.isNaN) return 'NaN';
    if (d == double.infinity) return 'Infinity';
    if (d == double.negativeInfinity) return '-Infinity';
    if (d == d.truncateToDouble() && d.abs() < 1e21) {
      if (d.abs() < 9007199254740992) return d.toInt().toString();
      return d.toString().substring(0, d.toString().length - 2);
    }
    return d.toString();
  }

  static const double _s1 = -1.66666666666666324348e-01;
  static const double _s2 = 8.33333333332248946124e-03;
  static const double _s3 = -1.98412698298579493134e-04;
  static const double _s4 = 2.75573137070700676789e-06;
  static const double _s5 = -2.50507602534068634195e-08;
  static const double _s6 = 1.58969099521155010221e-10;

  static double _kernelSin(double x, double y, int iy) {
    final ix = _hi(x) & 0x7fffffff;
    if (ix < 0x3e400000 && x.truncate() == 0) return x;
    final z = x * x;
    final v = z * x;
    final r = _s2 + z * (_s3 + z * (_s4 + z * (_s5 + z * _s6)));
    if (iy == 0) return x + v * (_s1 + z * r);
    return x - ((z * (0.5 * y - v * r) - y) - v * _s1);
  }

  static const double _c1 = 4.16666666666666019037e-02;
  static const double _c2 = -1.38888888888741095749e-03;
  static const double _c3 = 2.48015872894767294178e-05;
  static const double _c4 = -2.75573143513906633035e-07;
  static const double _c5 = 2.08757232129817482790e-09;
  static const double _c6 = -1.13596475577881948265e-11;

  static double _kernelCos(double x, double y) {
    final ix = _hi(x) & 0x7fffffff;
    if (ix < 0x3e400000 && x.truncate() == 0) return 1;
    final z = x * x;
    final r =
        z * (_c1 + z * (_c2 + z * (_c3 + z * (_c4 + z * (_c5 + z * _c6)))));
    if (ix < 0x3fd33333) return 1 - (0.5 * z - (z * r - x * y));
    final qx = switch (ix > 0x3fe90000) {
      true => 0.28125,
      false => _words(ix - 0x00200000, 0),
    };
    final hz = 0.5 * z - qx;
    final a = 1 - qx;
    return a - (hz - (z * r - x * y));
  }

  static const List<int> _npio2hw = [
    0x3FF921FB, 0x400921FB, 0x4012D97C, 0x401921FB, 0x401F6A7A, 0x4022D97C, //
    0x4025FDBB, 0x402921FB, 0x402C463A, 0x402F6A7A, 0x4031475C, 0x4032D97C,
    0x40346B9C, 0x4035FDBB, 0x40378FDB, 0x403921FB, 0x403AB41B, 0x403C463A,
    0x403DD85A, 0x403F6A7A, 0x40407E4C, 0x4041475C, 0x4042106C, 0x4042D97C,
    0x4043A28C, 0x40446B9C, 0x404534AC, 0x4045FDBB, 0x4046C6CB, 0x40478FDB,
    0x404858EB, 0x404921FB,
  ];
  static const double _invpio2 = 6.36619772367581382433e-01;
  static const double _pio2_1 = 1.57079632673412561417e+00;
  static const double _pio2_1t = 6.07710050650619224932e-11;
  static const double _pio2_2 = 6.07710050630396597660e-11;
  static const double _pio2_2t = 2.02226624879595063154e-21;
  static const double _pio2_3 = 2.02226624871116645580e-21;
  static const double _pio2_3t = 8.47842766036889956997e-32;

  /// Reduces [x] by π/2: returns `(n, y0, y1)`, or null when |x| is too
  /// large for the medium-size path (> 2^19·π/2 ≈ 823550). Those arguments
  /// fall back to the platform's sin/cos; ink geometry never gets near them.
  static (int, double, double)? _remPio2(double x) {
    final hx = _hi(x);
    final ix = hx & 0x7fffffff;
    if (ix <= 0x3fe921fb) return (0, x, 0);
    if (ix < 0x4002d97c) {
      if (hx > 0) {
        var z = x - _pio2_1;
        if (ix != 0x3ff921fb) {
          final y0 = z - _pio2_1t;
          return (1, y0, (z - y0) - _pio2_1t);
        }
        z -= _pio2_2;
        final y0 = z - _pio2_2t;
        return (1, y0, (z - y0) - _pio2_2t);
      }
      var z = x + _pio2_1;
      if (ix != 0x3ff921fb) {
        final y0 = z + _pio2_1t;
        return (-1, y0, (z - y0) + _pio2_1t);
      }
      z += _pio2_2;
      final y0 = z + _pio2_2t;
      return (-1, y0, (z - y0) + _pio2_2t);
    }
    if (ix > 0x413921fb) return null;
    var t = x.abs();
    final n = (t * _invpio2 + 0.5).truncate();
    final fn = n.toDouble();
    var r = t - fn * _pio2_1;
    var w = fn * _pio2_1t;
    var y0 = r - w;
    if (n >= 32 || ix == _npio2hw[n - 1]) {
      final j = ix >> 20;
      var i = j - ((_hi(y0) >> 20) & 0x7ff);
      if (i > 16) {
        t = r;
        w = fn * _pio2_2;
        r = t - w;
        w = fn * _pio2_2t - ((t - r) - w);
        y0 = r - w;
        i = j - ((_hi(y0) >> 20) & 0x7ff);
        if (i > 49) {
          t = r;
          w = fn * _pio2_3;
          r = t - w;
          w = fn * _pio2_3t - ((t - r) - w);
          y0 = r - w;
        }
      }
    }
    final y1 = (r - y0) - w;
    if (hx < 0) return (-n, -y0, -y1);
    return (n, y0, y1);
  }

  /// `Math.sin`.
  static double sin(double x) {
    final ix = _hi(x) & 0x7fffffff;
    if (ix <= 0x3fe921fb) return _kernelSin(x, 0, 0);
    if (ix >= 0x7ff00000) return double.nan;
    final reduced = _remPio2(x);
    if (reduced == null) return math.sin(x);
    final (n, y0, y1) = reduced;
    return switch (n & 3) {
      0 => _kernelSin(y0, y1, 1),
      1 => _kernelCos(y0, y1),
      2 => -_kernelSin(y0, y1, 1),
      _ => -_kernelCos(y0, y1),
    };
  }

  /// `Math.cos`.
  static double cos(double x) {
    final ix = _hi(x) & 0x7fffffff;
    if (ix <= 0x3fe921fb) return _kernelCos(x, 0);
    if (ix >= 0x7ff00000) return double.nan;
    final reduced = _remPio2(x);
    if (reduced == null) return math.cos(x);
    final (n, y0, y1) = reduced;
    return switch (n & 3) {
      0 => _kernelCos(y0, y1),
      1 => -_kernelSin(y0, y1, 1),
      2 => -_kernelCos(y0, y1),
      _ => _kernelSin(y0, y1, 1),
    };
  }

  static const double _ln2Hi = 6.93147180369123816490e-01;
  static const double _ln2Lo = 1.90821492927058770002e-10;
  static const double _invln2 = 1.44269504088896338700e+00;
  static const double _p1 = 1.66666666666666019037e-01;
  static const double _p2 = -2.77777777770155933842e-03;
  static const double _p3 = 6.61375632143793436117e-05;
  static const double _p4 = -1.65339022054652515390e-06;
  static const double _p5 = 4.13813679705723846039e-08;

  /// `Math.exp`.
  static double exp(double x) {
    var hx = _hi(x);
    final xsb = (hx >> 31) & 1;
    hx &= 0x7fffffff;
    if (hx >= 0x40862E42) {
      if (hx >= 0x7ff00000) {
        if (x.isNaN) return x;
        if (xsb == 0) return x;
        return 0;
      }
      if (x > 7.09782712893383973096e+02) return double.infinity;
      if (x < -7.45133219101941108420e+02) return 0;
    }
    if (hx < 0x3e300000) return 1 + x;
    if (x == 1.0) return math.e;
    var k = 0;
    var hi = 0.0, lo = 0.0;
    if (hx > 0x3fd62e42) {
      (k, hi, lo) = _expReduce(x, hx, xsb);
      x = hi - lo;
    }
    final t = x * x;
    final c = x - t * (_p1 + t * (_p2 + t * (_p3 + t * (_p4 + t * _p5))));
    if (k == 0) return 1 - ((x * c) / (c - 2.0) - x);
    final y = 1 - ((lo - (x * c) / (2.0 - c)) - hi);
    if (k >= -1021) {
      if (k == 1024) return y * 2.0 * 8.98846567431157953865e+307;
      return y * _words(0x3ff00000 + (k << 20), 0);
    }
    return y *
        _words(0x3ff00000 + ((k + 1000) << 20), 0) *
        9.33263618503218878990e-302;
  }

  static (int, double, double) _expReduce(double x, int hx, int xsb) {
    if (hx < 0x3FF0A2B2) {
      final sign = 1 - 2 * xsb;
      return (sign, x - sign * _ln2Hi, sign * _ln2Lo);
    }
    final k = (_invln2 * x + (0.5 - xsb)).truncate();
    final t = k.toDouble();
    return (k, x - t * _ln2Hi, t * _ln2Lo);
  }

  static const double _two54 = 1.80143985094819840000e+16;
  static const double _lg1 = 6.666666666666735130e-01;
  static const double _lg2 = 3.999999999940941908e-01;
  static const double _lg3 = 2.857142874366239149e-01;
  static const double _lg4 = 2.222219843214978396e-01;
  static const double _lg5 = 1.818357216161805012e-01;
  static const double _lg6 = 1.531383769920937332e-01;
  static const double _lg7 = 1.479819860511658591e-01;

  /// `Math.log`.
  static double log(double x) {
    var hx = _hi(x);
    final lx = _lo(x);
    var k = 0;
    if (hx < 0x00100000) {
      if (((hx & 0x7fffffff) | lx) == 0) return double.negativeInfinity;
      if (hx < 0) return double.nan;
      k -= 54;
      x *= _two54;
      hx = _hi(x);
    }
    if (hx >= 0x7ff00000) return x + x;
    k += (hx >> 20) - 1023;
    hx &= 0x000fffff;
    final i0 = (hx + 0x95f64) & 0x100000;
    x = _withHi(x, hx | (i0 ^ 0x3ff00000));
    k += i0 >> 20;
    final f = x - 1.0;
    if ((0x000fffff & (2 + hx)) < 3) {
      if (f == 0) {
        if (k == 0) return 0;
        final dk = k.toDouble();
        return dk * _ln2Hi + dk * _ln2Lo;
      }
      final r = f * f * (0.5 - 0.33333333333333333 * f);
      if (k == 0) return f - r;
      final dk = k.toDouble();
      return dk * _ln2Hi - ((r - dk * _ln2Lo) - f);
    }
    final s = f / (2.0 + f);
    final dk = k.toDouble();
    final z = s * s;
    var i = hx - 0x6147a;
    final w = z * z;
    final j = 0x6b851 - hx;
    final t1 = w * (_lg2 + w * (_lg4 + w * _lg6));
    final t2 = z * (_lg1 + w * (_lg3 + w * (_lg5 + w * _lg7)));
    i |= j;
    final r = t2 + t1;
    if (i > 0) {
      final hfsq = 0.5 * f * f;
      if (k == 0) return f - (hfsq - s * (hfsq + r));
      return dk * _ln2Hi - ((hfsq - (s * (hfsq + r) + dk * _ln2Lo)) - f);
    }
    if (k == 0) return f - s * (f - r);
    return dk * _ln2Hi - ((s * (f - r) - dk * _ln2Lo) - f);
  }

  static const List<double> _atanHi = [
    4.63647609000806093515e-01,
    7.85398163397448278999e-01,
    9.82793723247329054082e-01,
    1.57079632679489655800e+00,
  ];
  static const List<double> _atanLo = [
    2.26987774529616870924e-17,
    3.06161699786838301793e-17,
    1.39033110312309984516e-17,
    6.12323399573676603587e-17,
  ];
  static const List<double> _aT = [
    3.33333333333329318027e-01,
    -1.99999999998764832476e-01,
    1.42857142725034663711e-01,
    -1.11111104054623557880e-01,
    9.09088713343650656196e-02,
    -7.69187620504482999495e-02,
    6.66107313738753120669e-02,
    -5.83357013379057348645e-02,
    4.97687799461593236017e-02,
    -3.65315727442169155270e-02,
    1.62858201153657823623e-02,
  ];

  /// `Math.atan`.
  static double atan(double x) {
    final hx = _hi(x);
    final ix = hx & 0x7fffffff;
    if (ix >= 0x44100000) {
      if (x.isNaN) return x;
      if (hx > 0) return _atanHi[3] + _atanLo[3];
      return -_atanHi[3] - _atanLo[3];
    }
    if (ix < 0x3e400000) return x;
    final int id;
    (id, x) = _atanReduce(x, ix);
    final z = x * x;
    final w = z * z;
    final s1 =
        z *
        (_aT[0] +
            w *
                (_aT[2] +
                    w * (_aT[4] + w * (_aT[6] + w * (_aT[8] + w * _aT[10])))));
    final s2 =
        w * (_aT[1] + w * (_aT[3] + w * (_aT[5] + w * (_aT[7] + w * _aT[9]))));
    if (id < 0) return x - x * (s1 + s2);
    final r = _atanHi[id] - ((x * (s1 + s2) - _atanLo[id]) - x);
    if (hx < 0) return -r;
    return r;
  }

  static (int, double) _atanReduce(double x, int ix) {
    if (ix < 0x3fdc0000) return (-1, x);
    final a = x.abs();
    if (ix < 0x3fe60000) return (0, (2.0 * a - 1.0) / (2.0 + a));
    if (ix < 0x3ff30000) return (1, (a - 1.0) / (a + 1.0));
    if (ix < 0x40038000) return (2, (a - 1.5) / (1.0 + 1.5 * a));
    return (3, -1.0 / a);
  }

  static const double _piO4 = 7.8539816339744827900E-01;
  static const double _piO2 = 1.5707963267948965580E+00;
  static const double _pi = 3.1415926535897931160E+00;
  static const double _piLo = 1.2246467991473531772E-16;

  /// `Math.atan2`.
  static double atan2(double y, double x) {
    if (x.isNaN || y.isNaN) return double.nan;
    final hx = _hi(x), ix = hx & 0x7fffffff, lx = _lo(x);
    final hy = _hi(y), iy = hy & 0x7fffffff, ly = _lo(y);
    if (((hx - 0x3ff00000) | lx) == 0) return atan(y);
    final m = ((hy >> 31) & 1) | ((hx >> 30) & 2);
    if ((iy | ly) == 0) {
      return switch (m) {
        0 || 1 => y,
        2 => _pi,
        _ => -_pi,
      };
    }
    if ((ix | lx) == 0) {
      if (hy < 0) return -_piO2;
      return _piO2;
    }
    if (ix == 0x7ff00000) {
      if (iy == 0x7ff00000) {
        return switch (m) {
          0 => _piO4,
          1 => -_piO4,
          2 => 3.0 * _piO4,
          _ => -3.0 * _piO4,
        };
      }
      return switch (m) {
        0 => 0.0,
        1 => -0.0,
        2 => _pi,
        _ => -_pi,
      };
    }
    if (iy == 0x7ff00000) {
      if (hy < 0) return -_piO2;
      return _piO2;
    }
    final k = (iy - ix) >> 20;
    if (k > 60) return _atan2Quadrant(m & 1, _piO2 + 0.5 * _piLo);
    if (hx < 0 && k < -60) return _atan2Quadrant(m, 0.0);
    return _atan2Quadrant(m, atan((y / x).abs()));
  }

  static double _atan2Quadrant(int m, double z) => switch (m) {
    0 => z,
    1 => -z,
    2 => _pi - (z - _piLo),
    _ => (z - _piLo) - _pi,
  };

  static const List<double> _bp = [1.0, 1.5];
  static const List<double> _dpH = [0.0, 5.84962487220764160156e-01];
  static const List<double> _dpL = [0.0, 1.35003920212974897128e-08];
  static const double _two53 = 9007199254740992.0;
  static const double _huge = 1.0e300;
  static const double _tiny = 1.0e-300;
  static const double _l1 = 5.99999999999994648725e-01;
  static const double _l2 = 4.28571428578550184252e-01;
  static const double _l3 = 3.33333329818377432918e-01;
  static const double _l4 = 2.72728123808534006489e-01;
  static const double _l5 = 2.30660745775561754067e-01;
  static const double _l6 = 2.06975017800338417784e-01;
  static const double _lg2Full = 6.93147180559945286227e-01;
  static const double _lg2H = 6.93147182464599609375e-01;
  static const double _lg2L = -1.90465429995776804525e-09;
  static const double _ovt = 8.0085662595372944372e-17;
  static const double _cp = 9.61796693925975554329e-01;
  static const double _cpH = 9.61796700954437255859e-01;
  static const double _cpL = -7.02846165095275826516e-09;
  static const double _ivln2 = 1.44269504088896338700e+00;
  static const double _ivln2H = 1.44269502162933349609e+00;
  static const double _ivln2L = 1.92596299112661746887e-08;

  static int _yIsInt(int iy, int ly) {
    if (iy >= 0x43400000) return 2;
    if (iy < 0x3ff00000) return 0;
    final k = (iy >> 20) - 0x3ff;
    if (k > 20) {
      final j = ly >> (52 - k);
      if (((j << (52 - k)) & 0xFFFFFFFF) == ly) return 2 - (j & 1);
      return 0;
    }
    if (ly != 0) return 0;
    final j = iy >> (20 - k);
    if ((j << (20 - k)) == iy) return 2 - (j & 1);
    return 0;
  }

  static (double, double) _log2NearOne(double ax) {
    final t = ax - 1.0;
    final w = (t * t) * (0.5 - t * (3.3333333333333331e-01 - t * 0.25));
    final u = _ivln2H * t;
    final v = t * _ivln2L - w * _ivln2;
    final t1 = _withLo(u + v, 0);
    return (t1, v - (t1 - u));
  }

  static (double, double) _log2(double ax, int ix) {
    var n = 0;
    if (ix < 0x00100000) {
      ax *= _two53;
      n -= 53;
      ix = _hi(ax);
    }
    n += (ix >> 20) - 0x3ff;
    final j = ix & 0x000fffff;
    ix = j | 0x3ff00000;
    final k = switch (j > 0x3988E && j < 0xBB67A) {
      true => 1,
      false => 0,
    };
    if (j >= 0xBB67A) {
      n += 1;
      ix -= 0x00100000;
    }
    ax = _withHi(ax, ix);
    var u = ax - _bp[k];
    var v = 1.0 / (ax + _bp[k]);
    final ss = u * v;
    final sH = _withLo(ss, 0);
    var tH = _words(((ix >> 1) | 0x20000000) + 0x00080000 + (k << 18), 0);
    var tL = ax - (tH - _bp[k]);
    final sL = v * ((u - sH * tH) - sH * tL);
    var s2 = ss * ss;
    var r =
        s2 *
        s2 *
        (_l1 + s2 * (_l2 + s2 * (_l3 + s2 * (_l4 + s2 * (_l5 + s2 * _l6)))));
    r += sL * (sH + ss);
    s2 = sH * sH;
    tH = _withLo(3.0 + s2 + r, 0);
    tL = r - ((tH - 3.0) - s2);
    u = sH * tH;
    v = sL * tH + tL * ss;
    final pH = _withLo(u + v, 0);
    final pL = v - (pH - u);
    final zH = _cpH * pH;
    final zL = _cpL * pH + pL * _cp + _dpL[k];
    final t = n.toDouble();
    final t1 = _withLo(((zH + zL) + _dpH[k]) + t, 0);
    return (t1, zL - (((t1 - t) - _dpH[k]) - zH));
  }

  static double _overflowIf(bool overflow, double sign) => switch (overflow) {
    true => sign * double.infinity,
    false => sign * 0.0,
  };

  /// `Math.pow` and `**`.
  static double pow(double x, double y) {
    final hx = _hi(x), lx = _lo(x);
    final hy = _hi(y), ly = _lo(y);
    final ix = hx & 0x7fffffff;
    final iy = hy & 0x7fffffff;
    if ((iy | ly) == 0) return 1;
    if (y.isNaN) return double.nan;
    if (hx == 0x3ff00000 && lx == 0) {
      if (y.isInfinite) return double.nan;
      return 1;
    }
    if (x.isNaN) return double.nan;
    final yisint = switch (hx < 0) {
      true => _yIsInt(iy, ly),
      false => 0,
    };
    if (ly == 0) {
      if (iy == 0x7ff00000) {
        if (((ix - 0x3ff00000) | lx) == 0) return double.nan;
        if (ix >= 0x3ff00000) {
          if (hy >= 0) return y;
          return 0;
        }
        if (hy < 0) return -y;
        return 0;
      }
      if (iy == 0x3ff00000) {
        if (hy < 0) return 1 / x;
        return x;
      }
      if (hy == 0x40000000) return x * x;
      if (hy == 0x3fe00000 && hx >= 0) return math.sqrt(x);
    }
    final ax = x.abs();
    if (lx == 0 && (ix == 0x7ff00000 || ix == 0 || ix == 0x3ff00000)) {
      var z = ax;
      if (hy < 0) z = 1 / z;
      if (hx < 0) {
        if (((ix - 0x3ff00000) | yisint) == 0) return double.nan;
        if (yisint == 1) z = -z;
      }
      return z;
    }
    final n0 = ((hx & 0xFFFFFFFF) >> 31) - 1;
    if ((n0 | yisint) == 0) return double.nan;
    final s = switch ((n0 | (yisint - 1)) == 0) {
      true => -1.0,
      false => 1.0,
    };
    if (iy > 0x43f00000 && ix <= 0x3fefffff) return _overflowIf(hy < 0, 1);
    if (iy > 0x43f00000 && ix >= 0x3ff00000) return _overflowIf(hy > 0, 1);
    if (iy > 0x41e00000 && ix < 0x3fefffff) return _overflowIf(hy < 0, s);
    if (iy > 0x41e00000 && ix > 0x3ff00000) return _overflowIf(hy > 0, s);
    final (t1, t2) = switch (iy > 0x41e00000) {
      true => _log2NearOne(ax),
      false => _log2(ax, ix),
    };
    final y1 = _withLo(y, 0);
    final pL = (y - y1) * t1 + y * t2;
    var pH = y1 * t1;
    var z = pL + pH;
    var j = _hi(z);
    final lowZ = _lo(z);
    if (j >= 0x40900000 && ((j - 0x40900000) | lowZ) != 0) {
      return s * _huge * _huge;
    }
    if (j >= 0x40900000 && pL + _ovt > z - pH) return s * _huge * _huge;
    final under = j < 0x40900000 && (j & 0x7fffffff) >= 0x4090cc00;
    if (under && ((j - 0xc090cc00.toSigned(32)) | lowZ) != 0) {
      return s * _tiny * _tiny;
    }
    if (under && pL <= z - pH) return s * _tiny * _tiny;
    final i = j & 0x7fffffff;
    var k = (i >> 20) - 0x3ff;
    var n = 0;
    if (i > 0x3fe00000) {
      n = j + (0x00100000 >> (k + 1));
      k = ((n & 0x7fffffff) >> 20) - 0x3ff;
      final t = _words(n & ~(0x000fffff >> k), 0);
      n = ((n & 0x000fffff) | 0x00100000) >> (20 - k);
      if (j < 0) n = -n;
      pH -= t;
    }
    final t = _withLo(pL + pH, 0);
    final u = t * _lg2H;
    final v = (pL - (t - pH)) * _lg2Full + t * _lg2L;
    z = u + v;
    final w = v - (z - u);
    final tt = z * z;
    final tt1 =
        z - tt * (_p1 + tt * (_p2 + tt * (_p3 + tt * (_p4 + tt * _p5))));
    final r = (z * tt1) / (tt1 - 2.0) - (w + z * w);
    z = 1.0 - (r - z);
    j = _hi(z) + (n << 20);
    if ((j >> 20) <= 0) return s * z * math.pow(2.0, n).toDouble();
    return s * _withHi(z, j);
  }
}
