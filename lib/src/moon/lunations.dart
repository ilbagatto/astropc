import 'dart:math';

import 'package:vector_math/vector_math.dart';

import '../../mathutils.dart';
import '../../timeutils.dart';

/// Quarter types
enum Quarter {
  newMoon("New Moon", 0.0),
  firstQuarter("First Quarter", 0.25),
  fullMoon("Full Moon", 0.5),
  lastQuarter("Last Quarter", 0.75);

  const Quarter(this.title, this.coeff);

  final String title;
  final double coeff;
}

double calculateDelta(Quarter quarter, double t, ms, mm, f) {
  final tms = ms + ms;
  final tmm = mm + mm;
  final tf = f + f;
  double delta;

  switch (quarter) {
    case Quarter.newMoon:
    case Quarter.fullMoon:
      delta = (1.734e-1 - 3.93e-4 * t) * sin(ms) +
          2.1e-3 * sin(tms) -
          4.068e-1 * sin(mm) +
          1.61e-2 * sin(tmm) -
          4e-4 * sin(mm + tmm) +
          1.04e-2 * sin(tf) -
          5.1e-3 * sin(ms + mm) -
          7.4e-3 * sin(ms - mm) +
          4e-4 * sin(tf + ms) -
          4e-4 * sin(tf - ms) -
          6e-4 * sin(tf + mm) +
          1e-3 * sin(tf - mm) +
          5e-4 * sin(ms + tmm);
    default:
      delta = (0.1721 - 0.0004 * t) * sin(ms) +
          0.0021 * sin(tms) -
          0.6280 * sin(mm) +
          0.0089 * sin(tmm) -
          0.0004 * sin(tmm + mm) +
          0.0079 * sin(tf) -
          0.0119 * sin(ms + mm) -
          0.0047 * sin(ms - mm) +
          0.0003 * sin(tf + ms) -
          0.0004 * sin(tf - ms) -
          0.0006 * sin(tf + mm) +
          0.0021 * sin(tf - mm) +
          0.0003 * sin(ms + tmm) +
          0.0004 * sin(ms - tmm) -
          0.0003 * sin(tms + mm);
      double w = 0.0028 - 0.0004 * cos(ms) + 0.0003 * cos(ms);
      if (quarter == Quarter.lastQuarter) {
        w = -w;
      }
      delta += w;
  }
  return delta;
}

/// Find DJD of a quarter, closest to [ye], year, [mo], month and [da], day.
double findClosestPhase(Quarter quarter, int ye, mo, da) {
  final n = isLeapYear(ye) ? 366 : 365;
  final y = ye + dayOfYear(ye, mo, da) / n;
  final k = ((y - 1900) * 12.3685).round() + quarter.coeff;
  final t = k / 1236.85;
  final t2 = t * t;
  final t3 = t2 * t;

  final c = radians(166.56 + (132.87 - 9.173e-3 * t) * t);
  final j = 0.75933 +
      29.53058868 * k +
      0.0001178 * t2 -
      1.55e-07 * t3 +
      3.3e-4 * sin(c); // mean lunar phase

  assemble(List<double> args) =>
      radians(reduceDeg(args[0] + args[1] * k + args[2] * t2 + args[3] * t3));

  final ms = assemble([359.2242, 29.105356080, -0.0000333, -0.00000347]);
  final mm = assemble([306.0253, 385.81691806, 0.0107306, 0.00001236]);
  final f = assemble([21.2964, 390.67050646, -0.0016528, -0.00000239]);

  return j + calculateDelta(quarter, t, ms, mm, f);
}
