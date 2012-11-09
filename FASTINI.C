/*---------------------------------------------------------------------------+
|     MODULE NAME:   FastIni.C
|
|
|         $Author:   Dennis_Bareis  $
|       $Revision:   1.0  $
|           $Date:   28 May 1998 18:25:54  $
|        $Logfile:   E:/DB/PVCS.IT/OS2/FASTINI/FASTINI.C_V  $
|
|     DESCRIPTION:   Loads up INI files for faster access.
|     2010-11-2 - Released as Open Source under the GNU GPL License.
+---------------------------------------------------------------------------*/

/*------ Make constant string definition more efficient & protect them! -----*/
#pragma  strings(readonly)

/*------ Include required Header files --------------------------------------*/
#define  INCL_DOSPROCESS
#define  INCL_REXXSAA
#define  INCL_WINSHELLDATA
#define  _DLL
#define  _MT
#include <os2.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <rexxsaa.h>
#include <RexxDll.H>


/*--- Version Information ---------------------------------------------------*/
#define REXXDLL_VERSION_INFO                   \
        "98.148"                               \
        " "                                    \
        "http://www.ozemail.com.au/~dbareis"   \
        " "                                    \
        "db0@anz.com"                          \
        " "                                    \
        "Dennis Bareis"

/*--- Anchor Block Handle ---------------------------------------------------*/
static HAB hab = NULLHANDLE;




/*===========================================================================*/
REX_DECLARE_REXX_ENTRY_POINT(FastIniVersion)
/*                                                                           */
/* This routine requires the following parameters:                           */
/*                                                                           */
/*      1. The name of a variable that will be updated with the version      */
/*         information.                                                      */
/*===========================================================================*/
{
    UCHAR       * VariableName = REX_ASCIIZ_ARGV(0);
    LongRc0IfOk   AddRc;

    /*--- Validate parameter(s) ---------------------------------------------*/
    RexCheckPassedVariableCountSetUpRcAndExitOnError(1);

    /*--- Set the information variable --------------------------------------*/
    AddRc = RexSetRexxVariable(VariableName, REXXDLL_VERSION_INFO);
    if  (AddRc == 0)
        RexSetUpOkRc(RxFunctionRc);
    else
        RexSetUpErrorRc(MODULEID(), RxFunctionRc, "Could not update the variable \"%s\" (Rc = %lu).", VariableName, AddRc);

    /*--- Thats all Folks ---------------------------------------------------*/
    REX_RETURN_TO_CMD();
}



/*===========================================================================*/
REX_DECLARE_REXX_ENTRY_POINT(FastIniStart)
/*                                                                           */
/* This routine requires the following parameters:                           */
/*                                                                           */
/*      1. The Name of an INI file.                                          */
/*      2. The name of a variable to contain the INI Handle.                 */
/*                                                                           */
/* What it does is open the INI file.  This means that SysIni() INI file     */
/* open & closes will not actually open and close the INI file as its still  */
/* in use.                                                                   */
/*===========================================================================*/
{
   UCHAR       * IniName    = REX_ASCIIZ_ARGV(0);
   UCHAR       * HandleName = REX_ASCIIZ_ARGV(1);
   HINI          hIni;
   UCHAR         hIniString[30];
   LongRc0IfOk   AddRc;

   /*--- Validate parameter(s) ----------------------------------------------*/
   RexCheckPassedVariableCountSetUpRcAndExitOnError(2);
   RexSetUpOkRc(RxFunctionRc);

   /*--- We don't want to do anything if USER and/or SYSTEM INI file --------*/
   if  ((stricmp(IniName, "USER") == 0) || (stricmp(IniName, "SYSTEM") == 0) || (stricmp(IniName, "BOTH") == 0))
       hIni = NULLHANDLE;                          //No need to open
   else
   {
       /*--- Get Anchor Block Handle ----------------------------------------*/
       if  ((hab=WinInitialize(0)) == NULLHANDLE)
           hab = WinQueryAnchorBlock(HWND_DESKTOP);

       /*--- Open the INI file ----------------------------------------------*/
       if  ((hIni=PrfOpenProfile(hab, IniName)) == NULLHANDLE)
           RexSetUpErrorRc(MODULEID(), RxFunctionRc, "Could not open the INI file \"%s\".", IniName);
   }

   /*--- Set the users variable ---------------------------------------------*/
   sprintf(hIniString, "%lu", hIni);
   AddRc = RexSetRexxVariable(HandleName, hIniString);
   if  (AddRc != 0)
       RexSetUpErrorRc(MODULEID(), RxFunctionRc, "Could not update the variable \"%s\" (Rc = %lu).", HandleName, AddRc);

   /*--- Thats all Folks ----------------------------------------------------*/
   REX_RETURN_TO_CMD();
}


/*===========================================================================*/
REX_DECLARE_REXX_ENTRY_POINT(FastIniEnd)
/*                                                                           */
/* This routine requires the following parameters:                           */
/*                                                                           */
/*      1. The Handle of an INI file previously "started".                   */
/*                                                                           */
/*                                                                           */
/* Note that PrfOpenProfile() returns the same handle on multiple calls,     */
/* for this reason if the 1st close works we keep going until really         */
/* closed.                                                                   */
/*===========================================================================*/
{
   UCHAR  * Handle = REX_ASCIIZ_ARGV(0);
   HINI     hIni;
   BOOL     CloseOk;

   /*--- Validate parameter(s) ----------------------------------------------*/
   RexCheckPassedVariableCountSetUpRcAndExitOnError(1);
   RexSetUpOkRc(RxFunctionRc);

   /*--- Close the INI file -------------------------------------------------*/
   hIni = strtoul(Handle, NULL, 10);
   if  (hIni != 0)
   {
       /*--- Close the INI file ---------------------------------------------*/
       CloseOk = PrfCloseProfile(hIni);
       if   (! CloseOk)
            RexSetUpErrorRc(MODULEID(), RxFunctionRc, "Close of the INI handle \"%s\" failed.", Handle);
        else
        {
            int CloseCount;            //Used as safety (prevents infinite loop)

            /*--- In case of previous traps, keep closing until fails.. -----*/
            for (CloseCount=1; CloseCount <= 20; CloseCount++)
            {
                /*--- Close and see if closed -------------------------------*/
                CloseOk = PrfCloseProfile(hIni);
                if  (! CloseOk)
                    break;                          //Must be closed...
            }
        }
   }

   /*--- Thats all Folks ----------------------------------------------------*/
   REX_RETURN_TO_CMD();
}

