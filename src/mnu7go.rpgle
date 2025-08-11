       ctl-opt DFTACTGRP(*NO) bnddir('DSM7':'U7':'MNU7');
      /copy cpy,U7IBM_H
      /copy cpy,dsm7_h
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
      // to load the menu
       lMnus=xml_Xml2Tree('/home/bernard85/U7/mnu/mnumain.mnu'
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
       dsm_setFK(lScreen1:Qsn_RollUp:'0':%pAddr(RollUp));
       dsm_setFK(lScreen1:Qsn_RollDown:'0':%pAddr(RollDown));
       // launch
       dsm_go(pgmID
             :lScreens
             :'SCREEN1');
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
       lRow=lRow1;
       dow lRow<>*null
       and i<18;
         lRow9=lRow;
         dsm_SetPos(lBody:*omit:tree_getLevel(lRow)*2);
         dsm_printFld(lBody:1:lRow:'o');
         if tree_isOfTheKind(kMnu:lRow:pMnu);
           dsm_printLN(lBody:qsn_sa_wht:mnu.text);
         elseif tree_isOfTheKind(kCmd:lRow:pCmd);
           dsm_printLN(lBody:qsn_sa_grn:cmd.text);
         endIf;
         lRow=tree_getNextToDisplay(lMnus:lRow);
         i+=1;
       endDo;
     p                 e
      // -----------------------------------------------------------------------
      // Print Parent
      // -----------------------------------------------------------------------
     pPrintParent      b
     d printParent     pi
     d  rootLevel                     3u 0 const
     d  lChild                         *   const
     d  lBody                          *   const
      *
     d lParent         s               *
     d mnu             ds                  likeDs(tMnu) based(pMnu)
       lParent=tree_getParentToDisplay(lMnus:lChild);
       if lParent<>*null;
         printParent(rootLevel:lParent:lBody);
         pMnu=tree_getItem(lChild);
         dsm_SetPos(lBody:*omit:tree_getLevel(lChild)*2);
         dsm_printFld(lBody:1:lChild:'o');
         dsm_printLn (lBody:qsn_sa_wht:mnu.text);
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
        error=*off;
        return tree_getOption(lAny);
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
     d cmd             s            200    varying
       cmd='STRSEU SRCFILE(BERNARD85/XSCRIPT) SRCMBR(@FIRST) OPTION(5)';
       qcmdexc(cmd:%len(cmd));
       Dsm_ClrScr();
       dsm_refresh(lScreens);
     p                 e
      // ----------------------------------------------------------------------
      // F3=Exit
      // ----------------------------------------------------------------------
     pF3               b
       dsm_setCurScreen(lScreens:'*NOSCREEN');
     p                 e
      // ----------------------------------------------------------------------
      // RollUp
      // ----------------------------------------------------------------------
     pRollUp           b
       if tree_getNext(lRow9)=*null;
         msg_SndPM(pgmsts.pgmID:'You have reached the bottom of the list');
       else;
         lRow1=tree_getNext(lRow9);
         Dsm_ClrScr();
         dsm_AreaRefresh(lBody);
       endIf;
     p                 e
