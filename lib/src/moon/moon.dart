/// True geocentric ecliptic longitude, latitude and horizontal parallax of the
/// Moon at a given instant with expected accuracies of about
/// **10**, **3**, and **0.2** arcseconds respectively.

library;

import 'dart:math';
import 'package:vector_math/vector_math.dart';
import '../mathutils.dart';
import '../misc/nutation.dart';
import '../timeutils/julian.dart';

/// Moon Position, parallax and daily motion.
typedef MoonPosition = ({
  /// celestial longitude, degrees
  double lambda,

  /// celestial latitude, degrees
  double beta,

  /// distance from Earth, A.U.
  double delta,

  /// horizontal parallax
  double parallax,

  /// angular speed, degrees / 24h
  double motion
});

/// @nodoc
const _m = [
  27.32158213,
  365.2596407,
  27.55455094,
  29.53058868,
  27.21222039,
  6798.363307
];

/// @nodoc
const moonOrbit = {
  // Mean longitude
  'L': [
    218.3164477,
    481267.88123421,
    -0.0015786,
    1.0 / 538841,
    -(1.0 / 65194000)
  ],
  // Mean elongation
  'D': [
    297.8501921,
    445267.1114034,
    -0.0018819,
    1.0 / 545868,
    -(1.0 / 113065000)
  ],
  // Mean anomaly
  'M': [134.9633964, 477198.8675055, 0.0087414, 1.0 / 69699, -(1.0 / 14712000)],
  // Argument of latitude (mean distance of the Moon from its ascending node)
  'F': [
    93.272095,
    483202.0175233,
    -0.0036539,
    -(1.0 / 3526000),
    1.0 / 863310000
  ],
};

/// @nodoc
const sunOrbit = {
  // Mean anomaly
  'M': [357.5291092, 35999.0502909, -0.0001536, 1.0 / 24490000]
};

/// Mean Lunar Node.
/// [t] is a number of Julian centuries elapsed since 1900, Jan 0.5.
/// Return longitude in degrees
double meanNode(double t) => reduceDeg(polynome(
    t, [125.0445479, -1934.1362891, 0.0020754, 1.0 / 467441, 1.0 / 60616000]));

