/*
Naam: perpetualcalendar2.c
Auteur: Rob Toscani
Datum: 06-02-2024
Toelichting: Eeuwigdurende kalender. C-versie van perpetualcalendar2.py
Geijkt op https://en.wikipedia.org/wiki/Perpetual_calendar
https://en.wikipedia.org/wiki/Perpetual_calendar#/media/File:Permanent_Calendar_gregorian.png

Bij Juliaans geldt dat elk door 4 deelbaar jaar een schrikkeljaar is.

De Juliaanse kalender begint op zaterdag 1 jan 01, zie:
https://nl.wikipedia.org/wiki/Bestand:Ewiger_Julianischer_Kalender.png
Naar 1 jan 0 (begin Chr. jaartelling) terug-extrapoleren valt die datum (eigenlijk 1 jan 1 voor Chr. 
want de 0 kende men toen nog niet) bij Juliaans op een donderdag.
Bij Gregoriaans geldt voor 1 jan 0 echter de zaterdag (!), zie:
https://en.wikipedia.org/wiki/Perpetual_calendar#/media/File:Permanent_Calendar_gregorian.png
Stelling RJT: Juliaans loopt op dat moment (initieel) dus 2 dagen voor, ofwel op 1 jan 0 Gregoriaans 
(virtueel, op zaterdag) is het reeds 3 jan 0 Juliaans (1 jan 0 was het daar op donderdag al geweest).
Dit klopt met de sprong die is uitgevoerd bij invoering van de Gregoriaanse kalender in 1582:
Op do 4 okt Juliaans volgt vri 15 okt Gregoriaans, dus 5 okt wordt 15 okt ofwel een correctie van 10
dagen. Dit komt overeen met het 2 dagen voorlopen minus de 12 extra schrikkeldagen bij de eeuwjaren
niet deelbaar door 400 t/m 1500 bij Juliaans t.o.v. Gregoriaans.

######################################################################################

gcc -o perpetualcalendar2 perpetualcalendar2.c -lm -Ofast
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>


void     increment     (long *date, int leap, int *lengths);
int      julian_leap   (long year);
int      gregor_leap   (long year);


int main(int argc, char *argv[])
{
    char *months[]   = { "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
    char *weekdays[] = { "Friday", "Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday" };
    int  lengths[]   = { 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    long jdate[] = {  1, 1, 0 };         // day, month, year (Julian)
    long gdate[] = { -1, 1, 0 };         // day, month, year (Gregorian, starts 2 days behind Julian) 
    int  weekday = 6;                    // Julian starts (= day 1) on a Thursday (= 6) on Jan 1, Year 0
    int  jleap;
    int  gleap;
    long d, m, y;


    if (argc >= 3){
        d = atol(argv[1]);
        m = atol(argv[2]);
        y = atol(argv[3]);
    }
    else{
        printf("Not enough arguments given.\n");
        exit(1);
    }

    // Verify if date is legal:
    if(d > lengths[m]){
        printf("Date not legal\n");
        exit(1);
    }

    printf("%-15s%-18s%-20s%s\n", "Day Number", "Julian Calendar", "Gregorian Calendar", "Day of the week");

    while (1){
        // Print any occurrence of the date in both Julian and Gregorian calendars:
        if((d == jdate[0] && m == jdate[1] && y == jdate[2]) ||
           (d == gdate[0] && m == gdate[1] && y == gdate[2])){
            printf("%-15d%-3ld%-4s%-11ld%-3ld%-4s%-13ld%s\n", weekday-5, jdate[0], months[jdate[1]], jdate[2], \
                                              gdate[0], months[gdate[1]], gdate[2], weekdays[weekday%7]);
        }

        if(jdate[2] > y && gdate[2] > y)
            break;

        weekday += 1;

        jleap = lengths[2] + julian_leap(jdate[2]);
        gleap = lengths[2] + gregor_leap(gdate[2]);

        increment(jdate, jleap, lengths);
        increment(gdate, gleap, lengths);
    }
}


void increment(long *date, int leap, int *lengths)
{
    long *d = date;
    long *m = date + 1;
    long *y = date + 2;
    long list[3];
    if(*d == 31 && *m == 12)                 // End of year
        *y += 1;
    if(*d == 31 ||
      (*d == 30 && *d == lengths[*m]) ||
      (*d == leap && *m == 2)){              // End of month
        *m = *m  % 12 + 1;
        *d = 1;
    }
    else                                     // Any other date
        *d += 1;
}


int julian_leap(long year)
{
    if(year % 4 == 0)
	    return 1;                            // Julian leap year
    else
	    return 0;                            // No Julian leap year
}


int gregor_leap(long year)
{
    if(year % 400 == 0 || ( year % 4 == 0 && year % 100 != 0 ))
	    return 1;                            // Gregorian leap year
    else
	    return 0;                            // No Gregorian leap year
}

