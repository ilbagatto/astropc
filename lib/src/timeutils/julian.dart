/// # Julian Date
///
/// The main purpose is to convert between civil and Julian dates.
/// *Julian date* (JD) is the number of days elapsed since mean UT noon of
/// January 1st 4713 BC. This system of time measurement is widely adopted by
/// the astronomers.
library;

/// For better precision around the XX century, we use
/// the epoch **1900 January 0.5 (1989 December 31.5)** as the starting point.
/// See _"Astronomy With Your Personal Computer"_, p.14. This kind of Julian
/// date is referred as 'DJD'. To convert DJD to JD and vise versa, use
/// [djdToJd] constant: `jd = djd + DJD_TO_JD`

// The module contains some other usefull calendar-related functions, such as
/// [weekDay], [dayOfYear], [isLeapYear].

/// ## Civil vs. Astronomical year

/// There is disagreement between astronomers and historians about how to count
/// the years preceding the year 1. Astronomers generally use zero-based system.
/// The year before the year +1, is the *year zero*, and the year preceding the
/// latter is the *year -1*. The year which the historians call 585 B.C. is
/// actually the year -584.

/// In this module all subroutines accepting year ([isLeapYear], [cal2djd] etc.)
/// assume that **there is no year zero**. Conversion from the civil to the
/// astronomical time scale is done internally. Thus, the sequence of years is:
/// `BC -3, -2, -1, 1, 2, 3, AD`.
///
/// ## Time
///
/// Time is represented by fractional part of a day. For example, 7h30m UT
/// is `(7 + 30 / 60) / 24 = 0.3125`.
///
/// ## Zero day
///
/// Zero day is a special case of date: it indicates 12h UT of previous calendar
/// date. For instance, *1900 January 0.5* is often used instead of
/// *1899 December 31.5* to designate start of the astronomical epoch.
///
/// ##  Gregorian calendar
///
/// _Civil calendar_ in most cases means _proleptic Gregorian calendar_. it is
/// assumed that Gregorian calendar started at *Oct. 4, 1582*, when it was first
/// adopted in several European countries. Many other countries still used the
/// older Julian calendar. In Soviet Russia, for instance, Gregorian system was
/// accepted on **Jan 26, 1918**. See
/// [Wiki article](https://en.wikipedia.org/wiki/Gregorian_calendar#Adoption_of_the_Gregorian_Calendar)

import '../mathutils.dart';

/// Year when Gregorian calendar was introduced
const gregorianYear = 1582;

const djdToJd = 2415020;
const jdToMjd = 2400000.5;
const daysPerCent = 36525;

class CalendarException implements Exception {
  final String message;
  const CalendarException(this.message);
  String errMsg() => message;
}

/// Does a given date falls to period after introducion of Gregorian calendar?
bool afterGregorian(int y, int m, int d) {
  if (y < gregorianYear) return false;
  if (y > gregorianYear) return true;
  if (m < 10) return false;
  if (m > 10) return true;
  return d >= 15;
}

///
/// Converts calendar date into Julian days elapsed since **1900, Jan 0.5**
/// (1899 Dec 31.5).
///
/// Calendar date is expressed as:
/// [ye] - civil year
/// [mo] - month (1 - 12)
/// [da] day, with hours as fractional part
///
/// Throws [CalendarException] if [ye] is zero (astronomical years are not
/// allowed) or if input date is between **5th** and **14 October 1582**,
/// inclusive.
///
double julDay(int ye, int mo, double da) {
  if (ye == 0) {
    throw CalendarException('Zero year not allowed!');
  }

  final d = da.truncate();
  if (ye == gregorianYear && mo == 10) {
    if (d > 4 && d < 15) {
      throw CalendarException('Impossible date: $ye-$mo-$da');
    }
  }
  var y = ye < 0 ? ye + 1 : ye;
  var m = mo;
  if (mo < 3) {
    m += 12;
    y--;
  }

  int b;
  if (afterGregorian(ye, mo, d)) {
    // after Gregorian calendar
    final a = (y / 100).truncate();
    b = 2 - a + (a / 4).truncate();
  } else {
    b = 0;
  }

  final f = 365.25 * y;
  final c = (y < 0 ? f - 0.75 : f).truncate() - 694025;
  final e = (30.6001 * (m + 1)).truncate();

  return b + c + e + da - 0.5;
}

/// Converts [djd], number of Julian days since **1900 Jan. 0.5** into the
/// calendar date.
({int year, int month, double day}) calDay(double djd) {
  final d = djd + 0.5;
  final fi = modf(d);
  final f = fi.$1;
  var i = fi.$2;

  if (i > -115860) {
    final a = (i / 36524.25 + 9.9835726e-1).floor() + 14;
    i += 1 + a - (a / 4).floor();
  }
  final b = (i / 365.25 + 8.02601e-1).floor();
  final c = i - (365.25 * b + 7.50001e-1).floor() + 416;
  final g = (c / 30.6001).floor();
  final da = c - (30.6001 * g).floor() + f;
  final mo = g - (g > 13.5 ? 13 : 1);
  var ye = b + (mo < 2.5 ? 1900 : 1899);
  // convert astronomical, zero-based year to civil
  if (ye < 1) {
    ye--;
  }
  return (year: ye, month: mo, day: da);
}

/// DJD at Greenwich midnight.
/// Given [djd], a number of Julian days elapsed since 1900, Jan 0.5,
/// return DJD at Greenwich midnight
double djdMidnight(double djd) {
  final f = djd.floor();
  return f + ((djd - f).abs() >= 0.5 ? 0.5 : -0.5);
}

/// Day of week.
/// Given [djd], a number of Julian days elapsed since 1900, Jan 0.5,
/// return number in range (0..6) corresponding to weekDay:
/// `0` for Sunday, `1` for Monday and so on.
int weekDay(double djd) {
  final d0 = djdMidnight(djd);
  final j0 = d0 + djdToJd;
  return ((j0 + 1.5) % 7).truncate();
}

/// Is given year [ye] a leap-year?
bool isLeapYear(int ye) {
  return (ye % 4 == 0) && ((ye % 100 != 0) || (ye % 400 == 0));
}

/// Number of days in the year up to a particular date.
/// [ye] is the civil year, [mo] is the month (1-12), [da] is h day (1-31)
int dayOfYear(int ye, int mo, int da) {
  final k = isLeapYear(ye) ? 1 : 2;
  final a = (275 * mo / 9).floor();
  final b = (k * ((mo + 9) / 12.0)).floor();
  final c = da.floor();
  return a - b + c - 30;
}

// DJD corresponding to January 0.0 of a given year.
//
// Zero day is a special case of date: it indicates 12h UT of previous calendar
// date. For instance, *1900 January 0.5* is often used instead of
// *1899 December 31.5* to designate start of the astronomical epoch.
double djdZero(int year) {
  final y = year - 1;
  final a = (y / 100).truncateToDouble();
  return (365.25 * y).truncateToDouble() -
      a +
      (a / 4).truncateToDouble() -
      693595.5;
}
