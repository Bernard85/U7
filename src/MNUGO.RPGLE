       ctl-opt DFTACTGRP(*NO) bnddir('U7':'MNU7':'DSM6') actgrp('A7');
      /copy cpy,u7env_h
      /copy cpy,u7ibm_h
      /copy cpy,u7screen_h
      /copy cpy,u7msg_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,mnu7_h
      /copy cpy,u7form_h
      /copy cpy,dsm6_h
      /copy cpy,QSNAPI_H
      // --------------------------------------------------------------------
      // global variables
      // --------------------------------------------------------------------
       dcl-ds g qualified;
         lRootMnu      pointer;
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
     d space           s            100a   inz('')
      // --------------------------------------------------------------------
      // main
      // --------------------------------------------------------------------
       dcl-pi mnuGo;
         mnuID char(10);
       end-pi;
       // Load the shell
       g.lShell=dsm_getShell(g.lShells:'SHELL2');
       g.lTITLE     =dsm_getLayout(g.lShell:'TITLE'     :1 :1  :2 :132);
       g.lHEADER    =dsm_getLayout(g.lShell:'HEADER'    :3 :1  :3 :132);
       g.lLIST      =dsm_getLayout(g.lShell:'LIST'      :6 :1  :20:132);
       g.lFOOTER    =dsm_getLayout(g.lShell:'FOOTER'    :26:1  :1 :100);
       g.lFOOTERLEFT=dsm_getLayout(g.lShell:'FOOTERLEFT':26:120:1 :7);
       // load the menu tree from xml
       g.lRootMnu=xml_Xml2Tree(env_getAppliPath+'mnu/'+%trim(MnuId)+'.mnu'
                              :%pAddr(mnu_XmlInput));
       g.lRow1   =tree_getFirst(g.lRootMnu);
       // Load function keys
       screen_setFK(g.lFKs:Qsn_F3      :'0':%pAddr(F3)      :'F3=Exit'        );
       screen_setFK(g.lFKs:Qsn_F10     :'1':%pAddr(F10)     :'F10=Move to top');
       screen_setFK(g.lFKs:Qsn_RollDown:'1':%pAddr(RollDown)                  );
       screen_setFK(g.lFKs:Qsn_RollUp  :'1':%pAddr(RollUp)                    );
       screen_setFK(g.lFKs:Qsn_Enter   :'1':%pAddr(Enter)                     );
       // Load options
       screen_SetOption(g.lOpts:'+':'+=Develop');
       screen_SetOption(g.lOpts:'-':'-=Reduce');
       screen_SetOption(g.lOpts:'1':'1=Select');
       // Init the screen 1
       initScreen1();
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
      // display screen
      // --------------------------------------------------------------------
     p initScreen1     b
     d initScreen1     pi
     d w132a           s            132a
     d p               s              3u 0
     d FKs             s            100a
     d OPs             s            100a
     d rootMnu         ds                  likeDs(tMnu) based(pRootMnu)
       //
       dsm_clrscr();
       //
       pRootMnu=tree_getItem(g.lRootMnu);
       p=(132-%len(rootMnu.text))/2;
       %subst(w132a:p)=rootMnu.text;
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
     d mnu             ds                  likeDs(tMnu) based(pMnu)
     d cmd             ds                  likeDs(tCmd) based(pCmd)
     d choice          s              1a
     d link            ds                  likeDs(tLink) based(pLink)
     d y               s              3u 0
      /copy cpy,U7TREE_S
       clear g.lRows;
       dsm_initShell(g.lShell);
       dsm_initLayout(g.lList);
       // synchronize the 1st row
       tree_syncFirstRowToDisplay(g.lRow1);
       lRow=g.lRow1;
       rootLevel=tree_getLevel(g.lRootMnu);
       // print parent
       printParent(rootLevel:lRow);
       // loops on row
       dow lRow<>*null
       and dsm_canPrint(g.lList);
         margin=%subst(space:1:1+(tree_getLevel(lRow)-rootLevel-1)*2);
         dsm_print(g.lList:qsn_sa_wht:margin);
         choice=tree_getOption(lRow);
         dsm_printFld(g.lList:qsn_sa_grn_ul:QSN_FFW_ALPHA_SHIFT:choice:lRow);
         if tree_isOfTheKind(kMnu:lRow:pMnu);
           dsm_printLN(g.lList:qsn_sa_wht:mnu.text:y);
         elseif tree_isOfTheKind(kCmd:lRow:pCmd);
           dsm_printLN(g.lList:qsn_sa_grn:cmd.text:y);
         endIf;
         g.lRows(y)=lRow;
         g.lRow9=lRow;
         lRow=tree_getNextToDisplay(g.lRootMnu:lRow);
       endDo;
       // to clear the remain of the layout
       dsm_padLayout(g.lList);
     p                 e
      // -----------------------------------------------------------------------
      // synchronize the 1st row
      // -----------------------------------------------------------------------
     ptree_syncFirstRowToDisplay...
     p                 b
     dtree_syncFirstRowToDisplay...
     d                 pi
     d  lRow1                          *
       dow tree_getParentToDisplay(g.lRootMnu:lRow1)
          =tree_getPrevToDisplay  (g.lRootMnu:lRow1)
       and tree_getPrevToDisplay  (g.lRootMnu:lRow1)<>*null;
         lRow1=tree_getParentToDisplay(g.lRootMnu:lRow1);
       endDo;
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
     d mnu             ds                  likeDs(tMnu) based(pMnu)
     d margin          s             20a   varying
     d choice          s              1a
     d y               s              3u 0
       lParent=tree_getParentToDisplay(g.lRootMnu:lChild);
       if lParent<>*null;
         printParent(rootLevel:lParent);
         margin=%subst(space:1:1+(tree_getLevel(lParent)-rootLevel-1)*2);
         dsm_print(g.lList:qsn_sa_wht:margin);
         choice=tree_getOption(lParent);
         dsm_printFld(g.lList:qsn_sa_grn_ul:QSN_FFW_ALPHA_SHIFT:choice:lParent);
         if tree_isOfTheKind(kMnu:lParent:pMnu);
           dsm_printLN(g.lList:qsn_sa_wht:mnu.text:y);
         endIf;
         g.lRows(y)=lParent;
       endIf;
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
        if tree_isOfTheKind(kMnu:lRow)
       and %scan(choice:'+- ')=0;
         msg_SndPM(pgmsts.pgmID:'Choice "'+choice+'" on menu is not allowed');
         return *on;
       elseif tree_isOfTheKind(kCmd:lRow)
          and %scan(choice:'1 ')=0;
         msg_SndPM(pgmsts.pgmID
                  :'Choice "'+choice+'" on command is not allowed');
         return *on;
       endIf;
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
      // F10=Move to top
      // -----------------------------------------------------------------------
     pf10              b
     d f10             pi
       if g.lRows(g.csrY)<>*null;
         g.lRow1=g.lRows(g.csrY);
         return;
       endIf;
       msg_SndPM(pgmSts.pgmID:'Wrong cursor position.');
     p                 e
      // -----------------------------------------------------------------------
      // RollDown
      // -----------------------------------------------------------------------
     pRollDown         b
     d RollDown        pi
      *
     d rootLevel       s              3u 0
     d lRow            s               *
     d count           s              3u 0 inz(0)
       rootLevel=tree_getLevel(g.lRootMnu);
       if g.lRow1=tree_getFirst(g.lRootMnu);
         msg_SndPM(pgmSts.pgmID:'You have reached the top of the list.');
         return;
       endIf;
       lRow=tree_getPrevToDisplay(g.lRootMnu:g.lRow1);
       dow lRow<>*null;
         g.lRow1=lRow;
         count+=1;
         if count+tree_getLevel(lRow)-rootLevel>20;
           return;
         endIf;
         lRow=tree_getPrevToDisplay(g.lRootMnu:lRow);
       endDo;
     p                 e
      // -----------------------------------------------------------------------
      // RollUp
      // -----------------------------------------------------------------------
     pRollUp           b
     d RollUp          pi
      *
     d lNext           s               *
       lNext=tree_getNextToDisplay(g.lRootMnu:g.lRow9);
       if lNext=*null;
         msg_SndPM(pgmSts.pgmID:'You have reached the bottom of the list.');
       else;
         g.lRow1=lNext;
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // Enter
      // -----------------------------------------------------------------------
     pEnter            b
     d enter           pi
      *
     d lRow            s               *
     d cmd             ds                   likeDs(tCmd) based(pCmd)
     d fScreenToRefresh...
     d                 s               n    inz(*off)
       lRow=tree_getFirst(g.lRootMnu);
       dow lRow<>*null;
         if tree_getOption(lRow)='+';
           tree_OpenLink(lRow);
           tree_setOption(lRow:'  ');
           g.lRow1_b4=*null;
           g.lastProcessed=lRow;
         elseif tree_getOption(lRow)='-';
           tree_CloseLink(lRow);
           tree_setOption(lRow:'  ');
           g.lRow1_b4=*null;
           g.lastProcessed=lRow;
         elseif tree_getOption(lRow)='1';
           pCmd=tree_getItem(lRow);
           qcmdexc(cmd.order:%len(cmd.order));
           tree_setOption(lRow:'  ');
           g.lRow1_b4=*null;
           fScreenToRefresh=*on;
           g.lastProcessed=lRow;
         endIf;
         lRow=tree_getNextToDisplay(g.lRootMnu:lRow);
       endDo;
       if fScreenToRefresh;
         initScreen1();
       endIf;
     p                 e
