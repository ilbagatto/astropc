import 'dart:math';

import 'package:vector_math/vector_math.dart';

import '../../planets.dart';
import '../../mathutils.dart';

/// A record holding perturbations for heliocentric orbit.
typedef PertRecord = ({
  /// in longitude
  double dl,

  /// in radius-vector
  double dr,

  /// in mean longitude
  double dml,

  /// in eccentricity
  double ds,

  /// in mean anomaly
  double dm,

  /// in semi-major axis
  double da,

  /// in heliocentric latitude
  double dhl
});

/// Auxiliraly Sun-related elements needed for calculating perturbations.
List<double> buildAuxSun(double t) {
  List<double> x = List.filled(6, 0);
  x[0] = t / 5 + 0.1;
  x[1] = reduceRad(4.14473 + 5.29691e1 * t);
  x[2] = reduceRad(4.641118 + 2.132991e1 * t);
  x[3] = reduceRad(4.250177 + 7.478172 * t);
  x[4] = 5 * x[2] - 2 * x[1];
  x[5] = 2 * x[1] - 6 * x[2] + 3 * x[3];

  return x;
}

/// Calculates planetary perturbations
abstract class PertCalculator {
  /// Planet identifier
  final PlanetId id;

  PertCalculator(this.id);

  /// Calculates perturbations.
  /// [ctx] is a context,
  /// [dt] is optional delta-T in seconds. Defaults to **0.0**.
  /// Returns `PertRecord` instance. Typically, some members are
  /// initialized while others contain zeroes.
  PertRecord calculatePerturbations(CelestialSphera ctx, [double dt = 0]);
}

/// Mercury perturbations.
class PertMercury extends PertCalculator {
  PertMercury() : super(PlanetId.Mercury);

  @override
  PertRecord calculatePerturbations(CelestialSphera ctx, [double dt = 0]) {
    final me = ctx.getMeanAnomaly(id, dt);
    final ve = ctx.getMeanAnomaly(PlanetId.Venus, dt);
    final ju = ctx.getMeanAnomaly(PlanetId.Jupiter, dt);

    final dl = .00204 * cos(5 * ve - 2 * me + .21328) +
        .00103 * cos(2 * ve - me - 2.8046) +
        .00091 * cos(2 * ju - me - .64582) +
        .00078 * cos(5 * ve - 3 * me + .17692);
    final dr = 7.525e-06 * cos(2 * ju - me + .925251) +
        6.802e-06 * cos(5 * ve - 3 * me - 4.53642) +
        5.457e-06 * cos(2 * ve - 2 * me - 1.24246) +
        3.569e-06 * cos(5 * ve - me - 1.35699);
    return (dl: dl, dr: dr, dml: 0, ds: 0, dm: 0, da: 0, dhl: 0);
  }
}

class PertVenus extends PertCalculator {
  PertVenus() : super(PlanetId.Venus);

  @override
  PertRecord calculatePerturbations(CelestialSphera ctx, [double dt = 0]) {
    final t = ctx.t;
    final ms = ctx.sunMeanAnomaly;
    final ve = ctx.getMeanAnomaly(PlanetId.Venus, dt);
    final ju = ctx.getMeanAnomaly(PlanetId.Jupiter, dt);

    final dl = .00313 * cos(2 * ms - 2 * ve - 2.587) +
        .00198 * cos(3 * ms - 3 * ve + .044768) +
        .00136 * cos(ms - ve - 2.0788) +
        .00096 * cos(3 * ms - 2 * ve - 2.3721) +
        .00082 * cos(ju - ve - 3.6318);
    final dr = 2.2501e-05 * cos(2 * ms - 2 * ve - 1.01592) +
        1.9045e-05 * cos(3 * ms - 3 * ve + 1.61577) +
        6.887e-06 * cos(ju - ve - 2.06106) +
        5.172e-06 * cos(ms - ve - .508065) +
        3.62e-06 * cos(5 * ms - 4 * ve - 1.81877) +
        3.283e-06 * cos(4 * ms - 4 * ve + 1.10851) +
        3.074e-06 * cos(2 * ju - 2 * ve - .962846);
    final dm = radians(7.7e-4 * sin(4.1406 + t * 2.6227));

    return (dl: dl, dr: dr, dml: dm, ds: 0, dm: dm, da: 0, dhl: 0);
  }
}

