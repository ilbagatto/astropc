import '../../mathutils.dart';

/// A record holding an perturbations for heliocentric orbit.
typedef PertRecord = ({
  double dl,
  double dr,
  double dml,
  double ds,
  double dm,
  double da,
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
