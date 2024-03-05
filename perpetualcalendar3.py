#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Naam: perpetualcalendar3.py
# Auteur: Rob Toscani
# Datum: 07-02-2024
# Toelichting:
"""Eeuwigdurende kalender - Zowel Gregoriaanse als Juliaanse kalender"""
# Geijkt op https://en.wikipedia.org/wiki/Perpetual_calendar
# https://en.wikipedia.org/wiki/Perpetual_calendar#/media/File:Permanent_Calendar_gregorian.png
# https://nl.wikipedia.org/wiki/Bestand:Ewiger_Julianischer_Kalender.png
#
# Geeft de weekdag voor de opgegeven datum in zowel de Gregoriaanse als Juliaanse kalender.
# Bij Juliaans geldt dat elk door 4 deelbaar jaar een schrikkeljaar is.
#
# De Juliaanse kalender begint op zaterdag 1 jan 01, zie:
# https://nl.wikipedia.org/wiki/Bestand:Ewiger_Julianischer_Kalender.png
# Naar 1 jan 0 (begin Chr. jaartelling) terug-extrapoleren valt die datum (eigenlijk 1 jan 1 voor Chr.
# want de 0 kende men toen nog niet) bij Juliaans op een donderdag.
# Bij Gregoriaans geldt voor 1 jan 0 echter de zaterdag (!), zie:
# https://en.wikipedia.org/wiki/Perpetual_calendar#/media/File:Permanent_Calendar_gregorian.png
# Stelling RJT: Juliaans loopt op dat moment (initieel) dus 2 dagen voor, ofwel op 1 jan 0 Gregoriaans
# (virtueel, op zaterdag) is het reeds 3 jan 0 Juliaans (1 jan 0 was het daar op donderdag al geweest).
# Dit klopt met de sprong die is uitgevoerd bij invoering van de Gregoriaanse kalender in 1582:
# Op do 4 okt Juliaans volgt vri 15 okt Gregoriaans, dus 5 okt wordt 15 okt ofwel een correctie van 10
# dagen. Dit komt overeen met het 2 dagen voorlopen minus de 12 extra schrikkeldagen bij de eeuwjaren
# niet deelbaar door 400 t/m 1500 bij Juliaans t.o.v. Gregoriaans.
#
# Super-efficiënte versie: O(1)
#
######################################################################################
#
# Copyright (C) 2024 Rob Toscani <rob_toscani@yahoo.com>
#
# perpetualcalendar3.py is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# perpetualcalendar3.py is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
######################################################################################

import sys
import time

day       = int(sys.argv[1])            # Must be integer > 0
month     = int(sys.argv[2])            # Must be integer > 0
year      = int(sys.argv[3])            # Must be integer >= 0

months   = { 1:"January",2:"February",3:"March",4:"April",5:"May",6:"June",7:"July",8:"August",9:"September",10:"October",11:"November",12:"December" }
lengths  = { 1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31 }
weekdays = { 0:"Friday", 1:"Saturday", 2:"Sunday", 3:"Monday", 4:"Tuesday", 5:"Wednesday", 6:"Thursday" }


def is_leap(year, calendar):
    if (calendar == "Gregorian" and (year % 400 == 0 or ( year % 4 == 0 and year % 100 != 0 ))) or \
       (calendar == "Julian" and year % 4 == 0):
        return 1             # Leap year
    else:
        return 0             # No leap year


def recalculate_date(fullcycle_years, remainderdays, calendar):
    y = fullcycle_years
    remainderyear = 0
    while True:
        leap = is_leap(remainderyear, calendar)
        yearlength = 365 + leap
        if remainderdays > yearlength:
            remainderdays -= yearlength
            y += 1
        else:
            break
        remainderyear += 1
    if remainderdays == 0:
        m = 12
        d = 31
        y -= 1
    else:
        for m in range(1, 12+1):
            if m == 2:
                monthlength = 28 + leap
            else:
                monthlength = lengths[m]
            if remainderdays > monthlength:
                remainderdays -= monthlength
            elif remainderdays == 0:
                m -= 1
                d = lengths[m]
                break
            else:
                d = remainderdays
                break
    return (d, m, y)


calendar = ["Gregorian", "Julian"]
for i in (0, 1):

# Raise number of days in February if year in question is a leap year:
    lengths[2] = 28 + is_leap(year, calendar[i])     # leap year

    # Verify if date is legal:
    if year < 0 or month > 12 or month < 1 or day > lengths[month] or day < 1:
        print("Date not legal")
        sys.exit()

    # Calculate number of days in year in question including date:
    days_thisyear = sum([ lengths[mon] for mon in range(1, month) ]) + day

    # Calculate number of days before year in question, from/incl. Saturday Jan 1 of year 0 (a leap year):
    if calendar[i] == "Gregorian":
        days_previousyears = year * 365 + (year + 3) // 4  - (year + 99) // 100 + (year + 399) // 400

        # Re-calculate the date from Gregeorian to Julian calendar:
        days_total = days_previousyears + days_thisyear + 2   # Jan. 1 of Year 0 is 2 days earlier in Julian
        fullcycle_days = 366 + 3 * 365
        fullcycle_years = (days_total // fullcycle_days) * 4

    else: # if calendar = "Julian"
        days_previousyears = year * 365 + (year + 3) // 4

        # Re-calculate the date from Julian to Gregeorian calendar:
        days_total = days_previousyears + days_thisyear - 2   # Jan. 1 of Year 0 is 2 days later in Gregorian
        fullcycle_days = (1 + 4 * 24) * 366 + (400 - 1 - 4 * 24) * 365
        fullcycle_years = (days_total // fullcycle_days) * 400

    remainderdays = days_total % fullcycle_days
    recalculated = recalculate_date(fullcycle_years, remainderdays, calendar[(i+1)%2])

#   print(fullcycle_years, remainderdays, calendar[(i+1)%2])
#   print(recalculated)

    # Determine day number in the week:
    weekday = days_thisyear + days_previousyears - i * 2
    # Gregorian 1 Jan 0 is on a Saturday, the same date in Julian is 2 days earlier on a Thursday.


    date_now = int(time.strftime("%Y%m%d"))
    if calendar[i] == "Gregorian":
        date_gregor = year * 10000 + month * 100 + day
    else:
        date_gregor = recalculated[2] * 10000 + recalculated[1] * 100 + recalculated[0]

    # Determine past, present or future tense:
    if date_gregor < date_now:
        fall = "fell"
        be = "was"
    elif date_gregor == date_now:
        fall = "is TODAY, falls"
        be = "is"
    else:
        fall = "will fall"
        be = "will be"

    # Determine whether or not the year is a leap year:
    if is_leap(year, calendar[i]):
        leapstring = str(year) + " is a " + calendar[i] + " leap year."
    else:
        leapstring = str(year) + " is not a " + calendar[i] + " leap year."

    print("\n%-10s: %-2d %s %d =" % (calendar[i], day, months[month], year))
    print("%-10s: %-2d %s %d" % (calendar[(i+1)%2], recalculated[0], months[recalculated[1]], recalculated[2]))
    print("It %s on a %s,\nand %s day nr: %d" % (fall, weekdays[weekday % 7], be, days_thisyear + days_previousyears))
    print("as counted from January 1 of Year 0\non the %s calendar." % (calendar[i]))
    print(leapstring)

print()
