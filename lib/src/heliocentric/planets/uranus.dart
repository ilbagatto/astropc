import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../../mathutils.dart';
import '../common.dart';
import '../orbit.dart';
import '../pert.dart';
import '../planet.dart';

/// Uranus
class Uranus extends Planet {
  static Uranus? _instance;

  Uranus._() : super.create(PlanetId.Uranus, "Uranus", _buildOrbit(), false);

  factory Uranus() => _instance ??= Uranus._();

  /// Initialize osculating elements of the planet's orbit
  static OElements _buildOrbit() {
    return OElements(
        ML: MLTerms(244.19747, 1.194065406, 3.16e-4, -6e-7),
        PH: Terms.make(1.71548692e2, 1.4844328, 2.372e-4, -6.1e-7),
        EC: Terms.make(4.63444e-2, -2.658e-5, 7.7e-8),
        IN: Terms.make(7.72464e-1, 6.253e-4, 3.95e-5),
        ND: Terms.make(73.477111, 4.986678e-1, 1.3117e-3),
        SA: 19.21814);
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
    final x6 = x[5];
    final x8 = reduceRad(1.46205 + 3.81337 * t);
    final x9 = 2 * x8 - x4;
    final x10 = x4 - x2;
    final x11 = x4 - x3;
    final x12 = x8 - x4;
    final sx9 = sin(x9);
    final cx9 = cos(x9);
    final s2x9 = sin(2 * x9);
    final c2x9 = cos(2 * x9);

    var dml = (8.64319e-1 - 1.583e-3 * x1) * sx9 +
        (8.2222e-2 - 6.833e-3 * x1) * cx9 +
        3.6017e-2 * s2x9 -
        3.019e-3 * c2x9 +
        8.122e-3 * sin(x6);
    dml = radians(dml);

    final dp =
        1.20303e-1 * sx9 + 6.197e-3 * s2x9 + (1.9472e-2 - 9.47e-4 * x1) * cx9;
    final dm = dml - radians(dp) / s;
    var ds = (163 * x1 - 3349) * sx9 + 20981 * cx9 + 1311 * c2x9;
    ds *= 1e-7;
    final da = -3.825e-3 * cx9;
    final dl = (1.0122e-2 - 9.88e-4 * x1) * sin(x4 + x11) +
        (-3.8581e-2 + (2.031e-3 - 1.91e-3 * x1) * x1) * cos(x4 + x11) +
        (3.4964e-2 - (1.038e-3 - 8.68e-4 * x1) * x1) * cos(2 * x4 + x11) +
        5.594e-3 * sin(x4 + 3 * x12) -
        1.4808e-2 * sin(x10) -
        5.794e-3 * sin(x11) +
        2.347e-3 * cos(x11) +
        9.872e-3 * sin(x12) +
        8.803e-3 * sin(2 * x12) -
        4.308e-3 * sin(3 * x12);

    final sx11 = sin(x11);
    final cx11 = cos(x11);
    final sx4 = sin(x4);
    final cx4 = cos(x4);
    final s2x4 = sin(2 * x4);
    final c2x4 = cos(2 * x4);
    var dhl = (4.58e-4 * sx11 - 6.42e-4 * cx11 - 5.17e-4 * cos(4 * x12)) * sx4 -
        (3.47e-4 * sx11 + 8.53e-4 * cx11 + 5.17e-4 * sin(4 * x11)) * cx4 +
        4.03e-4 * (cos(2 * x12) * s2x4 + sin(2 * x12) * c2x4);
    dhl = radians(dhl);

    var dr = -25948 +
        4985 * cos(x10) -
        1230 * cx4 +
        3354 * cos(x11) +
        904 * cos(2 * x12) +
        894 * (cos(x12) - cos(3 * x12)) +
        (5795 * cx4 - 1165 * sx4 + 1388 * c2x4) * sx11 +
        (1351 * cx4 + 5702 * sx4 + 1388 * s2x4) * cos(x11);
    dr *= 1e-6;

    return (dl: dl, dr: dr, dml: dml, ds: ds, dm: dm, da: da, dhl: dhl);
  }
}
