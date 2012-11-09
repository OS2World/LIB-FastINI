#*---------------------------------------------------------------------------+
#     MODULE NAME:   FastIni.MAK
#
#         $Author:   Dennis_Bareis  $
#       $Revision:   1.0  $
#           $Date:   28 May 1998 18:25:56  $
#        $Logfile:   E:/DB/PVCS.IT/OS2/FASTINI/FASTINI.MAV  $
#
#     2010-11-2 - Released as Open Source under the GNU GPL License.
#     DESCRIPTION:
#
#---------------------------------------------------------------------------*/


MAKE_IN_PASS1_LIST           =                 \

MAKE_IN_PASS2_LIST           =                 \
                                FastIni.DLL
#                               FastIni.INF
.INCLUDE $(PRJSUPPORTDIR)\PRJVAC30.MAK
#############################################################################




#### Delete the following if not required ###################################
#DEBUG_WITH_IPMD = RemoveLeading#ToAllowDebuggingWithIPMD
C_FLAGS_OB             = /Ms -I.
C_FLAGS_OBJ            = /Ms -I.
_LXLITE_ENABLED        = NO
_ICCFLG_WARNING_LEVEL  =

FastIni.DLL:                \
              FastIni.OBJ   \
              REXXDLL.LIB   \
              REXX.LIB      \
              FastIni.DEF
              %do MAKE_DLL



#############################################################################
##########################[ LOAD DEPENDANCY FILE ]###########################
#############################################################################
%if !%defined(PRJNODEP)
.INCLUDE $(OUTPUT_DIRECTORY)\MAKE.DEP
%endif