class PertMars extends PertCalculator {
  PertMars() : super(PlanetId.Mars);
  @override
  PertRecord calculatePerturbations(CelestialSphera ctx, [double dt = 0]) {
    final ve = ctx.getMeanAnomaly(PlanetId.Venus, dt);
    final ju = ctx.getMeanAnomaly(PlanetId.Jupiter, dt);

    final ms = ctx.sunMeanAnomaly;
    final ma = ctx.getMeanAnomaly(PlanetId.Mars, dt);
    final a = 3 * ju - 8 * ma + 4 * ms;
    final sa = sin(a);
    final ca = cos(a);

    final dl = .00705 * cos(ju - ma - .85448) +
        .00607 * cos(2 * ju - ma - 3.2873) +
        .00445 * cos(2 * ju - 2 * ma - 3.3492) +
        .00388 * cos(ms - 2 * ma + .35771) +
        .00238 * cos(ms - ma + .61256) +
        .00204 * cos(2 * ms - 3 * ma + 2.7688) +
        .00177 * cos(3 * ma - ve - 1.0053) +
        .00136 * cos(2 * ms - 4 * ma + 2.6894) +
        .00104 * cos(ju + .30749);

    final dr = 5.3227e-05 * cos(ju - ma + .717864) +
        5.0989e-05 * cos(2 * ju - 2 * ma - 1.77997) +
        3.8278e-05 * cos(2 * ju - ma - 1.71617) +
        1.5996e-05 * cos(ms - ma - .969618) +
        1.4764e-05 * cos(2 * ms - 3 * ma + 1.19768) +
        8.966e-06 * cos(ju - 2 * ma + .761225) +
        7.914e-06 * cos(3 * ju - 2 * ma - 2.43887) +
        7.004e-06 * cos(2 * ju - 3 * ma - 1.79573) +
        6.62e-06 * cos(ms - 2 * ma + 1.97575) +
        4.93e-06 * cos(3 * ju - 3 * ma - 1.33069) +
        4.693e-06 * cos(3 * ms - 5 * ma + 3.32665) +
        4.571e-06 * cos(2 * ms - 4 * ma + 4.27086) +
        4.409e-06 * cos(3 * ju - ma - 2.02158);

    final dm = radians(-(.01133 * sa + .00933 * ca));

    return (dl: dl, dr: dr, dml: dm, ds: 0, dm: dm, da: 0, dhl: 0);
  }
}

