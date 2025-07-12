     h OPTION(*NODEBUGIO:*SRCSTMT:*noshowcpy) nomain BndDir('U7':'DSM6')
      /copy cpy,u7env_h
      /copy cpy,u7fmt_h
      /copy cpy,u7form_h
      /copy cpy,u7ibm_h
      /copy cpy,u7ifs_h
      /copy cpy,u7int_h
      /copy cpy,u7msg_h
      /copy cpy,dsm6_h
      /copy cpy,u7screen_h
      /copy cpy,u7screen_s
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,QSNAPI_H
      // To refresh the screen
     d dww_refresh     s               n   export inz(*off)
      // Screen NO
     d dww_screen      s              3i 0 export
      // Global fields
     d g               ds                  qualified
     d  lShells                        *
     d  caller                       10a
     d  lShell                         *
     d  lFormats                       *
     d  lForms                         *
     d  lForm                          *
     d  lRow1                          *
     d  lRow1_b4                       *
     d  lRow9                          *
     d  lRow9_b4                       *
     d  change                         n
     d  callerChoice                  1a
     d  lFKs                           *
     d  AID                           1a
     d  csrX                         10i 0
     d  csrY                         10i 0
     d  lTITLE                         *
     d  lHEADER                        *
     d  lLIST                          *
     d  lFOOTER                        *
     d  lFOOTERLEFT                    *
     d  lMSG                           *
      *
     d form            ds                  likeDs(tForm) based(pForm)
     d fks             s            100a
     d fks_b4          s            100a
     d sflEnd          s              7a
     d sflEnd_b4       s              7a
      // --------------------------------------------------------------------
      // end
      // --------------------------------------------------------------------
     pdww_end          b                   export
     d dww_end         pi
     p                 e
      // --------------------------------------------------------------------
      // init
      // --------------------------------------------------------------------
     pdww_init         b                   export
     d dww_init        pi
       // Clear the b4s
       FKs_b4='';
       sflEnd_b4='';
       // Load standard function keys                                        -
       screen_setFK(g.lFKs:x'33':'0':%pAddr(F3):'F3=Exit');
       screen_setFK(g.lFKs:x'3a':'1':%pAddr(f10):'F10=Move to top');
       screen_setFK(g.lFKs:x'3b':'0':%pAddr(f11):'F11=Formula   '
                                                :'F11=No Formula');
       screen_setFK(g.lFKs:x'f1':'1':%pAddr(Enter));
       screen_setFK(g.lFKs:x'f4':'1':%pAddr(rollUP  ));
       screen_setFK(g.lFKs:x'f5':'1':%pAddr(rolldown));

       // Load the shell
       g.lShell=dsm_getShell(g.lShells:'SHELL');
       g.lTITLE     =dsm_getLayout(g.lShell:'TITLE'     :1 :1  :2 :132);
       g.lLIST      =dsm_getLayout(g.lShell:'LIST'      :3 :1  :23:132);
       g.lFOOTER    =dsm_getLayout(g.lShell:'FOOTER'    :26:2  :1 :100);
       g.lFOOTERLEFT=dsm_getLayout(g.lShell:'FOOTERLEFT':26:120:1 :7  );

       // Load procedures for the interpreter
       int_loadProcs();
     p                 e
      // --------------------------------------------------------------------
      // Specific function
      // --------------------------------------------------------------------
     pdww_setFK        b                   export
     d dww_setFK       pi
     d  key                           1a   const
     d  fControl                       n   const
     d  pfunction                      *   const procptr
     d  libel0                       30a   const varying options(*nopass)
     d  libel1                       30a   const varying options(*nopass)
     d  libel2                       30a   const varying options(*nopass)
       if %parms()=%parmNum(libel0);
         screen_setFK(g.lFKs:key:fControl:pFunction:libel0);
       endIf;
       tree_sort(g.lFKs);
     p                 e
      // --------------------------------------------------------------------
      // load format
      // --------------------------------------------------------------------
     pdww_loadFmt      b                   export
     d dww_loadFmt     pi
     d  formatID                     10a   const varying
     d  fAppli                        1a   const
     d  pBuffer                        *
     d  fmtLen                        5u 0 options(*nopass)
      *
     d  lFormat        s               *
     d format          ds                  likeDs(tFormat) based(pFormat)
       lFormat=fmt_getFormat(g.lFormats:%trim(formatID):fAppli);
       if lFormat<>*null;
         pFormat=tree_getItem(lFormat);
         format.pBuffer1=%alloc(format.len);
         pBuffer=format.pBuffer1;
         // Length of the format if requested
         if %parms>=%parmnum(fmtlen);
           fmtLen=format.len;
         endif;
       endIf;
     p                 e
      // --------------------------------------------------------------------
      // load form
      // --------------------------------------------------------------------
     p dww_loadForm    b                   export
     d  dww_loadForm   pi
     d  formID                       10a   const varying
     d  fAppli                        1a   const
      *
     d lX              s               *
     d label           ds                  likeds(tLabel) based(pLabel)
       // Load form
       g.lForm=form_getForm(g.lForms:%trim(formID):fAppli);
       // Resolve formula
       lX=tree_getFirst(g.lForm);
       dow lX<>*null;
         if tree_isOfTheKind(kLabel:lX:pLabel);
           label.lFormula=int_FormulaLoad(label.formula:g.lFormats);
         endIf;
         lX=tree_getNextToDisplay(g.lForm:lX);
       endDo;
     p                 e
      // --------------------------------------------------------------------
      // display screen
      // --------------------------------------------------------------------
     pdww_display      b                   export
     d dww_display     pi
     d  caller                       10a   const
     d  callerChoice                  1a   const
      *
     d w132a           s            132a
     d p               s              3u 0
       g.caller=caller;
       pForm=tree_getItem(g.lForm);
       g.callerChoice=callerChoice;
       //
       dsm_clrscr();
       FKsToRefresh=*on;
       dww_refresh=*on;
       dww_Screen=1;
       p=(132-%len(form.text))/2;
       %subst(w132a:p)=form.text;
       dsm_initLayout(g.lTitle);
       dsm_println(g.lTITLE:qsn_sa_wht:w132a);
       g.lRow1=tree_GetFirstToDisplay(g.lForm);
       dow dww_screen>0;
         if dww_screen=1;
           Screen1();
         endif;
       endDo;
     p                 e
      // --------------------------------------------------------------------
      // Screen 1 - display form
      // --------------------------------------------------------------------
     p Screen1         b
      *
     d fkProcess       pr                  extproc(pAction)
     d pAction         s               *   procptr
     d fcontrol        s               n
       // List
       if g.lRow1<>g.lRow1_b4
       or dww_refresh;
         dsm_initShell(g.lShell);
         loadList();
         g.lRow1_B4=g.lRow1;
         dww_refresh=*off;
       endIf;
       // Function keys
       ///if screen_FKsToRefresh();
       if 1=1;
         FKs=screen_getfkentitle(g.lFKs);
         dsm_initLayout(g.lFooter);
         dsm_printLn(g.lFooter:qsn_sa_Blu:FKs);
       endIf;
       // SflEnd
       if tree_getNextToDisplay(g.lForm:g.lRow9)=*null;
         SflEnd=' Bottom';
       else;
         SflEnd='More...';
       endIf;
       ///SflEnd<>sflEnd_B4;
       if 1=1;
         sflEnd_b4=sflEnd;
         dsm_initLayout(g.lFOOTERLEFT);
         dsm_println(g.lFOOTERLEFT:qsn_sa_wht:sflEnd);
       endif;
       // Display the screen
       msg_RcvPM(g.caller);
       dsm_dspScr(g.lShell);
       // Take in account input
       dsm_ReadMdt(g.lShell:g.lLIST:%pAddr(clientRead));
       // get AID
       g.AID=dsm_getAID(g.lShell:g.lList:g.csrX:g.csrY:%pAddr(clientRead));
       // PROCESS OF FUNCTION KEYS BEFORE CONTROL
       screen_processFK(g.caller:g.lFKs:g.aid:%pAddr(control));
     p                 e
      // -----------------------------------------------------------------------
      // read MDT
      // -----------------------------------------------------------------------
     pclientRead       b
     d clientRead      pi
     d  pAtom                          *                                   const
     d  w1000                      1000a                                   const
     p                 e
      // -----------------------------------------------------------------------
      // print list
      // -----------------------------------------------------------------------
     ploadList         b
     d loadList        pi
     d lRow            s               *
     d fCanPrint       s               n
     d fFormula        s               n

       dsm_initLayout(g.lList);

       fFormula=screen_getFKcontext(g.lFKs:x'3b')='1';

       lRow=g.lRow1;
       printParent(g.lForm:lRow);
       dow lRow<>*null;

         if tree_isOfTheKind(kPanel:lRow);
           fCanPrint=dsm_CanPrint(g.lList);
         else;
           fCanPrint=dsm_CanPrint(g.lList);
         endIf;

         if not fCanPrint;
           leave;
         endIf;

         if tree_isOfTheKind(kPanel:lRow);
           dsm_PrintPanelLN(g.lList:lRow);
         elseIf tree_isOfTheKind(kLabel:lRow);
           dsm_PrintLabelLN(g.lList:lRow:fFormula:isEditable(lRow));
         endIf;
         g.lRow9=lRow;
         lRow=tree_getNextToDisplay(g.lForm:lRow);
       endDo;
       dsm_padLayout(g.lList);
     p                 e
      // -----------------------------------------------------------------------
      // is editable
      // -----------------------------------------------------------------------
     pisEditable       b
     d isEditable      pi              n
     d  lRow                           *                                   const
       if g.callerChoice='5';
         return *off;
       endif;
       return *on;
     p                 e
      // -----------------------------------------------------------------------
      // print parent
      // -----------------------------------------------------------------------
     pprintParent      b
     d printParent     pi
     d  lRoot                          *                                   const
     d  lRow                           *                                   const
      *
     d lX              s               *
       lX=tree_getParentToDisplay(lRoot:lRow);
       if lX=*null;
         return;
       endIf;
       printParent(lRoot:lX);
       dsm_PrintPanelLN(g.lList:lX);
     p                 e
      // -----------------------------------------------------------------------
      // control 2
      // -----------------------------------------------------------------------
     pcontrol          b
     d control         pi              n
       return dsm_control(g.lShell:%pAddr(lblControl));
     p                 e
      // -----------------------------------------------------------------------
      // control 2  label
      // -----------------------------------------------------------------------
     plblControl       b
     d lblControl      pi              n
     d  label                              likeDs(tLabel)
       if  label.mandatory
       and int_FormulaExec(label.lFormula)='';
         msg_SndPM(g.caller:'Field '+label.formula+' required.');
         return *on;
       endIf;
       return *off;
     p                 e
      // -----------------------------------------------------------------------
      // Enter
      // -----------------------------------------------------------------------
     penter            b
     d enter           pi
       ///if not g.change;
       ///  msg_SndPM(g.caller:'Type a function key to continue.');
       ///endIf;
       dww_screen=-1;
     p                 e
      // -----------------------------------------------------------------------
      // F3=Exit
      // -----------------------------------------------------------------------
     pf3               b
     d f3              pi
       dww_screen=-1;
     p                 e
      // -----------------------------------------------------------------------
      // F10=Move to top
      // -----------------------------------------------------------------------
     pf10              b
     d f10             pi
     d lX              s               *
       lX=dsm_getRowAt(g.lList:g.lForm:g.lRow1:g.lRow9:g.csrY);
       if lX=*null;
         msg_SndPM(g.caller:'Wrong cursor position.');
       else;
         g.lRow1=lX;
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // F11=Formula/No Formula
      // -----------------------------------------------------------------------
     pf11              b
     d f11             pi
       dww_refresh=*on;
     p                 e
      // -----------------------------------------------------------------------
      // ROLLup
      // -----------------------------------------------------------------------
     prollUp           b
     d rollUp          pi
       if tree_GetPrevToDisplay(g.lForm:g.lRow1)=*null;
         msg_SndPM(g.caller:'You have reached the top of the list.');
       else;
         g.lRow1=dsm_rollup(g.lList:g.lForm:g.lRow1);
       endif;
     p                 e
      // -----------------------------------------------------------------------
      // ROLLDOWN
      // -----------------------------------------------------------------------
     prolldown         b
     d rollDown        pi
       if tree_GetNextToDisplay(g.lForm:g.lRow9)=*null;
         msg_SndPM(g.caller:'You have reached the bottom of the list.');
       else;
         g.lRow1=tree_GetNextToDisplay(g.lForm:g.lRow9);
       endif;
     p                 e
