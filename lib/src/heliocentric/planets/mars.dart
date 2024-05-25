import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../common.dart';
import '../orbit.dart';
import '../pert.dart';
import '../planet.dart';

/// Mars
class Mars extends Planet {
  static Mars? _instance;

  Mars._() : super.create(PlanetId.Mars, "Mars", _buildOrbit(), false);

  factory Mars() => _instance ??= Mars._();

  /// Initialize osculating elements of the planet's orbit
  static OElements _buildOrbit() {
    return OElements(
        ML: MLTerms(293.737334, 53.17137642, 3.107e-4),
        PH: Terms.make(3.34218203e2, 1.8407584, 1.299e-4, -1.19e-6),
        EC: Terms.make(9.33129e-2, 9.2064e-5, -7.7e-8),
        IN: Terms.make(1.850333, -6.75e-4, 1.26e-5),
        ND: Terms.make(48.786442, 7.709917e-1, -1.4e-6, -5.33e-6),
        SA: 1.5236883);
  }

  @override
  PertRecord calculatePerturbations(CelestialContext ctx, [double dt = 0]) {
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