/// True position of the Moon.
///
/// Given [djd], number of Julian days since 1900 Jan. 0.5.,
/// return a [MoonPosition] record.
/// All the above are passed as arguments to the [callback] function
MoonPosition truePosition(double djd) {
  final t = djd / 36525;
  final t2 = t * t;
  final m = _m.map((x) => 360 * frac(djd / x)).toList();

  var ld =
      270.434164 + m[0] - (1.133E-3 - 1.9E-6 * t) * t2; // Moon's mean longitude
  var ms =
      358.475833 + m[1] - (1.5E-4 + 3.3E-6 * t) * t2; // mean anomaly of the Sun
  var md = 296.104608 + m[2] + (9.192E-3 + 1.44E-5 * t) * t2; // mean anomaly
  var de = 350.737486 + m[3] - (1.436E-3 - 1.9E-6 * t) * t2; // mean elongation
  var f = 11.250889 +
      m[4] -
      (3.211E-3 + 3E-7 * t) *
          t2; // mean distance of Moon from its ascending node
  var n = 259.183275 -
      m[5] +
      (2.078E-3 + 2.2E-5 * t) * t2; // longitude of Moon's asc. node
  final a = radians(51.2 + 20.2 * t);
  final sa = sin(a);
  final sn = sin(radians(n));
  final b = 346.56 + (132.87 - 9.1731E-3 * t) * t;
  final sb = 3.964E-3 * sin(radians(b));
  final c = radians(n + 275.05 - 2.3 * t);
  final sc = sin(c);
  ld += 2.33E-4 * sa + sb + 1.964E-3 * sn;
  ms -= 1.778E-3 * sa;
  md += 8.17E-4 * sa + sb + 2.541E-3 * sn;
  f += sb - 2.4691E-2 * sn - 4.328E-3 * sc;
  de += 2.011E-3 * sa + sb + 1.964E-3 * sn;
  final e = 1 - (2.495E-3 + 7.52E-6 * t) * t;
  final e2 = e * e;
  ms = radians(ms);
  n = radians(n);
  de = radians(de);
  f = radians(f);
  md = radians(md);

  final de2 = de + de;
  final de3 = de2 + de;
  final de4 = de2 + de2;
  final md2 = md + md;
  final md3 = md2 + md;
  final ms2 = ms + ms;
  final f2 = f + f;
  final f3 = f2 + f;
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // ecliptic longitude
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  final l = 6.28875 * sin(md) + // the first term of the equation of the centre
      1.274018 * sin(de2 - md) + // evection
      6.58309E-1 * sin(de2) +
      2.13616E-1 * sin(md2) -
      e * 1.85596E-1 * sin(ms) -
      1.14336E-1 * sin(f2) +
      5.8793E-2 * sin(2 * (de - md)) +
      5.7212E-2 * e * sin(de2 - ms - md) +
      5.332E-2 * sin(de2 + md) +
      4.5874E-2 * e * sin(de2 - ms) +
      4.1024E-2 * e * sin(md - ms) -
      3.4718E-2 * sin(de) -
      e * 3.0465E-2 * sin(ms + md) +
      1.5326E-2 * sin(2 * (de - f)) -
      1.2528E-2 * sin(f2 + md) -
      1.098E-2 * sin(f2 - md) +
      1.0674E-2 * sin(de4 - md) +
      1.0034E-2 * sin(md3) +
      8.548E-3 * sin(de4 - md2) -
      e * 7.91E-3 * sin(ms - md + de2) -
      e * 6.783E-3 * sin(de2 + ms) +
      5.162E-3 * sin(md - de) +
      e * 5E-3 * sin(ms + de) +
      3.862E-3 * sin(de4) +
      e * 4.049E-3 * sin(md - ms + de2) +
      3.996E-3 * sin(2 * (md + de)) +
      3.665E-3 * sin(de2 - md3) +
      e * 2.695E-3 * sin(md2 - ms) +
      2.602E-3 * sin(md - 2 * (f + de)) +
      e * 2.396E-3 * sin(2 * (de - md) - ms) -
      2.349E-3 * sin(md + de) +
      e2 * 2.249E-3 * sin(2 * (de - ms)) -
      e * 2.125E-3 * sin(md2 + ms) -
      e2 * 2.079E-3 * sin(ms2) +
      e2 * 2.059E-3 * sin(2 * (de - ms) - md) -
      1.773E-3 * sin(md + 2 * (de - f)) -
      1.595E-3 * sin(2 * (f + de)) +
      e * 1.22E-3 * sin(de4 - ms - md) -
      1.11E-3 * sin(2 * (md + f)) +
      8.92E-4 * sin(md - de3) -
      e * 8.11E-4 * sin(ms + md + de2) +
      e * 7.61E-4 * sin(de4 - ms - md2) +
      e2 * 7.04E-4 * sin(md - 2 * (ms + de)) +
      e * 6.93E-4 * sin(ms - 2 * (md - de)) +
      e * 5.98E-4 * sin(2 * (de - f) - ms) +
      5.5E-4 * sin(md + de4) +
      5.38E-4 * sin(4 * md) +
      e * 5.21E-4 * sin(de4 - ms) +
      4.86E-4 * sin(md2 - de) +
      e2 * 7.17E-4 * sin(md - ms2);

  final lambda = reduceDeg(ld + l);

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // ecliptic latitude
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  final g = 5.128189 * sin(f) +
      .280606 * sin(md + f) +
      .277693 * sin(md - f) +
      .173238 * sin(de2 - f) +
      .055413 * sin(de2 + f - md) +
      .046272 * sin(de2 - f - md) +
      .032573 * sin(de2 + f) +
      .017198 * sin(md2 + f) +
      .009267 * sin(de2 + md - f) +
      .008823 * sin(md2 - f) +
      e * .008247 * sin(de2 - ms - f) +
      .004323 * sin(2 * (de - md) - f) +
      .0042 * sin(de2 + f + md) +
      e * .003372 * sin(f - ms - de2) +
      e * .002472 * sin(de2 + f - ms - md) +
      e * .002222 * sin(de2 + f - ms) +
      e * .002072 * sin(de2 - f - ms - md) +
      e * .001877 * sin(f - ms + md) +
      .001828 * sin(de4 - f - md) -
      e * .001803 * sin(f + ms) -
      .00175 * sin(f3) +
      e * .00157 * sin(md - ms - f) -
      .001487 * sin(f + de) -
      e * .001481 * sin(f + ms + md) +
      e * .001417 * sin(f - ms - md) +
      e * .00135 * sin(f - ms) +
      .00133 * sin(f - de) +
      .001106 * sin(f + md3) +
      .00102 * sin(de4 - f) +
      .000833 * sin(f + de4 - md) +
      .000781 * sin(md - f3) +
      .00067 * sin(f + de4 - md2) +
      .000606 * sin(de2 - f3) +
      .000597 * sin(2 * (de + md) - f) +
      e * .000492 * sin(de2 + md - ms - f) +
      .00045 * sin(2 * (md - de) - f) +
      .000439 * sin(md3 - f) +
      .000423 * sin(f + 2 * (de + md)) +
      .000422 * sin(de2 - f - md3) -
      e * .000367 * sin(ms + f + de2 - md) -
      e * .000353 * sin(ms + f + de2) +
      .000331 * sin(f + de4) +
      e * .000317 * sin(de2 + f - ms + md) +
      e2 * .000306 * sin(2 * (de - ms) - f) -
      .000283 * sin(md + f3);
  final w1 = .0004664 * cos(n);
  final w2 = .0000754 * cos(c);
  final beta = g * (1 - w1 - w2);

  // horizontal parallax
  final hp = .950724 +
      .051818 * cos(md) +
      .009531 * cos(de2 - md) +
      .007843 * cos(de2) +
      .002824 * cos(md2) +
      .000857 * cos(de2 + md) +
      e * .000533 * cos(de2 - ms) +
      e * .000401 * cos(de2 - md - ms) +
      e * .00032 * cos(md - ms) -
      .000271 * cos(de) -
      e * .000264 * cos(ms + md) -
      .000198 * cos(f2 - md) +
      .000173 * cos(md3) +
      .000167 * cos(de4 - md) -
      e * .000111 * cos(ms) +
      .000103 * cos(de4 - md2) -
      .000084 * cos(md2 - de2) -
      e * .000083 * cos(de2 + ms) +
      .000079 * cos(de2 + md2) +
      .000072 * cos(de4) +
      e * .000064 * cos(de2 - ms + md) -
      e * .000063 * cos(de2 + ms - md) +
      e * .000041 * cos(ms + de) +
      e * .000035 * cos(md2 - ms) -
      .000033 * cos(md3 - de2) -
      .00003 * cos(md + de) -
      .000029 * cos(2 * (f - de)) -
      e * .000029 * cos(md2 + ms) +
      e2 * .000026 * cos(2 * (de - ms)) -
      .000023 * cos(2 * (f - de) + md) +
      e * .000019 * cos(de4 - ms - md);

  // distance from Earth in A.U.
  final delta = 8.794 / (hp * 3600);

  // angular speed
  final dm = 13.176397 +
      1.434006 * cos(md) +
      0.280135 * cos(de2) +
      0.251632 * cos(de2 - md) +
      0.097420 * cos(md2) -
      0.052799 * cos(f2) +
      0.034848 * cos(de2 + md) +
      0.018732 * cos(de2 - ms) +
      0.010316 * cos(de2 - ms - md) +
      0.008649 * cos(ms - md) -
      0.008642 * cos(f2 + md) -
      0.007471 * cos(ms + md) -
      0.007387 * cos(de) +
      0.006864 * cos(md2 + md) +
      0.006650 * cos(de4 - md) +
      0.003523 * cos(de2 + md2) +
      0.003377 * cos(de4 - md2) +
      0.003287 * cos(de4) -
      0.003193 * cos(ms) -
      0.003003 * cos(de2 + ms) +
      0.002577 * cos(md - ms + de2) -
      0.002567 * cos(f2 - md) -
      0.001794 * cos(de2 - md2) -
      0.001716 * cos(md - f2 - de2) -
      0.001698 * cos(de2 + ms - md) -
      0.001415 * cos(de2 + f2) +
      0.001183 * cos(md2 - ms) +
      0.001150 * cos(de + ms) -
      0.001035 * cos(de + md) -
      0.001019 * cos(f2 + md2) -
      0.001006 * cos(ms + md2);

  return (lambda: lambda, beta: beta, delta: delta, parallax: hp, motion: dm);
}

