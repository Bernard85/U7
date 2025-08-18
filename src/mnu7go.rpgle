       ctl-opt DFTACTGRP(*NO) bnddir('DSM7':'U7':'MNU7');
      /copy cpy,U7IBM_H
      /copy cpy,dsm7_h
      /copy cpy,u7env_h
      /copy cpy,mnu7_h
      /copy cpy,QSNAPI_H
      /copy cpy,u7tree_H
      /copy cpy,u7msg_H
      /copy cpy,u7xml_H
      // link for all screens
     d lScreens        s               *
     d lScreen1        s               *
     d lBody           s               *
      // to fill the sample
     d  lMnus          s               *
     d  lRow1          s               *
     d  lRow9          s               *
     d  csry           s             10i 0
     d  csrx           s             10i 0
     d  lastProcessed  s               *
     dMnu7Go           pi
     d MnuID                         10a
      // to load the menu
       lMnus=xml_Xml2Tree(env_getClientPath()+'mnu/'+%trim(mnuID)+'.mnu'
                         :%pAddr(mnu_XmlInput));
       lRow1=tree_getFirst(lMnus);
       // to register the screen
       lScreen1=dsm_setScreen(lScreens
                              :'SCREEN1'
                              :%pAddr(getter)
                              :%pAddr(setter)
                              :*null);
       // to register the area for title
       dsm_setArea(lScreen1:'HEADER'
                           :1:1
                           :4:132
                           :%pAddr(Header));
       lBody=dsm_setArea(lScreen1:'BODY'
                           :5:1
                           :22:132
                           :%pAddr(Body));
       dsm_setArea(lScreen1:'FOOTER'
                           :26:1
                           :1:130
                           :%pAddr(Footer));
       // set function key
       dsm_setFK(lScreen1:Qsn_Enter :'0':%pAddr(Enter));
       dsm_setFK(lScreen1:Qsn_F3    :'0':%pAddr(F3) :'F3=Exit');
       dsm_setFK(lScreen1:Qsn_F10:'0':%pAddr(F10):'F10=Move to top');
       dsm_setFK(lScreen1:Qsn_RollUp:'0':%pAddr(RollUp));
       dsm_setFK(lScreen1:Qsn_RollDown:'0':%pAddr(RollDown));
       // 1st message
       msg_SndPM(pgmsts.pgmID:env_getWelcomeMessage());
       // launch
       dsm_go(pgmID
             :lScreens
             :'SCREEN1'
             :csrY:csrX
             :lastProcessed);
      // end
       *inlr=*on;
      // ----------------------------------------------------------------------
      // Header
      // ----------------------------------------------------------------------
     pHeader           b
     d Header          pi
     d  lHeader                        *   const
     d mnus            ds                  likeds(tMnu) based(pMnus)
       pMnus=tree_getItem(lMnus);

       dsm_setPos(lHeader:*omit:(132-%len(Mnus.text))/2);
       dsm_println(lHeader:qsn_sa_wht:Mnus.text);

       dsm_printLn(lHeader:qsn_sa_blu:'Type options, press Enter');

       dsm_print(lHeader:qsn_sa_blu:'   +=Develop');
       dsm_print(lHeader:qsn_sa_blu: ' -=Reduce');
       dsm_print(lHeader:qsn_sa_blu: ' 1=Select');
     p                 e
      // ----------------------------------------------------------------------
      // Body
      // ----------------------------------------------------------------------
     pBody             b
     d Body            pi
     d  lBody                          *   const
      *
     d mnu             ds                  likeDs(tMnu) based(pMnu)
     d cmd             ds                  likeDs(tCmd) based(pCmd)
     d lRow            s               *
     d i               s              3u 0 inz(0)
       printParent(lRow1:lBody:i);
       lRow=lRow1;
       dow lRow<>*null
       and i<21;
         lRow9=lRow;
         dsm_SetPos(lBody:*omit:tree_getLevel(lRow)*2-2);

         if tree_isOpen(lRow) and tree_isOfTheKind(kMnu:lRow);
           dsm_print(lBody:qsn_sa_grn:'-');
         elseif tree_isOfTheKind(kMnu:lRow);
           dsm_print(lBody:qsn_sa_grn:'+');
         else;
           dsm_print(lBody:qsn_sa_grn:' ');
         endIf;

         dsm_printFld(lBody:1:lRow:'o');
         if tree_isOfTheKind(kMnu:lRow:pMnu);
           dsm_printLN(lBody:qsn_sa_wht:mnu.text);
         elseif tree_isOfTheKind(kCmd:lRow:pCmd);
           dsm_printLN(lBody:qsn_sa_grn:cmd.text);
         endIf;
         lRow=tree_getNextToDisplay(lMnus:lRow);
         i+=1;
       endDo;
       dsm_SetPos(lBody:20:100);
       if tree_getNextToDisplay(lMnus:lRow9)=*null;
         dsm_print(lBody:qsn_sa_wht: 'Bottom');
       else;
         dsm_print(lBody:qsn_sa_wht:'More...');
       endif;
     p                 e
      // -----------------------------------------------------------------------
      // Print Parent
      // -----------------------------------------------------------------------
     pPrintParent      b
     d printParent     pi
     d  lChild                         *   const
     d  lBody                          *   const
     d  i                             3u 0
      *
     d lParent         s               *
     d mnu             ds                  likeDs(tMnu) based(pMnu)
       lParent=tree_getParentToDisplay(lMnus:lChild);
       if lParent<>*null;
         printParent(lParent:lBody:i);
         i+=1;
         pMnu=tree_getItem(lParent);
         dsm_SetPos(lBody:*omit:tree_getLevel(lParent)*2-2);

         if tree_isOpen(lParent);
           dsm_print(lBody:qsn_sa_grn:'-');
         else;
           dsm_print(lBody:qsn_sa_grn:'+');
         endIf;

         dsm_printFld(lBody:1:lParent:'o');
         dsm_printLn(lBody:qsn_sa_wht:mnu.text);
       endIf;
     p                 e
      // ----------------------------------------------------------------------
      // getter
      // ----------------------------------------------------------------------
     pgetter           b
     d getter          pi           255a
     d  lAny                           *   const
     d  iAny                          1a   const
     d  error                          n
      *
     d  w2             s              2a
        error=*off;
        w2=tree_getOption(lAny);
        return w2;
     p                 e
      // ----------------------------------------------------------------------
      // setter
      // ----------------------------------------------------------------------
     psetter           b
     d setter          pi
     d  lAny                           *   const
     d  iAny                          1a   const
     d  fldVal                      255a   const
        tree_setOption(lAny:fldVal);
     p                 e
      // ----------------------------------------------------------------------
      // Footer
      // ----------------------------------------------------------------------
     pFooter           b
     d Footer          pi
     d  lFooter                        *   const
       dsm_println(lFooter:qsn_sa_blu:dsm_getFKText(lScreens));
     p                 e
      // ----------------------------------------------------------------------
      // Enter
      // ----------------------------------------------------------------------
     pEnter            b
     d lRow            s               *
     d option          s              1
     d cmd             ds                  likeDs(tCmd) based(pCmd)
     d fScrToClr       s               n   inz(*off)
       lRow=tree_getFirst(lMnus);
       dow lRow<>*null;
         option=tree_getOption(lRow);
         if tree_isOfTheKind(kMnu:lRow);
           if option ='+';
             tree_openLink(lRow);
             lastProcessed=lRow;
           elseif option='-';
             tree_CloseLink(lRow);
             lastProcessed=lRow;
           endIf;
         elseif tree_isOfTheKind(kCmd:lRow:pCmd)
            and option='1';
           qcmdexc(cmd.order:%len(cmd.order));
           fScrToClr=*on;
             lastProcessed=lRow;
         endIf;
         tree_setOption(lRow:'');
         lRow=tree_getNextToDisplay(lMnus:lRow);
       endDo;
       if fScrToClr=*on;
         Dsm_ClrScr(lScreen1);
       endIf;
       dsm_AreaToRefresh(lBody);
     p                 e
      // ----------------------------------------------------------------------
      // F3=Exit
      // ----------------------------------------------------------------------
     pF3               b
       dsm_setCurScreen(lScreens:'*NOSCREEN');
       // Save the tree in XML
       xml_tree2XML(env_getClientPath()+'mnu/'+%trim(mnuID)+'.mnu'
                   :lMnus
                   :%paddr(mnu_XmlOutput));
     p                 e
      // ----------------------------------------------------------------------
      // RollUp
      // ----------------------------------------------------------------------
     pRollUp           b
       if tree_getNext(lRow9)=*null;
         msg_SndPM(pgmsts.pgmID:'You have reached the bottom of the list');
       else;
         lRow1=tree_getNext(lRow9);
         dsm_AreaToRefresh(lBody);
       endIf;
     p                 e
      // ----------------------------------------------------------------------
      // RollDown
      // ----------------------------------------------------------------------
     pRollDown         b
      *
     d lRow            s               *
     d i               s              3u 0 inz(0)
       if tree_getPrevToDisplay(lMnus:lRow1)=*null;
         msg_SndPM(pgmsts.pgmID:'You have reached the top of the list');
       else;
         lRow=tree_getPrevToDisplay(lMnus:lRow1);
         dow lRow<>*null
         and i<21;
           lRow1=lRow;
           i+=1;
           lRow=tree_getPrevToDisplay(lMnus:lRow);
         endDo;
       endIf;
       dsm_AreaToRefresh(lBody);
     p                 e
      // ----------------------------------------------------------------------
      // F10
      // ----------------------------------------------------------------------
     pF10              b
      *
     d lRow            s               *
       lastProcessed=dsm_getNearest(lScreen1:csrY:csrX);
       if lastProcessed=*null;
         msg_SndPM(pgmsts.pgmID:'Wrong cursor position.');
       else;
         lRow1=lastProcessed;
         dsm_AreaToRefresh(lBody);
       endIf;
     p                 e
