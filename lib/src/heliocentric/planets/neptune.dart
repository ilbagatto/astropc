import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../../mathutils.dart';
import '../common.dart';
import '../planet.dart';
import '../orbit.dart';
import '../pert.dart';

/// Neptune
class Neptune extends Planet {
  static Neptune? _instance;

  Neptune._() : super.create(PlanetId.Neptune, "Neptune", _buildOrbit(), false);

  factory Neptune() => _instance ??= Neptune._();

  /// Initialize osculating elements of the planet's orbit
  static OElements _buildOrbit() {
    return OElements(
        ML: MLTerms(84.457994, 6.107942056e-1, 3.205e-4, -6e-7),
        PH: Terms.make(4.6727364e1, 1.4245744, 3.9082e-4, -6.05e-7),
        EC: Terms.make(8.99704e-3, 6.33e-6, -2e-9),
        IN: Terms.make(1.779242, -9.5436e-3, -9.1e-6),
        ND: Terms.make(130.681389, 1.098935, 2.4987e-4, -4.718e-6),
        SA: 30.10957);
  }

  @override
  PertRecord calculatePerturbations(CelestialContext ctx, [double dt = 0]) {
    final t = ctx.t;
    final s = ctx.getOrbitInstance(id).s;
    final x = ctx.auxSun;
    final x1 = x[0];
    final x2 = x[1];
    final x3 = x[2];
    final x4 = x[3];
    final x8 = reduceRad(1.46205 + 3.81337 * t);
    final x9 = 2 * x8 - x4;
    final x10 = x8 - x2;
    final x11 = x8 - x3;
    final x12 = x8 - x4;
    final sx9 = sin(x9);
    final cx9 = cos(x9);
    final s2x9 = sin(2 * x9);
    final c2x9 = cos(2 * x9);

    var dml = (1.089e-3 * x1 - 5.89833e-1) * sx9 +
        (4.658e-3 * x1 - 5.6094e-2) * cx9 -
        2.4286e-2 * s2x9;
    dml = radians(dml);
    final dp =
        2.4039e-2 * sx9 - 2.5303e-2 * cx9 + 6.206e-3 * s2x9 - 5.992e-3 * c2x9;
    final dm = dml - radians(dp) / s;
    var ds = 4389 * sx9 + 1129 * s2x9 + 4262 * cx9 + 1089 * c2x9;
    ds *= 1e-7;
    var da = 8189 * cx9 - 817 * sx9 + 781 * c2x9;
    da *= 1e-6;
    final s2x12 = sin(2 * x12);
    final c2x12 = cos(2 * x12);
    final sx8 = sin(x8);
    final cx8 = cos(x8);
    final dl = -9.556e-3 * sin(x10) -
        5.178e-3 * sin(x11) +
        2.572e-3 * s2x12 -
        2.972e-3 * c2x12 * sx8 -
        2.833e-3 * s2x12 * cx8;
    var dhl = 3.36e-4 * c2x12 * sx8 + 3.64e-4 * s2x12 * cx8;
    dhl = radians(dhl);
    var dr = -40596 +
        4992 * cos(x10) +
        2744 * cos(x11) +
        2044 * cos(x12) +
        1051 * c2x12;
    dr *= 1e-6;

    return (dl: dl, dr: dr, dml: dml, ds: ds, dm: dm, da: da, dhl: dhl);
  }
}
