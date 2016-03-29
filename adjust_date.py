#!/usr/bin/env python
from email.utils import parsedate_tz, mktime_tz, formatdate
from optparse import OptionParser
from datetime import datetime
from time import mktime
import sys, traceback

parser = OptionParser()
parser.add_option("-d", "--date", dest="date", help="input date", metavar="DATE")
parser.add_option("-s", "--seq", dest="seq", help="input sequence", metavar="SEQ")

(options, args) = parser.parse_args()

if options.date == None:
    print "ERROR you need to suply the --date option"
    sys.exit(1)

dt = datetime.fromtimestamp(float(options.date[1:]))

# Check the date and adjust it
if dt.isoweekday() in range (1, 6):
    # Weekday
    if dt.hour in range (1, 18):
        dt = dt.replace(hour=18)

new_time = mktime(dt.timetuple())
date = formatdate(new_time, True)

print date

