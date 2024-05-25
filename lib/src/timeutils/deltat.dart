/// *Delta T* indicates the difference between *UT* and *TDT* (Terrestrial
/// Dynamic Time), which used to be called *'Ephemeris time'* in the last
/// century. While *UT* is not a uniform time scale (it is occasionally adjusted,
/// due to irregularities in the Earth's rotation), *TDT* is a uniform time scale
/// which is needed as an argument for mathematical theories of celestial
/// movements.
///
/// For a historical range from 1620 to a recent year, we interpolate from a
/// table of observed values. Outside that range we use formulae from
/// *Astronomical Algorithms* by J.Meeus, second edition.
///
/// Formulae for other time periods are based on NASA Technical Publication
/// *"Five Millennium Canon of Solar Eclipses: -1999 to +3000"*. They are valid for
/// any time during the interval 2000 B.C. to 3000 A.D. See NASA Eclipse web site:
/// see http://eclipse.gsfc.nasa.gov/SEcat5/deltatpoly.html.
///
library;

import '../mathutils.dart';
import 'julian.dart';

final _historical = const {
  // From J.Meeus: Astronomical Algorithms: 2 edition
  1620: 121.0,
  1622: 112.0,
  1624: 103.0,
  1626: 95.0,
  1628: 88.0,
  1630: 82.0,
  1632: 77.0,
  1634: 72.0,
  1636: 68.0,
  1638: 63.0,
  1640: 60.0,
  1642: 56.0,
  1644: 53.0,
  1646: 51.0,
  1648: 48.0,
  1650: 46.0,
  1652: 44.0,
  1654: 42.0,
  1656: 40.0,
  1658: 38.0,
  1660: 35.0,
  1662: 33.0,
  1664: 31.0,
  1666: 29.0,
  1668: 26.0,
  1670: 24.0,
  1672: 22.0,
  1674: 20.0,
  1676: 19.0,
  1678: 16.0,
  1680: 14.0,
  1682: 12.0,
  1684: 11.0,
  1686: 10.0,
  1688: 9.0,
  1690: 8.0,
  1692: 7.0,
  1694: 7.0,
  1696: 7.0,
  1698: 7.0,
  1700: 7.0,
  1702: 7.0,
  1704: 8.0,
  1706: 8.0,
  1708: 9.0,
  1710: 9.0,
  1712: 9.0,
  1714: 9.0,
  1716: 9.0,
  1718: 10.0,
  1720: 10.0,
  1722: 10.0,
  1724: 10.0,
  1726: 10.0,
  1728: 10.0,
  1730: 10.0,
  1732: 10.0,
  1734: 11.0,
  1736: 11.0,
  1738: 11.0,
  1740: 11.0,
  1742: 11.0,
  1744: 12.0,
  1746: 12.0,
  1748: 12.0,
  1750: 12.0,
  1752: 13.0,
  1754: 13.0,
  1756: 13.0,
  1758: 14.0,
  1760: 14.0,
  1762: 14.0,
  1764: 14.0,
  1766: 15.0,
  1768: 15.0,
  1770: 15.0,
  1772: 15.0,
  1774: 15.0,
  1776: 16.0,
  1778: 16.0,
  1780: 16.0,
  1782: 16.0,
  1784: 16.0,
  1786: 16.0,
  1788: 16.0,
  1790: 16.0,
  1792: 15.0,
  1794: 15.0,
  1796: 14.0,
  1798: 13.0,
  1800: 13.1,
  1802: 12.5,
  1804: 12.2,
  1806: 12.0,
  1808: 12.0,
  1810: 12.0,
  1812: 12.0,
  1814: 12.0,
  1816: 12.0,
  1818: 11.9,
  1820: 11.6,
  1822: 11.0,
  1824: 10.2,
  1826: 9.2,
  1828: 8.2,
  1830: 7.1,
  1832: 6.2,
  1834: 5.6,
  1836: 5.4,
  1838: 5.3,
  1840: 5.4,
  1842: 5.6,
  1844: 5.9,
  1846: 6.2,
  1848: 6.5,
  1850: 6.8,
  1852: 7.1,
  1854: 7.3,
  1856: 7.5,
  1858: 7.6,
  1860: 7.7,
  1862: 7.3,
  1864: 6.2,
  1866: 5.2,
  1868: 2.7,
  1870: 1.4,
  1872: -1.2,
  1874: -2.8,
  1876: -3.8,
  1878: -4.8,
  1880: -5.5,
  1882: -5.3,
  1884: -5.6,
  1886: -5.7,
  1888: -5.9,
  1890: -6.0,
  1892: -6.3,
  1894: -6.5,
  1896: -6.2,
  1898: -4.7,
  1900: -2.8,
  1902: -0.1,
  1904: 2.6,
  1906: 5.3,
  1908: 7.7,
  1910: 10.4,
  1912: 13.3,
  1914: 16.0,
  1916: 18.2,
  1918: 20.2,
  1920: 21.1,
  1922: 22.4,
  1924: 23.5,
  1926: 23.8,
  1928: 24.3,
  1930: 24.0,
  1932: 23.9,
  1934: 23.9,
  1936: 23.7,
  1938: 24.0,
  1940: 24.3,
  1942: 25.3,
  1944: 26.2,
  1946: 27.3,
  1948: 28.2,
  1950: 29.1,
  1952: 30.0,
  1954: 30.7,
  1956: 31.4,
  1958: 32.2,
  1960: 33.1,
  1962: 34.0,
  1964: 35.0,
  1966: 36.5,
  1968: 38.3,
  1970: 40.2,
  1972: 42.2,
  1974: 44.5,
  1976: 46.5,
  1978: 48.5,
  1980: 50.5,
  1982: 52.2,
  1984: 53.8,
  1986: 54.9,
  1988: 55.8,
  1990: 56.9,
  1992: 58.3,
  1994: 60.0,
  1996: 61.6,
  1998: 63.0,

  // From http://www.staff.science.uu.nl/~gent0113/deltat/deltat_modern.htm
  2000: 63.8,
  2002: 63.3,
  2004: 64.6,
  2006: 64.9,
  2008: 65.5,
  2010: 66.1,
  2012: 68.0,
  2014: 69.0,
  2016: 70.0
};

