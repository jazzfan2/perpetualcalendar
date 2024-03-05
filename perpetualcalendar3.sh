#!/bin/bash
# Naam: perpetualcalendar3.sh
# Auteur: Rob Toscani
# Datum: 08-02-2024
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
# Versie van perpetualcalendar3.py in bash
# Super-efficiënte versie: O(1)
#
#
######################################################################################
#
# Copyright (C) 2024 Rob Toscani <rob_toscani@yahoo.com>
#
# perpetualcalendar3.sh is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# perpetualcalendar3.sh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
######################################################################################

day=$1            # Must be integer > 0
month=$2          # Must be integer > 0
year=$3           # Must be integer >= 0

months=("null" "January" "February" "March" "April" "May" "June" "July" "August" "September" "October" "November" "December")
lengths=(0 31 28 31 30 31 30 31 31 30 31 30 31)
weekdays=("Friday" "Saturday" "Sunday" "Monday" "Tuesday" "Wednesday" "Thursday")


is_leap(){
    year=$1
    calendar=$2
    if ( [[ $calendar == "Gregorian" ]] && 
         (( year % 400 == 0 || ( year % 4 == 0 && year % 100 != 0 ) )) ||
       ( [[ $calendar == "Julian" ]] && (( year % 4 == 0 )) )); then
        echo 1                  # Leap year
    else
        echo 0                  # No leap year
    fi
}


recalculate_date(){
    y=$1
    local remainderdays=$2
    calendar=$3
    (( remainderyear = 0 ))
    while true; do
        leap=$(is_leap $remainderyear $calendar)
        (( yearlength = 365 + leap ))
        if (( remainderdays > yearlength )); then
            (( remainderdays -= yearlength ))
            (( y += 1 ))
        else
            break
        fi
        (( remainderyear += 1 ))
    done
    if (( remainderdays == 0 )); then
        (( m = 12 ))
        (( d = 31 ))
        (( y -= 1 ))
    else
        for (( m = 1; m <= 12; m += 1 )); do
            if (( m == 2 )); then
                (( monthlength = 28 + leap ))
            else
                (( monthlength = ${lengths[m]} ))
            fi
            if (( remainderdays > monthlength )); then
                (( remainderdays -= monthlength ))
            elif (( remainderdays == 0 )); then
                (( m -= 1 ))
                (( d = ${lengths[m]} ))
                break
            else
                (( d = remainderdays ))
                break
            fi
        done
    fi
    echo "$d $m $y"
}

calendar=("Gregorian" "Julian")
for (( i = 0; i <= 1; i += 1 )); do

# Raise number of days in February if year in question is a leap year:
    (( lengths[2] = 28 + $(is_leap $year ${calendar[i]}) ))  # leap year

    # Verify if date is legal:
    if (( year < 0 || month > 12 || month < 1 || day > lengths[month] || day < 1 )); then
        echo "Date not legal. Give integers for day (> 0), month (> 0) and year (>= 0)."
        exit 1
    fi

    # Calculate number of days in year in question including date:
    (( days_thisyear = day ))
    for (( mon = 1; mon < month; mon += 1 )); do
        (( days_thisyear += lengths[mon] ))
    done

    # Calculate number of days before year in question, from/incl. Saturday Jan 1 of year 0 (a leap year):
    if [[ ${calendar[i]} == "Gregorian" ]]; then
        (( days_previousyears = year * 365 + (year + 3) / 4  - (year + 99) / 100 + (year + 399) / 400 ))

        # Re-calculate the date from Gregeorian to Julian calendar:
        (( days_total = days_previousyears + days_thisyear + 2 ))   # Jan. 1 of Year 0 is 2 days earlier in Julian
        (( fullcycle_days = 366 + 3 * 365 ))
        (( fullcycle_years = (days_total / fullcycle_days) * 4 ))

    else      # if calendar = "Julian"
        (( days_previousyears = year * 365 + (year + 3) / 4 ))

        # Re-calculate the date from Julian to Gregeorian calendar:
        (( days_total = days_previousyears + days_thisyear - 2 ))   # Jan. 1 of Year 0 is 2 days later in Gregorian
        (( fullcycle_days = (1 + 4 * 24) * 366 + (400 - 1 - 4 * 24) * 365 ))
        (( fullcycle_years = (days_total / fullcycle_days) * 400 ))
    fi

    (( remainderdays = days_total % fullcycle_days ))
    recalculated=( $(recalculate_date $fullcycle_years $remainderdays ${calendar[$(( (i + 1) % 2 ))]}) )

#   echo $fullcycle_years $remainderdays ${calendar[$(( (i + 1) % 2 ))]}
#   echo ${recalculated[@]}

    # Determine day number in the week:
    (( weekday = days_thisyear + days_previousyears - i * 2 ))
    # Gregorian 1 Jan 0 is on a Saturday, the same date in Julian is 2 days earlier on a Thursday.

    date_now=$(date "+%Y%m%d")
    if [[ ${calendar[i]} == "Gregorian" ]]; then
        (( date_gregor = year * 10000 + month * 100 + day ))
    else
        (( date_gregor = ${recalculated[2]} * 10000 + ${recalculated[1]} * 100 + ${recalculated[0]} ))
    fi

    # Determine past, present or future tense:
    if (( date_gregor < date_now )); then
        fall="fell"
        be="was"
    elif (( date_gregor == date_now )); then
        fall="is TODAY, falls"
        be="is"
    else
        fall="will fall"
        be="will be"
    fi

    # Determine whether or not the year is a leap year:
    if (( $(is_leap $year ${calendar[i]}) )); then
        leapstring="$year is a ${calendar[i]} leap year."
    else
        leapstring="$year is not a ${calendar[i]} leap year."
    fi 

    printf '\n%-10s: %-2d %s %d =\n' "${calendar[i]}" $day "${months[month]}" $year
    printf '%-10s: %-2d %s %d\n' "${calendar[(( (i+1)%2 ))]}" ${recalculated[0]} "${months[recalculated[1]]}" ${recalculated[2]}
    printf 'It %s on a %s,\n' "$fall" "${weekdays[$(( weekday % 7 ))]}"
    printf 'and %s day nr: %d\n' "$be" $(( days_thisyear + days_previousyears ))
    printf 'as counted from January 1 of Year 0\non the %s calendar.\n' "${calendar[i]}"
    printf "$leapstring\n"

done

printf "\n" 
