/// Calculates obliquity of the ecliptic.
/// Source: P.Duffett-Smith, "Astronomy with Your PC", 2 edition.

library;

/// Given [djd], number of Julian days since 1900 Jan. 0.5.,
/// and optional [deps], nutation in ecliptic obliquity in degrees,
/// calculate **obliquity of ecliptic** in degrees.
/// Without the second argument, return mean obliquity.
double obliquity(double djd, {deps = 0.0}) {
  final t = djd / 36525.0;
  final c = (((-0.00181 * t) + 0.0059) * t + 46.845) * t;
  return 23.45229444 - (c / 3600) + deps;
}
