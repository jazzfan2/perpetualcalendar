#!/bin/bash
# Naam: perpetualcalendar3a.sh
# Auteur: Rob Toscani
# Datum: 09-02-2024
# Toelichting:
# Eeuwigdurende kalender - Zowel Gregoriaanse als Juliaanse kalender
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
# Snellere versie van perpetualcalendar3.sh in awk
# Super-efficiënte versie: O(1)
# Overflow bij year > 5 miljoen
#
######################################################################################

day=$1
month=$2
year=$3
date_now=$(date "+%Y%m%d")

awk -v day="$day" -v month="$month" -v year="$year" -v date_now="$date_now" \
    'function julian_leap(year)
    {
        if (year % 4 == 0)
            return 1                             # Julian leap year
        else
            return 0                             # No Julian leap year
    }

    function gregor_leap(year)
    {
        if (year % 400 == 0 || (year % 4 == 0 && year % 100 != 0))
            return 1                             # Gregorian leap year
        else
            return 0                             # No Gregorian leap year
    }

    function recalculate_date(fullcycle_yrs, remaindays, calendar)
    {
        y = fullcycle_yrs
        remainyear = 0
        while (1){
            if (calendar == "Julian")
                leap = julian_leap(remainyear)
            else     # "Gregorian"
                leap = gregor_leap(remainyear)
            yearlength = 365 + leap
            if (remaindays > yearlength){
                remaindays -= yearlength
                y += 1
            }
            else
                break
            remainyear += 1
        }
        if (remaindays == 0){
            m = 12
            d = 31
            y -= 1
        }
        else{
            for (m = 1; m <= 12; m += 1){
                if (m == 2)
                    monthlength = 28 + leap
                else
                    monthlength = lengths[m]
                if (remaindays > monthlength)
                    remaindays -= monthlength
                else if (remaindays == 0){
                    m -= 1
                    d = lengths[m]
                    break
                }
                else{
                    d = remaindays
                    break
                }
            }
        }
        return d" "m" "y
    }


    BEGIN \
    {
    months[1]  = "January"
    months[2]  = "February"
    months[3]  = "March"
    months[4]  = "April"
    months[5]  = "May"
    months[6]  = "June"
    months[7]  = "July"
    months[8]  = "August"
    months[9]  = "September"
    months[10] = "October"
    months[11] = "November"
    months[12] = "December"

    lengths[1]  = 31
    lengths[2]  = 28
    lengths[3]  = 31
    lengths[4]  = 30
    lengths[5]  = 31
    lengths[6]  = 30
    lengths[7]  = 31
    lengths[8]  = 31
    lengths[9]  = 30
    lengths[10] = 31
    lengths[11] = 30
    lengths[12] = 31

    weekdays[0] = "Friday"
    weekdays[1] = "Saturday"
    weekdays[2] = "Sunday"
    weekdays[3] = "Monday"
    weekdays[4] = "Tuesday"
    weekdays[5] = "Wednesday"
    weekdays[6] = "Thursday"

    calendar[0] = "Gregorian"
    calendar[1] = "Julian"

    for (i = 0; i <= 1; i += 1 ){

        # Determine if year in question is a leap year, if so: raise number of days in February:
        if (calendar[i] == "Gregorian")
            lengths[2] = 28 + gregor_leap(year)  # leap year
        else
            lengths[2] = 28 + julian_leap(year)  # leap year

        # Verify if date is legal:
        if (year < 0 || month > 12 || month < 1 || day > lengths[month] || day < 1){
            print "Date not legal"
            exit
        }

        # Calculate number of days in year in question including date:
        days_thisyear = day
        for (mon = 1; mon < month; mon += 1)
            days_thisyear += lengths[mon]

        # Calculate number of days before year in question, from/incl. Saturday Jan 1 of year 0 (a leap year):
        if (calendar[i] == "Gregorian"){
            days_previousyears = year * 365 + int((year + 3) / 4) - int((year + 99) / 100) + int((year + 399) / 400)

            # Re-calculate the date from Gregeorian to Julian calendar:
            days_total = days_previousyears + days_thisyear + 2   # Jan. 1 of Year 0 is 2 days earlier in Julian
            fullcycle_days = 366 + 3 * 365
            fullcycle_years = int(days_total / fullcycle_days) * 4
        }
        else{      # if calendar = "Julian"
            days_previousyears = year * 365 + int((year + 3) / 4)

            # Re-calculate the date from Julian to Gregeorian calendar:
            days_total = days_previousyears + days_thisyear - 2   # Jan. 1 of Year 0 is 2 days later in Gregorian
            fullcycle_days = (1 + 4 * 24) * 366 + (400 - 1 - 4 * 24) * 365
            fullcycle_years = int(days_total / fullcycle_days) * 400
        }

        remainderdays = days_total % fullcycle_days
        split(recalculate_date(fullcycle_years, remainderdays, calendar[(i + 1) % 2]), recalculated)

#       print fullcycle_years, remainderdays, calendar[(i + 1) % 2]
#       print recalculated[1], recalculated[2], recalculated[3]

        # Determination of day number in the week:
        weekday = days_thisyear + days_previousyears - i * 2
        # Gregorian 1 Jan 0 is on a Saturday, the same date in Julian is 2 days earlier on a Thursday.

        date_asked = year * 10000 + month * 100 + day

        # Determine past, present or future tense:
        if (date_asked < date_now){
            fall = "fell"
            be = "was"
        }
        else if (date_asked == date_now){
            fall = "falls"
            be = "is"
        }
        else{
            fall = "will fall"
            be = "will be"
        }

        # Determine whether or not the year is a leap year:
        if (calendar[i] == "Gregorian" && gregor_leap(year))
            leapstring = year" is a Gregorian leap year."
        else if (calendar[i] == "Julian" && julian_leap(year))
            leapstring = year" is a Julian leap year."
        else
            leapstring = year" is not a "calendar[i]" leap year."

        printf ("\n%-10s: %-2d %s %d =\n", calendar[i], day, months[month], year)
        printf ("%-10s: %-2d %s %d\n", calendar[(i+1)%2], recalculated[1], months[recalculated[2]], recalculated[3])
        printf ("It %s on a %s,\n", fall, weekdays[((weekday % 7) + 7) % 7])
        printf ("and %s day nr: %d\n", be, days_thisyear + days_previousyears)
        printf ("as counted from January 1 of Year 0\non the %s calendar.\n", calendar[i])
        print leapstring

    }

    printf "\n"

}' <<<""