/// Apparent position of the Moon, with respect of nutation,
/// aberration and optionally, light-time travel.
MoonPosition apparent(double djd,
    {double? dpsi, bool ignoreLightTravel = true}) {
  final truePos = truePosition(djd);
  dpsi ??= nutation(djd / daysPerCent).deltaPsi;
  double lambda = truePos.lambda + dpsi; // nutation

  return (
    lambda: lambda,
    beta: truePos.beta,
    delta: truePos.delta,
    parallax: truePos.parallax,
    motion: truePos.motion
  );
}

/// Longitude of Lunar Node, arc-degrees.
/// If [trueNode] is *true*, the result refers to the true equinox of the date.
double lunarNode(double djd, {bool trueNode = true}) {
  final t =
      (djd - 36525) / 36525; // convert DJD to centuries since epoch 2000.0
  final mn = polynome(
      t, [125.0445479, -1934.1362891, 0.0020754, 1.0 / 467441, 1.0 / 60616000]);
  double nd;
  if (trueNode) {
    assemble(terms) => radians(reduceDeg(polynome(t, terms)));
    assembleMoon(k) => assemble(moonOrbit[k]);

    final d = assembleMoon('D');
    final m = assembleMoon('M');
    final f = assembleMoon('F');
    final ms = assemble(sunOrbit['M']);
    nd = mn -
        1.4979 * sin(2 * (d - f)) -
        0.1500 * sin(ms) -
        0.1226 * sin(2 * d) +
        0.1176 * sin(2 * f) -
        0.0801 * sin(2 * (m - f));
  } else {
    nd = mn;
  }

  return reduceDeg(nd);
}
