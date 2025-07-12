     h  DFTACTGRP(*NO) bnddir('U7':'DSM6':'DWW') actgrp('A7')
      /include cpy,u7env_h
      /include cpy,u7ibm_h
      /include cpy,u7screen_h
      /include cpy,u7msg_h
      /include cpy,u7tree_h
      /include cpy,u7xml_h
      /include cpy,u7form_h
      /include cpy,dsm6_h
      /include cpy,QSNAPI_H
      /include cpy,dww_h
      // --------------------------------------------------------------------
      // global variables
      // --------------------------------------------------------------------
       dcl-DS g qualified;
         where         varChar(60) inz;
         lRoot         pointer;
         lShells       pointer;
         lShell        pointer;
         lTitle        pointer;
         lHeader       pointer;
         lList         pointer;
         lFooter       pointer;
         lFooterLeft   pointer;
         lMsg          pointer;
         lFKs          pointer inz(*null);
         lOpts         pointer inz(*null);
         AID           char(1);
         csrX          int(10);
         csrY          int(10);
         screen        int(3);
         lRow1         pointer;
         lRow9         pointer;
         lRow1_b4      pointer;
         lRow9_b4      pointer;
         lRows         pointer  dim(27);
         lastProcessed pointer;
       end-ds;
     d sqlStm          s           2000
     d log4i         e ds                  extName(log4i) based(pLog4i)
     d ind             s              3i 0 dim(9)
     d tl4i            ds                  qualified
     d  kind                          1a   inz('4')
     d  log4i                              likeDs(log4i)
     d space           s            100a   inz('')
      // --------------------------------------------------------------------
      // main
      // --------------------------------------------------------------------
       dcl-pi log4iww1;
         where varchar(60) options(*nopass);
       end-pi;
       // Take in account parameters
       if %parms()>=%parmNum(where)
       and where <>'';
         g.where=' and '+%trim(where);
       endIf;
       // Load the shell
       g.lShell=dsm_getShell(g.lShells:'SHELL2');
       g.lTITLE     =dsm_getLayout(g.lShell:'TITLE'     :1 :1  :1 :132);
       g.lHEADER    =dsm_getLayout(g.lShell:'HEADER'    :2 :1  :3 :132);
       g.lLIST      =dsm_getLayout(g.lShell:'LIST'      :5 :1  :21:132);
       g.lFOOTER    =dsm_getLayout(g.lShell:'FOOTER'    :26:1  :1 :100);
       g.lFOOTERLEFT=dsm_getLayout(g.lShell:'FOOTERLEFT':26:120:1 :7);
       // load log4i according request
       // Load function keys
       screen_setFK(g.lFKs:Qsn_F3      :'0':%pAddr(F3)      :'F3=Exit'        );
       screen_setFK(g.lFKs:Qsn_RollDown:'1':%pAddr(RollDown)                  );
       screen_setFK(g.lFKs:Qsn_RollUp  :'1':%pAddr(RollUp)                    );
       screen_setFK(g.lFKs:Qsn_Enter   :'1':%pAddr(Enter)                     );
       // Load options
       screen_SetOption(g.lOpts:'d':'d=Develop');
       screen_SetOption(g.lOpts:'r':'r=Reduce');
       screen_SetOption(g.lOpts:'5':'5=Display');
       // Initialise the displayer module
       dww_init();
       dww_loadFmt ('LOG4I':'N':pLog4i);
       dww_loadForm('LOG4I':'N');
       // Load data
       loadData();
       // Init the screen 1
       g.lRow1=tree_getFirst(g.lRoot);
       initScreen1();
       g.screen=1;
       // Loop on screen
       dow g.screen>0;
         if g.screen=1;
           Screen1();
         endif;
       endDo;
       // End the program
       *inlr=*on;
      // --------------------------------------------------------------------
      // load data (log4i)
      // --------------------------------------------------------------------
     pLoadData         b
     d loadData        pi
       sqlStm=  'select *'
             +   ' from log4i'
             +  ' start with l4itype=''T'''
             +' connect by prior l4iID=l4ipID'
             +  ' order by 1';
       // -- open then cursor
       exec sql prepare s1 from :sqlStm;
       exec sql declare i1 cursor for s1;
       exec sql open i1;
       //
       exec sql fetch next from i1 into :log4i:ind;
       g.lRoot=tree_getNewLink(*null);
       loadChilds(0:g.lRoot);
       exec sql close i1;
     p                 e
      // --------------------------------------------------------------------
      // load data (log4i) (part 2)
      // --------------------------------------------------------------------
     pLoadChilds       b
     d loadChilds      pi
     d  parentID                      5i 0 const
     d  lParent                        *   const
      *
     d lL4i            s               *
     d l4i             ds                  based(pL4i) likeDs(tL4i)
     d ID              s              5i 0
       dow sqlcod=0
       and l4ipid=parentID;
         pL4i=tree_getNewItem(%addr(tL4i):%size(tL4i));
         l4i.log4i=log4i;
         lL4i=tree_getNewLink(pL4i);
         tree_linkToParent(lParent:lL4i);
         ID=l4iID;
         exec sql fetch next from i1 into :log4i:ind;
         loadChilds(ID:lL4i);
       endDo;
     p                 e
      // --------------------------------------------------------------------
      // display screen
      // --------------------------------------------------------------------
     p initScreen1     b
     d initScreen1     pi
     d w132a           s            132a
     d p               s              3u 0
     d FKs             s            100a
     d OPs             s            100a
     d title           c                   const('log4i - Work With')
       //
       dsm_clrscr();
       //
       p=(132-%len(title))/2;
       %subst(w132a:p)=title;
       dsm_initLayout(g.lTitle);
       dsm_println(g.lTITLE:qsn_sa_wht:w132a);
       dsm_initLayout(g.lHeader);
       dsm_println(g.lHEADER:qsn_sa_blu:'Type options, press Enter');
       OPs='   '+screen_getChoicesEntitle(g.lOpts);
       dsm_println(g.lHEADER:qsn_sa_blu:OPs);
       dsm_initLayout(g.lFooter);
       FKs=screen_getFkEntitle(g.lFKs);
       dsm_printLn(g.lFooter:qsn_sa_Blu:FKs);
     p                 e
      // --------------------------------------------------------------------
      // screen
      // --------------------------------------------------------------------
     p screen1         b
       // Update the list
       if g.lRow1_b4<>g.lRow1;
         g.lRow1_b4=g.lRow1;
         loadList();
       endIf;
       // Receive the messages
       msg_RcvPM(pgmsts.pgmID);
       // Force cursor to position
       if g.lastProcessed=*null;
         g.lastProcessed=g.lRow1;
       endif;
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
      // --------------------------------------------------------------------
      // client Reader
      // --------------------------------------------------------------------
     pclientRead       b
     d clientRead      pi
     d  lList                          *   const
     d  w1000                      1000a   const
     d  w2             s              2a
        w2=w1000;
        tree_setOption(lList:w1000);
     p                 e
      // --------------------------------------------------------------------
      // load the list
      // --------------------------------------------------------------------
     p loadList        b
      *
     d lRow            s               *
     d rootLevel       s              3u 0
     d margin          s             20a   varying
     d choice          s              1a
     d link            ds                  likeDs(tLink) based(pLink)
       clear g.lRows;
       dsm_initShell(g.lShell);
       dsm_initLayout(g.lList);
       lRow=g.lRow1;
       rootLevel=tree_getLevel(g.lRoot);
       // print parent
       printParent(rootLevel:lRow);
       // loops on row
       dow lRow<>*null
       and dsm_canPrint(g.lList);
         margin=%subst(space:1:1+(tree_getLevel(lRow)-rootLevel-1)*2);
         dsm_print(g.lList:qsn_sa_wht:margin);
         choice=tree_getOption(lRow);
         dsm_printFld(g.lList:qsn_sa_grn_ul:QSN_FFW_ALPHA_SHIFT:choice:lRow);
         printRow(lRow);
         g.lRow9=lRow;
         lRow=tree_getNextToDisplay(g.lRoot:lRow);
       endDo;
       // to clear the remain of the layout
       dsm_padLayout(g.lList);
     p                 e
      // -----------------------------------------------------------------------
      // Print Parent
      // -----------------------------------------------------------------------
     pPrintParent      b
     d printParent     pi
     d  rootLevel                     3u 0                                 const
     d  lChild                         *                                   const
      *
     d lParent         s               *
     d margin          s             20a   varying
     d choice          s              1a
       lParent=tree_getParentToDisplay(g.lRoot:lChild);
       if lParent<>*null;
         printParent(rootLevel:lParent);
         margin=%subst(space:1:1+(tree_getLevel(lParent)-rootLevel-1)*2);
         dsm_print(g.lList:qsn_sa_wht:margin);
         choice=tree_getOption(lParent);
         dsm_printFld(g.lList:qsn_sa_grn_ul:QSN_FFW_ALPHA_SHIFT:choice:lParent);
         printRow(lParent);
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // Print row
      // -----------------------------------------------------------------------
     pPrintRow         b
     d printRow        pi
     d  lRow                           *   const
     d l4i             ds                  likeDs(tL4i) based(pL4i)
     d y               s              3u 0
     d w100            s            100a
     d w1              s              1a
       pL4i=tree_getItem(lRow);
       w100=' '+l4i.log4i.l4itag+'  '+l4i.log4i.l4itext;
       if l4i.log4i.l4itype='T';
         w1=qsn_sa_red;
       elseif l4i.log4i.l4itype='P';
         w1=qsn_sa_wht;
       else;
         w1=qsn_sa_grn;
       endif;
       dsm_printLN(g.lList:w1:w100:y);
       g.lRows(y)=lRow;
     p                 e
      // -----------------------------------------------------------------------
      // control
      // -----------------------------------------------------------------------
     pcontrol          b
     d control         pi              n
       return dsm_control(g.lShell:%pAddr(inputControl));
     p                 e
      // -----------------------------------------------------------------------
      // control on user input
      // -----------------------------------------------------------------------
     pinputControl     b
     d inputControl    pi              n
     d  lRow                           *
     d  value                      1000a     varying
      *
     d  choice         s              1a
       choice=tree_getOption(lRow);
       value=choice;
       return *off;
     p                 e
      // -----------------------------------------------------------------------
      // F3=Exit
      // -----------------------------------------------------------------------
     pf3               b
     d f3              pi
       g.screen=0;
     p                 e
      // -----------------------------------------------------------------------
      // RollDown
      // -----------------------------------------------------------------------
     pRollDown         b
     d RollDown        pi
     d rootLevel       s              3u 0
     d lRow            s               *
     d count           s              3u 0 inz(0)
       if     g.lRows(g.csrY)=*null;
         msg_SndPM(pgmSts.pgmID:'Wrong cursor position.');
       elseif g.lRows(g.csrY)=g.lRow9
          and tree_getPrevToDisplay(g.lRoot:g.lRow1)=*null;
         msg_SndPM(pgmSts.pgmID:'You have reached the top of the list.');
       elseif g.lRows(g.csrY)=g.lRow9;
         g.lRow9=tree_getPrevToDisplay(g.lRoot:g.lRow1);
       else;
         g.lRow9=g.lRows(g.csrY);
       endif;
      *
       g.lastProcessed=g.lRow9;
       rootLevel=tree_getLevel(g.lRoot);
       lRow=tree_getPrevToDisplay(g.lRoot:g.lRow9);
       dow lRow<>*null;
         g.lRow1=lRow;
         count+=1;
         if count+tree_getLevel(lRow)-rootLevel=21;
           return;
         endIf;
         lRow=tree_getPrevToDisplay(g.lRoot:lRow);
       endDo;
     p                 e
      // -----------------------------------------------------------------------
      // RollUp
      // -----------------------------------------------------------------------
     pRollUp           b
     d RollUp          pi
       if     g.lRows(g.csrY)=*null;
         msg_SndPM(pgmSts.pgmID:'Wrong cursor position.');
       elseif g.lRows(g.csrY)=g.lRow1
          and tree_getNextToDisplay(g.lRoot:g.lRow9)=*null;
         msg_SndPM(pgmSts.pgmID:'You have reached the bottom of the list.');
       elseif g.lRows(g.csrY)=g.lRow1;
         g.lRow1=tree_getNextToDisplay(g.lRoot:g.lRow9);
       else;
         g.lRow1=g.lRows(g.csrY);
       endif;
       g.lastProcessed=g.lRow1;
     p                 e
      // -----------------------------------------------------------------------
      // Enter
      // -----------------------------------------------------------------------
     pEnter            b
     d enter           pi
      *
     d lRow            s               *
     d fScreenToRefresh...
     d                 s               n    inz(*off)
     d l4i             ds                  based(pL4i) likeDs(tL4i)
       lRow=tree_getFirst(g.lRoot);
       dow lRow<>*null;
         if tree_getOption(lRow)='d';
           tree_OpenLink(lRow);
           tree_setOption(lRow:'  ');
           g.lRow1_b4=*null;
           g.lastProcessed=lRow;
         elseif tree_getOption(lRow)='r';
           tree_CloseLink(lRow);
           tree_setOption(lRow:'  ');
           g.lRow1_b4=*null;
           g.lastProcessed=lRow;
         elseif tree_getOption(lRow)='5';
           pL4i=tree_getItem(lRow);
           log4i=l4i.log4i;
           dww_display(pgmsts.pgmID:'5');
           tree_setOption(lRow:'  ');
           fScreenToRefresh=*on;
           g.lRow1_b4=*null;
           g.lastProcessed=lRow;
         endIf;
         lRow=tree_getNextToDisplay(g.lRoot:lRow);
       endDo;
       if fScreenToRefresh;
         initScreen1();
       endIf;
     p                 e
