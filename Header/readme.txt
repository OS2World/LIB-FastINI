FastIni - Header File
Mon Feb 1 1999
3:40:50am

This is a header file and example program on the best way to use my FASTINI.DLL to greatly boost OS/2 rexx's SysIni() performance (hundreds of times faster). 

This code is designed to interface with FASTINI.DLL  which greatly speeds up access to INI files made with  the standard rexx "SysIni()" calls.

The code has been designed to "work" even if the DLL is unavailable for some reason.  This makes it fairly easy to slot the code in.

Note that it is highly recommended that you call "FastIniCleanup()" prior to exiting your rexx code, particularly in case of traps which you should trap.


Released as Open Source Software under the GNU GPL license. 

Original work by Dennis Bareis (dbareis@gmail.com)
http://dennisbareis.com/