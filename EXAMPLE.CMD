/* TEST PROGRAM FOR FASTINI.DLL (http://www.ozemail.com.au/~dbareis) */
/*    2010-11-2 - Released as Open Source under the GNU GPL License. */

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
   /*--- Load up functions --------------------------------------------------*/
   call RxFuncAdd  'FastIniStart',   'FastIni',  'FastIniStart';
   call RxFuncAdd  'FastIniEnd',     'FastIni',  'FastIniEnd';
   call RxFuncAdd  'FastIniVersion', 'FastIni',  'FastIniVersion';

   /*--- Output information -------------------------------------------------*/
   say 'You can have as many INI files opened for "fast" access as you wish.  You';
   say 'should note that any writes are not written to disk until you close them.';
   say 'It is highly recommended that you Trap "NOVALUE"/"SYNTAX"/"HALT" at least';
   say 'and ensure any opened handles are closed.';
   say '';
   say 'Note that a future release (not distant!) will provide better and safer';
   say 'example code that can be included into your code with HTMLPP.';
   say '';
   say '';

   /*--- Load INI to improve performance ------------------------------------*/
   FastRc = FastIniStart(IniFile, "IniHandle");   /* Don't really need to check Rc */
   if  FastRc = 'OK' then
       say 'IniHandle=' || IniHandle;
   else
       say 'Fast Load failed. ' || FastRc;
end;

/*--- Write 200 values ------------------------------------------------------*/
Count = 0;
do x = 1 to 20
   do  Key = 1 to 10
       call SysIni IniFile, App||x, Key, "New Value - " || Count;
       Count = Count + 1;
   end;
end;
say Count || ' values set....';
say ''

/*--- Close Fast INI file ---------------------------------------------------*/
if UserCmd = "FAST" then
do
   /*--- This will write out (checkpoint) all previous changes --------------*/
   call FastIniEnd  IniHandle;
end;

/*--- Tell user how long it took --------------------------------------------*/
say 'Took ' || time('Elapsed') || ' seconds in ' || UserCmd || ' mode.';

/*--- Output version Info ---------------------------------------------------*/
call FastIniVersion("VersionInfo");
say  VersionInfo;
exit(0);
