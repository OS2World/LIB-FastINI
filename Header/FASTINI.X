;----------------------------------------------------------------------------
;    MODULE NAME:   FASTINI.X
;
;        $Author:   Dennis  $
;      $Revision:   1.0  $
;          $Date:   13 Nov 2000 18:11:16  $
;       $Logfile:   C:/DBAREIS/Projects.PVCS/MultiOs/rexxhdr/FASTINI.X.pvcs  $
;         SOURCE:   http://dennisbareis.com/ 
;
;    DESCRIPTION:   Example program for "FASTINI.XH".
;
;                   Compile with "ppwizard FASTINI.X /rexx"
;
;     Released as Open Source Software under the GNU GPL license.
;----------------------------------------------------------------------------

/*
 * $Header:   C:/DBAREIS/Projects.PVCS/MultiOs/rexxhdr/FASTINI.X.pvcs   1.0   13 Nov 2000 18:11:16   Dennis  $
 */

/*--- Load FASTINI support --------------------------------------------------*/
#include "FASTINI.XH"

/*--- Add trap handlers -----------------------------------------------------*/
signal on HALT    name RexxCtrlC;
signal on NOVALUE name RexxTrapUninitializedVariable;
signal on SYNTAX  name RexxTrapSyntaxError;

/*--- Initialization --------------------------------------------------------*/
address cmd '@echo off';

/*--- Get parameter ---------------------------------------------------------*/
UserCmd = translate(strip(arg(1)));
if UserCmd <> "FAST" & UserCmd <> "SLOW" then
do
   say 'ERROR: This test program requires a parameter "FAST" or "SLOW"!';
   exit(255);
end;

/*--- Initialization --------------------------------------------------------*/
IniFile = "INITEST.INI";
call RxFuncAdd  'SysIni', 'RexxUtil', 'SysIni';

/*--- Prepare INI for fast access -------------------------------------------*/
Dummy = time('Reset');
if UserCmd = "FAST" then
do
   /*--- Load INI to improve performance ------------------------------------*/
   FastRc = FastIniOpenIni(IniFile, "IniHandle");
   if  FastRc = 'OK' then
       say 'IniHandle=' || IniHandle;
   else
       say 'Fast Load failed. ' || FastRc;
end;

/*--- Write 200 values ------------------------------------------------------*/
Count = 0;
do x = 1 to 20
   do  Key = 1 to 10
       call SysIni IniFile, 'App' || x, Key, "New Value - " || Count;
       Count = Count + 1;
   end;
end;
say Count || ' values set....';
say ''

/*--- Close Fast INI file ---------------------------------------------------*/
if UserCmd = "FAST" then
do
   /*--- This will write out (checkpoint) all previous changes --------------*/
   call FastIniCloseIni IniHandle;
end;

/*--- Tell user how long it took --------------------------------------------*/
say 'Took ' || time('Elapsed') || ' seconds in ' || UserCmd || ' mode.';

/*--- Output version Info ---------------------------------------------------*/
if FastIniIsFast() = 'Y' then
   call FastIniGetVersion("VersionInfo");
else
   VersionInfo = 'FASTINI.DLL is unavailable and was therefore not used';
say  VersionInfo;
exit(0);




/*===========================================================================*/
CommonTrapHandler:
/*                                                                           */
/* arg(1) = Failing Line                                                     */
/* arg(2) = Type of trap (heading to be underlined)                          */
/* arg(3) = Trap specific Title  (text description)                          */
/* arg(4) = Trap specific Text                                               */
/*===========================================================================*/
   /*--- Work out some details based on passed info -------------------------*/
   FailingLine     = arg(1);
   TrapHeading     = 'BUG: ' || arg(2);
   TextDescription = arg(3);
   Text            = arg(4);

   /*--- Work out name of THIS rexx procedure -------------------------------*/
   parse source . . SourceFileName;

   /*--- Display details of the failing rexx code ---------------------------*/
   say "[0;1;31m" || copies('=+', 39);
   say TrapHeading;
   say copies('~', length(TrapHeading));
   say substr(TextDescription, 1 , 16) || ': ' || Text;
   say 'Failing Module  : ' || SourceFileName;
   say 'Failing Line #  : ' || FailingLine;
   say 'Failing Command : ' || strip(SourceLine(FailingLine));
   say copies('=+', 39) || "[0m";

   /*--- Cleanup any Fast opened INI files ----------------------------------*/
   call FastIniCleanup;

   /*--- We won't let a failure in one subprocedure stop others working -----*/
   exit(FailingLine);


/*===========================================================================*/
RexxTrapUninitializedVariable:
/*===========================================================================*/
   /*--- Process the trap (it never returns) --------------------------------*/
   call CommonTrapHandler SIGL, 'NoValue Abort!', 'Unknown Variable', condition('D');

/*===========================================================================*/
RexxTrapSyntaxError:
/*===========================================================================*/
   /*--- Process the trap (it never returns) --------------------------------*/
   call CommonTrapHandler SIGL, 'Syntax Error!', 'Reason', errortext(Rc);


/*===========================================================================*/
RexxCtrlC:
/*===========================================================================*/
   LineCtrlC = SIGL;
   call FastIniCleanup;
   say '';
   say "[0;1;31m" || copies('=+', 39);
   say "Come on, you pressed Ctrl+C or Break didn't you!";
   say copies('=+', 39) || "[0m";
   exit(LineCtrlC);




