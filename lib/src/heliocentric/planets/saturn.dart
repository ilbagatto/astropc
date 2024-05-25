import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../common.dart';
import '../orbit.dart';

import '../pert.dart';
import '../planet.dart';

/// Saturn
class Saturn extends Planet {
  static Saturn? _instance;

  Saturn._() : super.create(PlanetId.Saturn, "Saturn", _buildOrbit(), false);

  factory Saturn() => _instance ??= Saturn._();

  /// Initialize osculating elements of the planet's orbit
  static OElements _buildOrbit() {
    return OElements(
        ML: MLTerms(266.564377, 3.398638567, 3.245e-4, -5.8e-6),
        PH: Terms.make(9.1098214e1, 1.9584158, 8.2636e-4, 4.61e-6),
        EC: Terms.make(5.589232e-2, -3.455e-4, -7.28e-7, 7.4e-10),
        IN: Terms.make(2.492519, -3.9189e-3, -1.549e-5, 4e-8),
        ND: Terms.make(112.790414, 8.731951e-1, -1.5218e-4, -5.31e-6),
        SA: 9.554747);
  }

  @override
  PertRecord calculatePerturbations(CelestialContext ctx, [double dt = 0]) {
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
