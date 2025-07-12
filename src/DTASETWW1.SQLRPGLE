       ctl-opt DFTACTGRP(*NO) bnddir('U7':'DSM6':'DWW') actgrp('A7')
               option(*noshowcpy);
      /include cpy,u7env_h
      /include cpy,u7Fmt_h
      /include cpy,u7grid_h
      /include cpy,u7ibm_h
      /include cpy,u7int_h
      /include cpy,u7screen_h
      /include cpy,u7msg_h
      /include cpy,u7tree_h
      /include cpy,u7xml_h
      /include cpy,u7xView_h
      /include cpy,dsm6_h
      /include cpy,QSNAPI_H
      /include cpy,dww_h
      // --------------------------------------------------------------------
      // global variables
      // --------------------------------------------------------------------
       dcl-ds g qualified;
         fileID        varChar(10);
         libID         varChar(10);
         fmtID         varChar(20);
         where         varChar(60) inz;
         orderBy       varChar(60) inz;
         lShells       pointer;
         lShell        pointer;
         lTitle        pointer;
         lHeader       pointer;
         lHeaders      pointer;
         lList         pointer;
         lFooter       pointer;
         lFooterLeft   pointer;
         lFKs          pointer inz(*null);
         lOpts         pointer inz(*null);
         AID           char(1);
         csrX          int(10);
         csrY          int(10);
         screen        int(3);
         lastProcessed pointer;
         lXViews       pointer;
         lXView        pointer;
         lGrids        pointer;
         lFmts         pointer;
       end-ds;
       dcl-s  sqlStm       char(2000);
       dcl-s  RNIDS_max    int(10);
       dcl-s  RNIDS_b4     int(10);
       dcl-s  RNIDS        int(10);
       dcl-s  Refresh      ind;
       dcl-ds XView likeDs(tXView) based(pXView);
       dcl-ds leftb4 likeDs(tLimit);
     d lFormat         s               *
     d format          ds                  likeDs(tFormat) based (pFormat)
      // Record id
     d Atom            ds                         likeDs(tAtom)
      // Record type
     d tAtom           ds                         qualified template
     d  fileName                     10a
     d  rnids                        10i 0
     d  rrn                          10i 0
     d  choice                        1a   inz('')
      // Records id for those displayed
     d Atoms           ds                  dim(20) inz likeDs(tAtom)
      // Buffer for displayed records
     d  pDta           s               *   dim(20)
     d  pDta1          s               *
      // open file
     d  hFile          s               *
     D Ropen           Pr              *   ExtProc('_Ropen' )
     D  pRFile                         *   Value Options(*String)
     D  pMode                          *   Value Options(*String)
      // close file
     D Rclose          Pr            10i 0 ExtProc('_Rclose')
     D  pRFile                         *   Value
      // read by rrn
     dRreadd           pr              *   extproc('_Rreadd')
     d hInFile                         *   value
     d pInBuf                          *   value
     d InBufSx                       10i 0 value
     d InOpts                        10i 0 value
     d InRrn                         10i 0 value
     **-- I/O feedback structure:  -------------------------------------------**
     D RIOFB           Ds                  Based(pRIOFB$)
     D  pKey                           *
     D  pSysParm                       *
     D  IoRcdRrn                     10u 0
     D  IoNbrBytRw                   10i 0
     D  IoBlkCnt                      5i 0
     D  IoBlkFllBy                    1a
     D  IoBitFld                      1a
     D  IoRsv                        20a
      // Array to memorize user input
     d   rnidss        s             10i 0 inz(*hival) dim(100) ascend
     d   choices       s              1a   inz('')     dim(100)
      // --------------------------------------------------------------------
      // main
      // --------------------------------------------------------------------
       dcl-pi dtasetww1;
         fileLibID    char(20);
         fmtID     varChar(20);
         where     varchar(60) options(*nopass);
         orderBy   varchar(60) options(*nopass);
       end-pi;
       g.fileID=%trim(%subst(fileLibID:1 :10));
       g.libID =%trim(%subst(fileLibID:11:10));
       if fmtID='*FILE';
         g.fmtID=%trim(g.fileID);
       else;
         g.fmtID=%trim(fmtID);
       endif;
       if %parms()>=%parmNum(where)
       and where <>'';
         g.where='where '+%trim(where);
       endIf;
       if %parms()>=%parmNum(orderBy)
       and orderBy<>'';
         g.orderBy='order by '+%trim(orderBy);
       endIf;
       // Load the shell and layouts
       g.lShell=dsm_getShell(g.lShells:'SHELL');
       g.lTITLE     =dsm_getLayout(g.lShell:'TITLE'     :1 :1  :1 :132);
       g.lHEADER    =dsm_getLayout(g.lShell:'HEADER'    :2 :1  :3 :132);
       g.lHEADERS   =dsm_getLayout(g.lShell:'HEADERS'   :5 :1  :1 :132);
       g.lLIST      =dsm_getLayout(g.lShell:'LIST'      :6 :2  :20:131);
       g.lFOOTER    =dsm_getLayout(g.lShell:'FOOTER'    :26:1  :1 :100);
       g.lFOOTERLEFT=dsm_getLayout(g.lShell:'FOOTERLEFT':26:120:1 :7);
       // Load function keys
       screen_setFK(g.lFKs:Qsn_F3      :'0':%pAddr(F3)      :'F3=Exit'        );
       screen_setFK(g.lFKs:Qsn_F5      :'1':%pAddr(F5)      :'F5=Refresh'     );
       screen_setFK(g.lFKs:Qsn_F7      :'1':%pAddr(F7)      :'F7/F19=Left/all');
       screen_setFK(g.lFKs:Qsn_F8      :'1':%pAddr(F8)     :'F8/F20=Right/all');
       screen_setFK(g.lFKs:Qsn_F17     :'1':%pAddr(F17)     :'F17=Top'        );
       screen_setFK(g.lFKs:Qsn_F18     :'1':%pAddr(F18)     :'F18=Bottom'     );
       screen_setFK(g.lFKs:Qsn_enter   :'1':%pAddr(Enter)                     );
       screen_setFK(g.lFKs:Qsn_F19     :'1':%pAddr(F19)                       );
       screen_setFK(g.lFKs:Qsn_F20     :'1':%pAddr(F20)                       );
       screen_setFK(g.lFKs:Qsn_RollDown:'1':%pAddr(RollDown)                  );
       screen_setFK(g.lFKs:Qsn_RollUp  :'1':%pAddr(RollUp)                    );
       // Load options
       screen_SetOption(g.lOpts:'5':'5=Display');
       // define and open the sql cursor
       openSql();
       // define and open the sql cursor
       allocMemory();
       // Init the screen 1
       initScreen1();
       // Initialise the displayer module
       dww_init();
       dww_loadFmt ('CLIENT':'N':pDta1);
       dww_loadForm('CLIENT':'N');
       // Loop on screen
       g.screen=1;
       dow g.screen>0;
         if g.screen=1;
           Screen1();
         endif;
       endDo;
       // End the program
       *inlr=*on;
      // --------------------------------------------------------------------
      // define and open the cursor
      // --------------------------------------------------------------------
     popenSql          b
     d openSql         pi
       sqlStm='select'
             +' '''+g.fileID+''''
             +' ,row_number() over()'
             +' ,rrn(m) ,'''''
             +' from &f m'
             +' '+g.where
             +' '+g.orderBy;
       if g.libID='*LIBL';
         sqlStm=%scanrpl('&f':g.fileID:sqlStm);
       else;
         sqlStm=%scanrpl('&f':g.libID+'.'+g.fileID:sqlStm);
       endif;
       exec sql prepare s1 from :sqlStm;
       exec sql declare i1 scroll cursor for s1;
       exec sql open i1;
       // -- the last row is memorized
       exec sql fetch last from i1 into :atom;
       RNIDS_max=atom.RNIDS;
     p                 e
      // --------------------------------------------------------------------
      // alloc Memory
      // --------------------------------------------------------------------
     pallocMemory      b
     d allocMemory     pi
     d i               s              3u 0
       lFormat=fmt_getFormat(g.lFmts:g.fileID);
       pFormat=tree_getItem(lFormat);
       for i=1 to 20;
         pDta(i)=%alloc(format.len);
       endFor;
       pDta1=%alloc(format.len);
      // --
       hFile=rOpen(g.libID+'/'+g.fileID:'rr,nullcap=Y');
     p                 e
      // --------------------------------------------------------------------
      // initialize screen 1
      // --------------------------------------------------------------------
     p initScreen1     b
     d initScreen1     pi
     d w132a           s            132a
     d p               s              3u 0
     d FKs             s            100a
     d OPs             s            100a
     d lGrid           s               *
     d grid            ds                  likeDs(tGrid) based(pGrid)
       //
       dsm_clrscr();
       //
       g.lXView=xview_getXView(g.lXViews:g.lGrids:g.lFmts:g.fileID);
       pXView=tree_getItem(g.lXView);
       xview_posToMostLeft(XView:128);
       xview_setHdrs(XView:0);
       //
       lGrid=grid_getgrid(g.lGrids:g.fileID);
       pGrid=tree_getItem(lGrid);
       p=(132-%len(%trim(grid.text)))/2;
       %subst(w132a:p)=grid.text;
       dsm_initLayout(g.lTitle);
       dsm_println(g.lTITLE:qsn_sa_wht:w132a);
       dsm_initLayout(g.lHeader);
       dsm_println(g.lHEADER:qsn_sa_blu:'Type options, press Enter');
       OPs='   '+screen_getChoicesEntitle(g.lOpts);
       dsm_println(g.lHEADER:qsn_sa_blu:OPs);
       dsm_initLayout(g.lFooter);
       FKs=screen_getFkEntitle(g.lFKs);
       dsm_printLn(g.lFooter:qsn_sa_Blu:FKs);
       RNIDS=1;
     p                 e
      // --------------------------------------------------------------------
      // screen 1
      // --------------------------------------------------------------------
     p screen1         b
     d i               s              3u 0
     d rowCount        s              3u 0
     d rowCount_1      s              3i 0
     d skip            s             10i 0
       // Update the headers for columns
       if leftb4<>xView.left;
         loadHeaders();
       endIf;
       // Update the data
       if RNIDS_b4<>RNIDS;
         // To know the current position
         exec sql fetch current from i1 into :atom;
         skip=RNIDS-atom.RNIDS;
         exec sql fetch relative :skip from i1;
         clear atoms;
         exec sql fetch current from i1 for 20 rows into :atoms;
         exec sql get diagnostics :rowCount=ROW_COUNT;
         for i=1 to rowCount;
           pRIOFB$=rreadd(hFile:pDta(i):format.len:x'00000001':atoms(i).rrn);
         endFor;
       endIf;
       // To refresh the list
       if RNIDS_b4<>RNIDS
       or leftb4<>xView.left
       or refresh;
         RNIDS_b4=RNIDS;
         leftb4 =xView.left;
         refresh=*off;
         loadList();
       endIf;
       // Receive the messages
       msg_RcvPM(pgmsts.pgmID);
       // Force cursor to position
       dsm_posOnField(g.lShell:g.lList:g.lastProcessed);
       // Display the screen
       dsm_dspScr(g.lShell);
       // Take in account user input
       dsm_ReadMdt(g.lShell:g.lLIST:%pAddr(clientRead));
       // get AID
       g.AID=dsm_getAID(g.lShell:g.lList:g.csrX:g.csrY:%pAddr(clientRead));
       // process of function key
       screen_processFK(pgmsts.pgmID:g.lFKs:g.aid:%pAddr(control));
     p                 e
      // -----------------------------------------------------------------------
      // read MDT
      // -----------------------------------------------------------------------
     pclientRead       b
     d clientRead      pi
     d  pAtom                          *                                   const
     d  w1000                      1000a                                   const
      *
     d  Atom           ds                  likeDs(tAtom) based(pAtom)
        atom.choice=w1000;
     p                 e
      // -----------------------------------------------------------------------
      // load headers
      // -----------------------------------------------------------------------
     ploadHeaders      b
     d loadHeaders     pi
       dsm_initLayout(g.lHeaders);
       xview_setHdrs(xView:0);
       dsm_println(g.lHeaders:qsn_sa_wht:'Opt'+XView.hdrs);
     p                 e
      // --------------------------------------------------------------------
      // load the list
      // --------------------------------------------------------------------
     ploadList         b
     d loadList        pi
     d w128            s            128a
     d lColumn         s               *
     d column          ds                  likeDs(tColumn) based(pColumn)
     d choice          s              1a
     d i               s              3u 0
     d n               s              3u 0
      *
       dcl-s string char(32000);
       dsm_initShell(g.lShell);
       dsm_initLayout(g.lList);
       // Get the first
       n=%lookupGE(atoms(1).rnids:rnidss);
       // loops on the arrea
       for i=1 to 20;
         if atoms(i).rrn=0;
           leave;
         endIf;
         format.pBuffer1=pDta(i);
         lColumn=XView.left.lColumn;
         dow 1=1;
          pColumn=tree_getItem(lColumn);
          string=int_FormulaExec(column.lFormula);

          if lColumn=XView.right.lColumn;
            // right column
            %subst(w128:Column.pos:XView.right.width)
            =%subst(String:XView.right.pos:XView.right.width);
            if Column.pos+XView.right.width<%len(w128);
              // right attribut
              %subst(w128:Column.pos+XView.right.width:1)=x'20';
            endif;
            leave;
          elseif lColumn=XView.left.lColumn;
            // left column
            %subst(w128:Column.pos:XView.left.width)
            =%subst(String:XView.left.pos:XView.left.width);
          else;
            // mid column
            %subst(w128:Column.pos)=%subst(String:1:column.maxWidth);
          endif;
          lColumn=tree_getNext(lColumn);
        endDo;
        if  n>0
        and atoms(i).rnids=rnidss(n);
          choice=choices(n);
          n+=1;
        else;
          choice=' ';
        endIf;
        dsm_printFld(g.lList:qsn_sa_grn_ul:QSN_FFW_ALPHA_SHIFT
                    :choice
                    :%addr(Atoms(i)));
        dsm_printLN(g.lList:qsn_sa_grn:w128);
       endFor;
       // to clear the remain of the layout
       dsm_padLayout(g.lList);
     p                 e
      // -----------------------------------------------------------------------
      // control
      // -----------------------------------------------------------------------
     pcontrol          b
     d control         pi              n
       return dsm_control(g.lShell:%pAddr(clientCheck));
     p                 e
      // -----------------------------------------------------------------------
      // control on user input
      // -----------------------------------------------------------------------
     pclientCheck      b
     d clientCheck     pi              n
     d  pAtom                          *
     d   value                        1a   varying
     d ko              c                   const(*on)
     d ok              c                   const(*off)
     d choice          s              1a   varying
     d Atom            ds                  likeDs(tAtom) based(pAtom)
       value=atom.choice;
       setChoice(atom:atom.choice);
       if %scan(atom.choice:' 5')=0;
         msg_SndPM(pgmsts.pgmID
                  :'Choice "'+atom.choice+'" on list is not allowed');
         return ko;
       endif;
       return ok;
     p                 e
      // -----------------------------------------------------------------------
      // Memorize de choice
      // -----------------------------------------------------------------------
     psetChoice        b
     d setChoice       pi
     d  atom                               likeDs(tAtom)const
     d  choice                        1a   varying      const
      //
     d   rnidss$       s             10i 0 inz(*hival) dim(100) ascend
     d   choices$      s              1a   inz('')     dim(100)
      // index
     d  n              s              3u 0
       // Find if user input is already memorized
       n=%lookupGE(atom.rnids:rnidss);
       if  rnidss(n)<>atom.rnids
       and rnidss(n)<>*hival;
         %subarr(rnidss$  :1)  =%subarr(rnidss   :n);
         %subarr(choices$:1)  =%subarr(choices :n);
         %subarr(rnidss   :n+1)=%subarr(rnidss$  :1);
         %subarr(choices :n+1)=%subarr(choices$:1);
       endif;
       rnidss(n)  =atom.rnids;
       choices(n)=choice;
     p                 e
      // -----------------------------------------------------------------------
      // F3=Exit
      // -----------------------------------------------------------------------
     pf3               b
     d f3              pi
       exec sql close i1;
       g.screen=0;
     p                 e
      // -----------------------------------------------------------------------
      // F5=Refresh
      // -----------------------------------------------------------------------
     pf5               b
     d f5              pi
       exec sql close i1;
       exec sql open i1;
       // -- the new last row is memorized
       exec sql fetch last from i1 into :atom;
       RNIDS_max=atom.RNIDS;
       // -- to force the refresh
       RNIDS_b4=0;
     p                 e
      // -----------------------------------------------------------------------
      // F7=Left
      // -----------------------------------------------------------------------
     pf7               b
     d f7              pi
       if not xview.left.most;
         xview_TabLeft(XView:128);
       else;
         msg_SndPM(pgmsts.pgmID:'You have reached the left of the list');
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // F8=Right
      // -----------------------------------------------------------------------
     pf8               b
     d f8              pi
       if not xview.right.most;
         xview_TabRight(XView:128);
       else;
         msg_SndPM(pgmsts.pgmID:'You have reached the right of the list');
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // rollDown
      // -----------------------------------------------------------------------
     pRollDown         b
     d RollDown        pi
       if RNIDS=1;
         msg_SndPM(pgmsts.pgmID:'You have reached the top of the list');
       elseif RNIDS<20;
         RNIDS=1;
       else;
         RNIDS-=20;
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // rollUp
      // -----------------------------------------------------------------------
     pRollUp           b
     d RollUp          pi
       if RNIDS+20>RNIDS_max;
         msg_SndPM(pgmsts.pgmID:'You have reached the bottom of the list');
       else;
         RNIDS+=20;
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // F17=Top
      // -----------------------------------------------------------------------
     pf17              b
     d f17             pi
       if RNIDS=1;
         msg_SndPM(pgmsts.pgmID:'You have reached the top of the list');
       else;
         RNIDS=1;
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // F18=Bottom
      // -----------------------------------------------------------------------
     pf18              b
     d f18             pi
       if RNIDS=RNIDS_max-20+1;
         msg_SndPM(pgmsts.pgmID:'You have reached the top of the list');
       else;
         RNIDS=RNIDS_max-20+1;
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // F19=All left
      // -----------------------------------------------------------------------
     pf19              b
     d f19             pi
       if not xview.left.most;
         xView_posToMostLeft(xView:128);
       else;
         msg_SndPM(pgmsts.pgmID:'You have reached the left of the list');
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // F20=All right
      // -----------------------------------------------------------------------
     pf20              b
     d f20             pi
     p                 e
      // -----------------------------------------------------------------------
      // Enter
      // -----------------------------------------------------------------------
     pEnter            b
     d Enter           pi
     d i               s              5u 0
     d RNIDS1          s             10i 0
     d Atom            ds                         likeDs(tAtom)
     d skip            s             10i 0
       for i=1 to %elem(rnidss);
         if rnidss(i)=*hival;
           leave;
         endIf;
         if choices(i)='5';
           exec sql fetch current from i1 into :atom;
           skip=RNIDSS(i)-atom.RNIDS;
           exec sql fetch relative :skip from i1 into :atom;
           pRIOFB$=rreadd(hFile:pDta1:format.len:x'00000001':atom.rrn);
           dww_display(pgmsts.pgmID:choices(i));
         endIf;
       endFor;
       dsm_clrscr();
       dsm_DspScr(g.lShell:*on);
       Refresh=*on;
       reset choices;
       reset rnidss;
     p                 e
