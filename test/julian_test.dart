import 'package:test/test.dart';
import 'package:astropc/timeutils.dart';

const cases = [
  {'year': 1984, 'month': 8, 'day': 29.0, 'djd': 30921.5},
  {'year': 1899, 'month': 12, 'day': 31.5, 'djd': 0.0},
  {'year': 1938, 'month': 8, 'day': 17.0, 'djd': 14107.5},
  {'year': 1, 'month': 1, 'day': 1.0, 'djd': -693596.5},
  {'year': -4713, 'month': 7, 'day': 12.0, 'djd': -2414827.5},
  {'year': -4713, 'month': 1, 'day': 1.5, 'djd': -2415020.0}
];

void main() {
  group('Civil --> Julian', () {
    for (var c in cases) {
      test('${c['year']}-${c['month']}-${c['day']}', () {
        var djd =
            julDay(c['year'] as int, c['month'] as int, c['day'] as double);
        expect(djd, closeTo(c['djd']!, 1e-6));
      });
    }
  });

  group('Julian --> Civil', () {
    for (var c in cases) {
      test('${c['djd']}', () {
        final date = calDay(c['djd'] as double);
        expect(date.year, equals(c['year']));
        expect(date.month, equals(c['month']));
        expect(date.day, closeTo(c['day']!, 1e-6));
      });
    }
  });

  group('Special case', () {
    test('Zero date (Jan 0.5, 1900)', () {
      expect(julDay(1900, 1, 0.5), closeTo(0.0, 1e-6));
    });
  });

  group('Exceptions', () {
    test('Zero year', () {
      expect(() => julDay(0, 12, 1), throwsA(TypeMatcher<CalendarException>()));
    });
    test('Impossible date 1582 Oct 10', () {
      expect(() => julDay(1582, 10, 10),
          throwsA(TypeMatcher<CalendarException>()));
    });
  });

  group('DJD at midnight', () {
    test('Before noon', () {
      expect(djdMidnight(23772.99), closeTo(23772.5, 0.5));
    });
    test('After noon', () {
      expect(djdMidnight(23773.3), closeTo(23772.5, 0.5));
    });
    test('Previous day, before midnight', () {
      expect(djdMidnight(23772.4), closeTo(23771.5, 0.5));
    });
    test('Previous day, before noon', () {
      expect(djdMidnight(23771.9), closeTo(23771.5, 0.5));
    });
    test('Next day, after midnight', () {
      expect(djdMidnight(23773.6), closeTo(23773.5, 0.5));
    });
  });

  test('DJD Zero', () {
    expect(djdZero(2010), closeTo(40176.5, 0.5));
  });

  group('Weekdays', () {
    const cases = [
      [30921.5, 3],
      [0.0, 0],
      [14107.5, 3],
      [-693596.5, 6],

      // Not sure about weekDays of the next two dates; there are controverses;
      // Perl  DateTime module gives weekDays 5 and 4 respectively
      [-2414827.5, 5],
      [-2415020.0, 1],
      [23772.99, 1],
    ];

    for (var c in cases) {
      test('${c[0]} should be weekday ${c[1]}', () {
        expect(weekDay(c[0] as double), equals(c[1]));
      });
    }
  });

  group('Leap year', () {
    const leap = [
      2000,
      2004,
      2008,
      2012,
      2016,
      2020,
      2024,
      2028,
      2032,
      2036,
      2040,
      2044,
      2048
    ];

    for (var y in leap) {
      test('$y should be leap year', () {
        expect(isLeapYear(y), isTrue);
      });
    }

    const noleap = [
      2001,
      2003,
      2010,
      2014,
      2017,
      2019,
      2025,
      2026,
      2035,
      2038,
      2045,
      2047,
      2049
    ];
    for (var y in noleap) {
      test('$y should not be leap year', () {
        expect(isLeapYear(y), isFalse);
      });
    }
  });

  group('Day of year', () {
    final n1 = dayOfYear(1990, 4, 1);
    final n2 = dayOfYear(2000, 4, 1);

    test('Non-leap year', () {
      expect(n1, equals(91));
    });

    test('Leap year', () {
      expect(n2, equals(92));
    });
  });

  group('DJD to DateTime', () {
    final got = djdToDateTime(23772.990278);
    test('Year', () => expect(got.year, equals(1965)));
    test('Month', () => expect(got.month, equals(2)));
    test('Day', () => expect(got.day, equals(1)));

    test('Hour', () => expect(got.hour, equals(11)));
    test('Minute', () => expect(got.minute, equals(46)));
    test('Second', () => expect(got.second, equals(0)));
    test('Time Zone offset',
        () => expect(got.timeZoneOffset.inMinutes, equals(0)));
  });
}