class PertJupiter extends PertCalculator {
  PertJupiter() : super(PlanetId.Jupiter);
  @override
  PertRecord calculatePerturbations(CelestialSphera ctx, [double dt = 0]) {
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

class PertSaturn extends PertCalculator {
  PertSaturn() : super(PlanetId.Saturn);
  @override
  PertRecord calculatePerturbations(CelestialSphera ctx, [double dt = 0]) {
    final s = ctx.getOrbitInstance(id).s;
    final x = ctx.auxSun;
    final x1 = x[0];
    final x2 = x[1];
    final x3 = x[2];
    final x4 = x[3];
    final x5 = x[4];
    final x6 = x[5];
    final x7 = x3 - x2;
    final x8 = x4 - x3;

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

    final s3x3 = sin(3 * x3);
    final c3x3 = cos(3 * x3);
    final s4x3 = sin(4 * x3);
    final c4x3 = cos(4 * x3);
    final c2x5 = cos(2 * x5);
    final s5x7 = sin(5 * x7);
    final s2x8 = sin(2 * x8);
    final c2x8 = cos(2 * x8);
    final s3x8 = sin(3 * x8);
    final c3x8 = cos(3 * x8);

    var dml = 7.581e-3 * s2x5 -
        7.986e-3 * sx6 -
        1.48811e-1 * sx7 -
        4.0786e-2 * s2x7 -
        (8.14181e-1 - (1.815e-2 - 1.6714e-2 * x1) * x1) * sx5 -
        (1.0497e-2 - (1.60906e-1 - 4.1e-3 * x1) * x1) * cx5 -
        1.5208e-2 * s3x7 -
        6.339e-3 * s4x7 -
        6.244e-3 * sx3 -
        1.65e-2 * s2x7 * sx3 +
        (8.931e-3 + 2.728e-3 * x1) * sx7 * sx3 -
        5.775e-3 * s3x7 * sx3 +
        (8.1344e-2 + 3.206e-3 * x1) * cx7 * sx3 +
        1.5019e-2 * c2x7 * sx3 +
        (8.5581e-2 + 2.494e-3 * x1) * sx7 * cx3 +
        1.4394e-2 * c2x7 * cx3 +
        (2.5328e-2 - 3.117e-3 * x1) * cx7 * cx3 +
        6.319e-3 * c3x7 * cx3 +
        6.369e-3 * sx7 * s2x3 +
        9.156e-3 * s2x7 * s2x3 +
        7.525e-3 * s3x8 * s2x3 -
        5.236e-3 * cx7 * c2x3 -
        7.736e-3 * c2x7 * c2x3 -
        7.528e-3 * c3x8 * c2x3;
    dml = radians(dml);

    var ds = (-7927 + (2548 + 91 * x1) * x1) * sx5 +
        (13381 + (1226 - 253 * x1) * x1) * cx5 +
        (248 - 121 * x1) * s2x5 -
        (305 + 91 * x1) * c2x5 +
        412 * s2x7 +
        12415 * sx3 +
        (390 - 617 * x1) * sx7 * sx3 +
        (165 - 204 * x1) * s2x7 * sx3 +
        26599 * cx7 * sx3 -
        4687 * c2x7 * sx3 -
        1870 * c3x7 * sx3 -
        821 * c4x7 * sx3 -
        377 * c5x7 * sx3 +
        497 * c2x8 * sx3 +
        (163 - 611 * x1) * cx3 -
        12696 * sx7 * cx3 -
        4200 * s2x7 * cx3 -
        1503 * s3x7 * cx3 -
        619 * s4x7 * cx3 -
        268 * s5x7 * cx3 -
        (282 + 1306 * x1) * cx7 * cx3 +
        (-86 + 230 * x1) * c2x7 * cx3 +
        461 * s2x8 * cx3 -
        350 * s2x3 +
        (2211 - 286 * x1) * sx7 * s2x3 -
        2208 * s2x7 * s2x3 -
        568 * s3x7 * s2x3 -
        346 * s4x7 * s2x3 -
        (2780 + 222 * x1) * cx7 * s2x3 +
        (2022 + 263 * x1) * c2x7 * s2x3 +
        248 * c3x7 * s2x3 +
        242 * s3x8 * s2x3 +
        467 * c3x8 * s2x3 -
        490 * c2x3 -
        (2842 + 279 * x1) * sx7 * c2x3 +
        (128 + 226 * x1) * s2x7 * c2x3 +
        224 * s3x7 * c2x3 +
        (-1594 + 282 * x1) * cx7 * c2x3 +
        (2162 - 207 * x1) * c2x7 * c2x3 +
        561 * c3x7 * c2x3 +
        343 * c4x7 * c2x3 +
        469 * s3x8 * c2x3 -
        242 * c3x8 * c2x3 -
        205 * sx7 * s3x3 +
        262 * s3x7 * s3x3 +
        208 * cx7 * c3x3 -
        271 * c3x7 * c3x3 -
        382 * c3x7 * s4x3 -
        376 * s3x7 * c4x3;
    ds *= 1e-7;

    final dp = (7.7108e-2 + (7.186e-3 - 1.533e-3 * x1) * x1) * sx5 -
        7.075e-3 * sx7 +
        (4.5803e-2 - (1.4766e-2 + 5.36e-4 * x1) * x1) * cx5 -
        7.2586e-2 * cx3 -
        7.5825e-2 * sx7 * sx3 -
        2.4839e-2 * s2x7 * sx3 -
        8.631e-3 * s3x7 * sx3 -
        1.50383e-1 * cx7 * cx3 +
        2.6897e-2 * c2x7 * cx3 +
        1.0053e-2 * c3x7 * cx3 -
        (1.3597e-2 + 1.719e-3 * x1) * sx7 * s2x3 +
        1.1981e-2 * s2x7 * c2x3 -
        (7.742e-3 - 1.517e-3 * x1) * cx7 * s2x3 +
        (1.3586e-2 - 1.375e-3 * x1) * c2x7 * c2x3 -
        (1.3667e-2 - 1.239e-3 * x1) * sx7 * c2x3 +
        (1.4861e-2 + 1.136e-3 * x1) * cx7 * c2x3 -
        (1.3064e-2 + 1.628e-3 * x1) * c2x7 * c2x3;

    final dm = dml - radians(dp) / s;

    var da = 572 * sx5 -
        1590 * s2x7 * cx3 +
        2933 * cx5 -
        647 * s3x7 * cx3 +
        33629 * cx7 -
        344 * s4x7 * cx3 -
        3081 * c2x7 +
        2885 * cx7 * cx3 -
        1423 * c3x7 +
        (2172 + 102 * x1) * c2x7 * cx3 -
        671 * c4x7 +
        296 * c3x7 * cx3 -
        320 * c5x7 -
        267 * s2x7 * s2x3 +
        1098 * sx3 -
        778 * cx7 * s2x3 -
        2812 * sx7 * sx3 +
        495 * c2x7 * s2x3 +
        688 * s2x7 * sx3 +
        250 * c3x7 * s2x3 -
        393 * s3x7 * sx3 -
        856 * sx7 * c2x3 -
        228 * s4x7 * sx3 +
        441 * s2x7 * c2x3 +
        2138 * cx7 * sx3 +
        296 * c2x7 * c2x3 -
        999 * c2x7 * sx3 +
        211 * c3x7 * c2x3 -
        642 * c3x7 * sx3 -
        427 * sx7 * s3x3 -
        325 * c4x7 * sx3 +
        398 * s3x7 * s3x3 -
        890 * cx3 +
        344 * cx7 * c3x3 +
        2206 * sx7 * cx3 -
        427 * c3x7 * c3x3;
    da *= 1e-6;

    var dhl = 7.47e-4 * cx7 * sx3 +
        1.069e-3 * cx7 * cx3 +
        2.108e-3 * s2x7 * s2x3 +
        1.261e-3 * c2x7 * s2x3 +
        1.236e-3 * s2x7 * c2x3 -
        2.075e-3 * c2x7 * c2x3;
    dhl = radians(dhl);

    return (dl: 0, dr: 0, dml: dml, ds: ds, dm: dm, da: da, dhl: dhl);
  }
}

class PertUranus extends PertCalculator {
  PertUranus() : super(PlanetId.Uranus);
  @override
  PertRecord calculatePerturbations(CelestialSphera ctx, [double dt = 0]) {
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

class PertNeptune extends PertCalculator {
  PertNeptune() : super(PlanetId.Neptune);
  @override
  PertRecord calculatePerturbations(CelestialSphera ctx, [double dt = 0]) {
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

class PertPluto extends PertCalculator {
  PertPluto() : super(PlanetId.Pluto);
  @override
  PertRecord calculatePerturbations(CelestialSphera ctx, [double dt = 0]) {
    return (dl: 0, dr: 0, dml: 0, ds: 0, dm: 0, da: 0, dhl: 0);
  }
}
