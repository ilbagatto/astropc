import 'dart:math';

import '../common.dart';
import '../orbit.dart';
import '../pert.dart';
import '../planet.dart';

/// Mercury
class Mercury extends Planet {
  static Mercury? _instance;

  Mercury._() : super.create(PlanetId.Mercury, "Mercury", _buildOrbit(), true);

  factory Mercury() => _instance ??= Mercury._();

  /// Initialize osculating elements of the planet's orbit
  static OElements _buildOrbit() {
    return OElements(
        ML: MLTerms(178.179078, 415.2057519, 3.011e-4),
        PH: Terms.make(75.899697, 1.5554889, 2.947e-4),
        EC: Terms.make(2.0561421e-1, 2.046e-5, -3e-8),
        IN: Terms.make(7.002881, 1.8608e-3, -1.83e-5),
        ND: Terms.make(47.145944, 1.1852083, 1.739e-4),
        SA: 3.870986e-1);
  }

  @override
  PertRecord calculatePerturbations(CelestialContext ctx, [double dt = 0]) {
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
