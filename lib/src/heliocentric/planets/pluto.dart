import '../common.dart';
import '../orbit.dart';
import '../pert.dart';
import '../planet.dart';

/// Pluto
class Pluto extends Planet {
  static Pluto? _instance;

  Pluto._() : super.create(PlanetId.Pluto, "Pluto", _buildOrbit(), false);

  factory Pluto() => _instance ??= Pluto._();

  /// Initialize osculating elements of the planet's orbit
  static OElements _buildOrbit() {
    return OElements(
        ML: MLTerms(95.3113544, 3.980332167e-1),
        PH: Terms.make(224.017),
        EC: Terms.make(2.5515e-1),
        IN: Terms.make(17.1329),
        ND: Terms.make(110.191),
        SA: 39.8151);
  }

  @override
  PertRecord calculatePerturbations(CelestialContext ctx, [double dt = 0]) {
    return (dl: 0, dr: 0, dml: 0, ds: 0, dm: 0, da: 0, dhl: 0);
  }
}
