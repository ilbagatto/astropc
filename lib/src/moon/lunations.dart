library;

import 'dart:math';
import 'package:vector_math/vector_math.dart';

import '../mathutils.dart';
import '../timeutils/julian.dart';

/// Quarter types
enum QuarterType { newMoon, firstQuarter, fullMoon, lastQuarter }

/// Base class for calculating corrections necessary for determining time
/// of lunations.
abstract class DeltaCalculator {
  final double t;
  final double ms;
  final double mm;
  final double f;

  double? tms;
  double? tmm;
  double? tf;

  /// Constructor.
  /// [t] is time in centuries since epoch 1900.0.
  /// [ms] and [mm] are mean anomalies of the Sun and the Moon. [f] is Moon's
  /// argument of latitude.
  DeltaCalculator(this.t, this.ms, this.mm, this.f) {
    tms = ms + ms;
    tmm = mm + mm;
    tf = f + f;
  }

  double calculate();
}

/// Calculates delta for New and Full Moon.
class NFDelta extends DeltaCalculator {
  NFDelta(super.t, super.ms, super.mm, super.f);

  @override
  double calculate() {
    return (1.734e-1 - 3.93e-4 * t) * sin(ms) +
        2.1e-3 * sin(tms!) -
        4.068e-1 * sin(mm) +
        1.61e-2 * sin(tmm!) -
        4e-4 * sin(mm + tmm!) +
        1.04e-2 * sin(tf!) -
        5.1e-3 * sin(ms + mm) -
        7.4e-3 * sin(ms - mm) +
        4e-4 * sin(tf! + ms) -
        4e-4 * sin(tf! - ms) -
        6e-4 * sin(tf! + mm) +
        1e-3 * sin(tf! - mm) +
        5e-4 * sin(ms + tmm!);
  }
}

/// Calculates delta for First ans Last quarters.
class FLDelta extends DeltaCalculator {
  FLDelta(super.t, super.ms, super.mm, super.f);

  @override
  double calculate() {
    return (0.1721 - 0.0004 * t) * sin(ms) +
        0.0021 * sin(tms!) -
        0.6280 * sin(mm) +
        0.0089 * sin(tmm!) -
        0.0004 * sin(tmm! + mm) +
        0.0079 * sin(tf!) -
        0.0119 * sin(ms + mm) -
        0.0047 * sin(ms - mm) +
        0.0003 * sin(tf! + ms) -
        0.0004 * sin(tf! - ms) -
        0.0006 * sin(tf! + mm) +
        0.0021 * sin(tf! - mm) +
        0.0003 * sin(ms + tmm!) +
        0.0004 * sin(ms - tmm!) -
        0.0003 * sin(tms! + mm);
  }
}

/// Base class for Lunar Quarters
abstract class Quarter {
  final QuarterType _type;
  final String _name;
  final double _coeff;

  static final Map<QuarterType, Quarter> _cache = <QuarterType, Quarter>{};

  const Quarter._create(this._type, this._name, this._coeff);

  /// Factory constructor. Each Phase is created only once, as a Singletone.
  factory Quarter(QuarterType type) {
    if (_cache.containsKey(type)) {
      return _cache[type]!;
    }

    Quarter q;
    switch (type) {
      case QuarterType.newMoon:
        q = NewMoon();
        break;
      case QuarterType.firstQuarter:
        q = FirstQuarter();
        break;
      case QuarterType.fullMoon:
        q = FullMoon();
        break;
      case QuarterType.lastQuarter:
        q = LastQuarter();
    }
    _cache[type] = q;
    return q;
  }

  // Name
  String get name => _name;
  // Coefficient
  double get coeff => _coeff;
  // Type (unique identifier)
  QuarterType get type => _type;

  @override
  String toString() {
    return _name;
  }
}

/// New Moon
class NewMoon extends Quarter {
  const NewMoon() : super._create(QuarterType.newMoon, 'New Moon', 0.0);
}

/// First Quarter
class FirstQuarter extends Quarter {
  const FirstQuarter()
      : super._create(QuarterType.firstQuarter, 'First Quarter', 0.25);
}

/// Full Moon
class FullMoon extends Quarter {
  const FullMoon() : super._create(QuarterType.fullMoon, 'Full Moon', 0.5);
}

/// Last Quarter
class LastQuarter extends Quarter {
  const LastQuarter()
      : super._create(QuarterType.lastQuarter, 'Last Quarter', 0.75);
}

/// Determines time of closest phase of a given type.
class QuarterQuery {
  final Quarter _quarter;

  /// Constructor.
  const QuarterQuery(this._quarter);

  double _calculateDelta(double t, double ms, double mm, double f) {
    if (_quarter.type == QuarterType.newMoon ||
        _quarter.type == QuarterType.fullMoon) {
      return NFDelta(t, ms, mm, f).calculate();
    }

    final delta = FLDelta(t, ms, mm, f).calculate();
    var w = 0.0028 - 0.0004 * cos(ms) + 0.0003 * cos(ms);
    if (_quarter.type == QuarterType.lastQuarter) {
      w = -w;
    }
    return delta + w;
  }

  /// Find DJD of a quarter, closest to [ye], year, [mo], month and [da], date.
  double findClosest(int ye, int mo, int da) {
    final n = isLeapYear(ye) ? 366 : 365;
    final y = ye + dayOfYear(ye, mo, da) / n;
    final k = ((y - 1900) * 12.3685).round() + _quarter.coeff;
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

    return j + _calculateDelta(t, ms, mm, f);
  }
}
