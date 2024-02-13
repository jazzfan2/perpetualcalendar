# Project’s Title
perpetualcalendar - A program that calculates on what day any given past, present or future date falls - on both the Gregorian and Julian Calendars. Three versions are available:
## perpetualcalendar3.py
Python3 version
## perpetualcalendar3a.sh
Shell (Bash) version
## perpetualcalendar3a.sh
Quicker Bash version with awk code

# Description:
'perpetual calendar' calculates on which date a date falls, both in our present Gregorian Calendar as in the 
ancient Julian Calendar, and recalculates the date from Gregorian into Julian and vice versa.
Additionally, it tells if the year in question is or isn ´t a leap year in any of the two calendars.

Any date from the year 0 to very far in the future is supported, with no impact on the program's speed:
- Python: year number unlimited
- Shell: year number up to 2,5 * 10^16
- Shell with awk: year number up to 5000000

# How to use perpetualcalendar:
In order to use perpetual calendar, supply the following command, with day, month and year as integers in respective order, for instance July, 4th, 1776 (example with the Python version):

perpetualcalendar3.py 4 7 1776

# Author:
Written by Rob Toscani (rob_toscani@yahoo.com).