const ydSince = 1620;
const ydUntil = 2016;

double interpolate(int ye, double djd) {
  if (ye == ydUntil) {
    // the last value in the table, no interpolation
    return _historical[ydUntil]!;
  }

  final y0 = ye % 2 == 0 ? ye : ye - 1;
  final y1 = y0 + 2;
  final d0 = _historical[y0]!;
  final d1 = _historical[y1]!;
  final j0 = djdZero(y0);
  final j1 = djdZero(y1);
  // simple linear interpolation between two values
  return ((djd - j0) * (d1 - d0) / (j1 - j0)) + d0;
}

double predict(int ye) {
  // all other cases
  final t = (ye - 2000) / 100.0;
  // before 948
  if (ye < 948) {
    return polynome(t, [2177.0, 497.0, 44.1]);
  } else {
    // 948 - 1620 and after 2010
    var result = polynome(t, [102.0, 102.0, 25.3]);
    // correction for 2000-2100 [Meeus-1998: pg 78]
    if (ye > 2010 && ye < 2100) {
      result += 0.37 * (ye - 2100);
    }
    return result;
  }
}

/// Approximate Delta-T in seconds for a given [djd], number of Julian days
/// elapsed since 1900, Jan 0.5.
/// `Delta-T = ET - UT`.
/// StateError indicates an error in tabular data or the algorythm.
double deltaT(double djd) {
  final date = calDay(djd);

  if (date.year >= ydSince && date.year <= ydUntil) {
    return interpolate(date.year, djd);
  }
  return predict(date.year);
}
