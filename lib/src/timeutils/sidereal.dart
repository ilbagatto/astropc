///
/// Converts a given civil time into the local sidereal time and vice-versa.
///
/// == Sidereal and Civil time
///
/// *Sidereal time* is reckoned by the daily transit of a fixed point in space
/// (fixed with respect to the distant stars), 24 hours of sidereal time elapsing
/// between an successive transits. The sidereal day is thus shorter than the
/// solar day by nearely 4 minutes, and although the solar and sidereal time
/// agree once a year, the difference between them grows systematically as the
/// months pass in the sense that sidereal time runs faster than solar time.
/// *Sidereal time* (ST) is used extensively by astronomers since it is the time
/// kept by the star.
///
/// == Caveats
///
/// Times may be converted quite easily from UT to Greenwich mean sidereal time
/// (SG) since **there is a small range of sidereal times which occurs twice on
/// the same calendar date**. The ambiguous period is from 23h 56m 04s UT to
/// Oh 03m 56s UT, i.e. about 4 minutes either side of midnight. The routine
/// given here correctly converts SG to UT in the period before midnight, but
/// not in the period after midnight when the ambiguity must be resolved by other
/// means.
///
/// -- *Peter Duffett-Smith, "Astronomy with your PC*"
///
library;

import '../mathutils.dart';
import 'julian.dart';

const solarToStd = 1.002737909350795;
const sidRate = 0.9972695677;
const ambigDelta = 6.552E-2;

double _tnaught(double djd) {
  final date = calDay(djd);
  final dj0 = julDay(date.year, 1, 0.0);
  final t = dj0 / 36525;
  return 6.57098e-2 * (djd - dj0) -
      (24 -
          (6.6460656 + (5.1262e-2 + (t * 2.581e-5)) * t) -
          (2400 * (t - ((date.year - 1900) / 100))));
}

/// Converts civil to Local Sidereal time.
/// [djd] is number of Julian days elapsed since 1900, Jan 0.5.
/// [lng] is optional Geographic longitude, negative eastwards, 0.0 by default
double djdToSidereal(double djd, {double lng = 0.0}) {
  final djm = djdMidnight(djd);
  final utc = (djd - djm) * 24;
  final t0 = _tnaught(djm);
  final gst = (1.0 / sidRate) * utc + t0;
  final lst = gst - lng / 15;
  return toRange(lst, 24.0);
}

/// Convert Local Sidereal time [lst] to civil time.
/// [djd] is a number of Julian days elapsed since 1900, Jan 0.5.
/// [lng] optional Geographic longitude, negative eastwards, 0.0 by default
/// callback function receives 2 arguments:
/// * Universal time
/// * flag, which is _true_ if the result is ambiguous (see Caveats)
void siderealToUTC(
    {required double lst,
    required double djd,
    double lng = 0.0,
    required Function(double, bool) callback}) {
  final djm = djdMidnight(djd);
  final t0 = toRange(_tnaught(djm), 24.0);
  final gst = lst + lng / 15;
  final utc = toRange(gst - t0, 24.0) * sidRate;
  callback(utc, utc < ambigDelta);
}
