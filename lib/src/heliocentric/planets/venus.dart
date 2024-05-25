import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../common.dart';
import '../orbit.dart';
import '../pert.dart';
import '../planet.dart';

/// Venus
class Venus extends Planet {
  static Venus? _instance;

  Venus._() : super.create(PlanetId.Venus, "Venus", _buildOrbit(), true);

  factory Venus() => _instance ??= Venus._();

  /// Initialize osculating elements of the planet's orbit
  static OElements _buildOrbit() {
    return OElements(
        ML: MLTerms(342.767053, 162.5533664, 3.097e-4),
        PH: Terms.make(130.163833, 1.4080361, -9.764e-4),
        EC: Terms.make(6.82069e-3, -4.774e-5, 9.1e-8),
        IN: Terms.make(3.393631, 1.0058e-3, -1e-6),
        ND: Terms.make(75.779647, 8.9985e-1, 4.1e-4),
        SA: 7.233316e-1);
  }

  @override
  PertRecord calculatePerturbations(CelestialContext ctx, [double dt = 0]) {
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
