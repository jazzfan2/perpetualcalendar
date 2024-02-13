# Name: perpetualcalendar 
perpetualcalendar - A program that calculates on what day any given past, present or future date falls - on both the Gregorian and Julian Calendars. Three versions are available:
- perpetualcalendar3.py - Python3 version
- perpetualcalendar3.sh - Shell (Bash) version
- perpetualcalendar3a.sh - Quicker Bash version with awk code

# Description:
'perpetual calendar' calculates on which day a date falls, both in our present Gregorian Calendar and in the 
ancient Julian Calendar, and recalculates the date from Gregorian into Julian and vice versa.
Additionally, it tells how many days have passed since Jan 1 of year 0, and if the year in question is or isn´t a leap year in any of the two calendars.

Any date from the year 0 to very far in the future is supported, with no impact on the program's speed:
- Python: year number unlimited
- Shell: year number up to 2,5 * 10^16
- Shell with awk: year number up to 5000000

# How to use perpetualcalendar:
In order to use perpetual calendar, supply the name of the program as the command, with day, month and year as integer arguments in respective order.
For instance with the Python version, a query for the 4th of July, 1776 is done as follows:


	./perpetualcalendar3.py 4 7 1776


... rendering following result:

	Gregorian : 4  July 1776 =
	Julian    : 23 June 1776
	It fell on a Thursday, and was day nr: 648857
	as counted from January 1 of Year 0 on the Gregorian calendar.
	1776 is a Gregorian leap year.

	Julian    : 4  July 1776 =
	Gregorian : 15 July 1776
	It fell on a Monday, and was day nr: 648870
	as counted from January 1 of Year 0 on the Julian calendar.
	1776 is a Julian leap year.


# Author:
Written by Rob Toscani (rob_toscani@yahoo.com).
