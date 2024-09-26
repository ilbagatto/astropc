/// Osculating orbital elements
// ignore_for_file: non_constant_identifier_names

library;

import 'package:vector_math/vector_math.dart';

import '../timeutils/julian.dart';
import '../mathutils.dart';

/// Orbital terms
class Terms {
  final List<double> _terms;

  /// Constructor
  const Terms(this._terms);

  /// Osculating terms of the orbit
  List<double> get terms => _terms;

  /// Creates Terms instance from any number of arguments.
  factory Terms.make(double a, [double b = 0, double c = 0, double d = 0]) {
    return Terms([a, b, c, d]);
  }

  /// Instaniate osculating elements for moment [t], centuries
  /// passed since the epoch 1900,0
  double assemble(double t) => reduceDeg(polynome(t, terms));
}

/// Mean Lonitude, a special case of Terms
class MLTerms extends Terms {
  /// Constructor
  MLTerms(double a, [double b = 0, double c = 0, double d = 0])
      : super([a, b, c, d]);

  /// The mean longitude increases by 360 deg. for every rotation of the PlanetId
  /// about the Sun. In order to preserve accuracy, it is is expressed in such
  /// a manner that integer rotations are subtracted from the second term of the
  /// expression  before adding the other terms.
  @override
  double assemble(double t) {
    final b = frac360(terms[1] * t);
    return reduceDeg(terms[0] + b + (terms[3] * t + terms[2]) * t * t);
  }
}

/// A record holding an orbit instantiated for a given moment of time.
/// All angular values are in radians.
typedef OrbitInstance = ({
  double ph, // argument of perihelion
  double s, // eccentricity
  double nd, // ascending node
  double ic, // inclination
  double sa, // major semi-axis
  double ma, // mean anomaly
  double dm // mean daily motion
});

/// Osculating elements of an orbit
class OElements {
  late MLTerms ML; // mean longitude
  late Terms PH; // argument of perihelion
  late Terms EC; // eccentricity
  late Terms IN; // inclination
  late Terms ND; // ascending node
  late double SA; // major semi-axis
  double? _DM; // mean daily motion

  /// Constructor
  OElements(
      {required this.ML,
      required this.PH,
      required this.EC,
      required this.IN,
      required this.ND,
      required this.SA});

  /// Given [t], time in centuries from epoch 1900.0,
  /// calculate Mean Anomaly in arc-degrees.
  double meanAnomaly(double t) => reduceDeg(ML.assemble(t) - PH.assemble(t));

  /// Mean Daily motion
  double get DM {
    _DM ??=
        ML.terms[1] * 9.856263e-3 + (ML.terms[2] + ML.terms[3]) / daysPerCent;
    return _DM!;
  }

  // Instantiate orbit for a given moment.
  OrbitInstance instantiate(double t) {
    final ph = PH.assemble(t);
    return (
      ph: radians(ph),
      s: EC.assemble(t),
      nd: radians(ND.assemble(t)),
      ic: radians(IN.assemble(t)),
      sa: SA,
      ma: radians(reduceDeg(ML.assemble(t) - ph)),
      dm: radians(DM)
    );
  }
}
