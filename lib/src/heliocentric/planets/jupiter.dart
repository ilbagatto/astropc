import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../common.dart';
import '../orbit.dart';
import '../pert.dart';
import '../planet.dart';

/// Jupiter
class Jupiter extends Planet {
  static Jupiter? _instance;

  Jupiter._() : super.create(PlanetId.Jupiter, "Jupiter", _buildOrbit(), false);

  factory Jupiter() => _instance ??= Jupiter._();

  /// Initialize osculating elements of the planet's orbit
  static OElements _buildOrbit() {
    return OElements(
        ML: MLTerms(238.049257, 8.434172183, 3.347e-4, -1.65e-6),
        PH: Terms.make(1.2720972e1, 1.6099617, 1.05627e-3, -3.43e-6),
        EC: Terms.make(4.833475e-2, 1.6418e-4, -4.676e-7, -1.7e-9),
        IN: Terms.make(1.308736, -5.6961e-3, 3.9e-6),
        ND: Terms.make(99.443414, 1.01053, 3.5222e-4, -8.51e-6),
        SA: 5.202561);
  }

  @override
  PertRecord calculatePerturbations(CelestialContext ctx, [double dt = 0]) {
    final s = ctx.getOrbitInstance(id).s;
    final x = ctx.auxSun;
    final x1 = x[0];
    final x2 = x[1];
    final x3 = x[2];
    final x5 = x[4];
    final x6 = x[5];
    final x7 = x3 - x2;

    final sx3 = sin(x3);
    final cx3 = cos(x3);
    final s2x3 = sin(2 * x3);
    final c2x3 = cos(2 * x3);
    final sx5 = sin(x5);
    final cx5 = cos(x5);
    final s2x5 = sin(2 * x5);
    final sx6 = sin(x6);
    final sx7 = sin(x7);
    final cx7 = cos(x7);
    final s2x7 = sin(2 * x7);
    final c2x7 = cos(2 * x7);
    final s3x7 = sin(3 * x7);
    final c3x7 = cos(3 * x7);
    final s4x7 = sin(4 * x7);
    final c4x7 = cos(4 * x7);
    final c5x7 = cos(5 * x7);

    var dml = (3.31364e-1 - (1.0281e-2 + 4.692e-3 * x1) * x1) * sx5 +
        (3.228e-3 - (6.4436e-2 - 2.075e-3 * x1) * x1) * cx5 -
        (3.083e-3 + (2.75e-4 - 4.89e-4 * x1) * x1) * s2x5 +
        2.472e-3 * sx6 +
        1.3619e-2 * sx7 +
        1.8472e-2 * s2x7 +
        6.717e-3 * s3x7 +
        2.775e-3 * s4x7 +
        6.417e-3 * s2x7 * sx3 +
        (7.275e-3 - 1.253e-3 * x1) * sx7 * sx3 +
        2.439e-3 * s3x7 * sx3 -
        (3.5681e-2 + 1.208e-3 * x1) * sx7 * cx3 -
        3.767e-3 * c2x7 * sx3 -
        (3.3839e-2 + 1.125e-3 * x1) * cx7 * sx3 -
        4.261e-3 * s2x7 * cx3 +
        (1.161e-3 * x1 - 6.333e-3) * cx7 * cx3 +
        2.178e-3 * cx3 -
        6.675e-3 * c2x7 * cx3 -
        2.664e-3 * c3x7 * cx3 -
        2.572e-3 * sx7 * s2x3 -
        3.567e-3 * s2x7 * s2x3 +
        2.094e-3 * cx7 * c2x3 +
        3.342e-3 * c2x7 * c2x3;
    dml = radians(dml);

    var ds = (3606 + (130 - 43 * x1) * x1) * sx5 +
        (1289 - 580 * x1) * cx5 -
        6764 * sx7 * sx3 -
        1110 * s2x7 * sx3 -
        224 * s3x7 * sx3 -
        204 * sx3 +
        (1284 + 116 * x1) * cx7 * sx3 +
        188 * c2x7 * sx3 +
        (1460 + 130 * x1) * sx7 * cx3 +
        224 * s2x7 * cx3 -
        817 * cx3 +
        6074 * cx3 * cx7 +
        992 * c2x7 * cx3 +
        508 * c3x7 * cx3 +
        230 * c4x7 * cx3 +
        108 * c5x7 * cx3 -
        (956 + 73 * x1) * sx7 * s2x3 +
        448 * s2x7 * s2x3 +
        137 * s3x7 * s2x3 +
        (108 * x1 - 997) * cx7 * s2x3 +
        480 * c2x7 * s2x3 +
        148 * c3x7 * s2x3 +
        (99 * x1 - 956) * sx7 * c2x3 +
        490 * s2x7 * c2x3 +
        158 * s3x7 * c2x3 +
        179 * c2x3 +
        (1024 + 75 * x1) * cx7 * c2x3 -
        437 * c2x7 * c2x3 -
        132 * c3x7 * c2x3;
    ds *= 1e-7;

    final dp = (7.192e-3 - 3.147e-3 * x1) * sx5 -
        4.344e-3 * sx3 +
        (x1 * (1.97e-4 * x1 - 6.75e-4) - 2.0428e-2) * cx5 +
        3.4036e-2 * cx7 * sx3 +
        (7.269e-3 + 6.72e-4 * x1) * sx7 * sx3 +
        5.614e-3 * c2x7 * sx3 +
        2.964e-3 * c3x7 * sx3 +
        3.7761e-2 * sx7 * cx3 +
        6.158e-3 * s2x7 * cx3 -
        6.603e-3 * cx7 * cx3 -
        5.356e-3 * sx7 * s2x3 +
        2.722e-3 * s2x7 * s2x3 +
        4.483e-3 * cx7 * s2x3 -
        2.642e-3 * c2x7 * s2x3 +
        4.403e-3 * sx7 * c2x3 -
        2.536e-3 * s2x7 * c2x3 +
        5.547e-3 * cx7 * c2x3 -
        2.689e-3 * c2x7 * c2x3;

    final dm = dml - radians(dp) / s;

    var da = 205 * cx7 -
        263 * cx5 +
        693 * c2x7 +
        312 * c3x7 +
        147 * c4x7 +
        299 * sx7 * sx3 +
        181 * c2x7 * sx3 +
        204 * s2x7 * cx3 +
        111 * s3x7 * cx3 -
        337 * cx7 * cx3 -
        111 * c2x7 * cx3;
    da *= 1e-6;

    return (dl: 0, dr: 0, dml: dml, ds: ds, dm: dm, da: da, dhl: 0);
  }
}
