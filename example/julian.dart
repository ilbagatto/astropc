import 'dart:io';
import 'package:args/args.dart';
import 'package:astropc/timeutils.dart';

String getUsage(parser) {
  return '''
Julian Date Calculator

julian [OPTIONS] [DATETIME] 

OPTIONS

${parser.usage}

DATETIME format is a subset of ISO 8601 which includes the subset accepted by 
RFC 3339, e.g.:

"2012-02-27 13:27:00"
"2012-02-27T13:27:00"         same as the above
"2012-02-27"                  midnight
"2012-02-27T13:27:00Z"        UTC+0
"2002-02-27T14:00:00-0500"    UTC-5h time zone
"2002-02-27T14:00:00 -05:00"  same as the above
"-123450101 00:00:00 Z"       in the year -12345.

The date must be in range from 271821-04-20 BC to 275760-09-13 AD
If omitted, current date and time will be used.

Example:
julian --mode=djd "1965-02-01 11:46"

''';
}

DateTime stringsToDateTime(dateStrings) {
  if (dateStrings.length == 0) {
    return DateTime.now();
  } else if (dateStrings.length == 1) {
    return DateTime.parse(dateStrings[0]);
  } else {
    return DateTime.parse(dateStrings.join(' '));
  }
}

void main(List<String> arguments) {
  exitCode = 0;
  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h',
        negatable: false,
        defaultsTo: false,
        help: 'Displays this help information')
    ..addOption('mode',
        abbr: 'm',
        allowed: ['std', 'mjd', 'djd'],
        defaultsTo: 'std',
        help: 'Julian Date type',
        allowedHelp: {
          'std': 'Total number of days elapsed since 4713 BC Jan 1, 12:00',
          'mjd': 'Total number of days elapsed since 1858 AD Nov 17 00:00',
          'djd': 'Total number of days elapsed since 1899 AD Dec 31 12:00',
        });

  try {
    final argResults = parser.parse(arguments);
    if (argResults['help']) {
      print(getUsage(parser));
      exit(exitCode);
    }

    var civil = stringsToDateTime(argResults.rest);
    if (!civil.isUtc) {
      civil = civil.toUtc();
    }
    print('UTC: ${civil.toString()}');

    final hm = civil.hour + (civil.minute + civil.second / 60) / 60;
    final djd = julDay(civil.year, civil.month, civil.day + hm / 24);
    double jd;
    final mode = argResults['mode'];
    switch (mode) {
      case 'std':
        jd = djd + djdToJd;
        break;
      case 'mjd':
        jd = djd + djdToJd - jdToMjd;
        break;
      default:
        jd = djd;
    }

    print('${mode.toUpperCase()}: ${jd.toStringAsFixed(8)}');
  } catch (e) {
    print(e);
    exitCode = 1;
  }
}
