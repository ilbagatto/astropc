import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../mathutils.dart';
import 'sun.dart';

enum SolEquType {
  marchEquinox,
  juneSolstice,
  septemberEquinox,
  decemberSolstice
}

/// Solstice/quinox event circumstances
class SolEquEvent {
  final double _djd;
  final double _lambda;

  const SolEquEvent(this._djd, this._lambda);

  /// Number of Julian days since 1900 Jan. 0.5
  double get djd => _djd;

  /// Apparent longitude of the Sun, arc-degrees
  double get lambda => _lambda;
}

/// Find time of solstice or equinox for a given year.
/// The result is accurate within 5 minutes of Universal Time.
SolEquEvent solEqu(int year, SolEquType type) {
  late int k;
  switch (type) {
    case SolEquType.marchEquinox:
      k = 0;
      break;
    case SolEquType.juneSolstice:
      k = 1;
      break;
    case SolEquType.septemberEquinox:
      k = 2;
      break;
    case SolEquType.decemberSolstice:
      k = 3;
  }
  final k90 = k * 90.0;
  var dj = (year + k / 4.0) * 365.2422 - 693878.7; // shorter but less exact way
  double x;
  do {
    final sg = apparent(dj, ignoreLightTravel: true);
    x = sg.phi;
    dj += 58.0 * sin(radians(k90 - x));
  } while (shortestArc(k90, x) >= 1e-6);
  return SolEquEvent(dj, x);
}
