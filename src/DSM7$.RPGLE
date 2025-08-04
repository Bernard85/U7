       ctl-opt DFTACTGRP(*NO) bnddir('DSM7':'U7');
      /copy cpy,U7IBM_H
      /copy cpy,dsm7_h
      /copy cpy,QSNAPI_H
      /copy cpy,u7tree_H
      /copy cpy,u7msg_H
      // link for all screens
     d lScreens        s               *
     d lScreen1        s               *
     d lHeader         s               *
     d lBody           s               *
     d lFooter         s               *
      // to fill the sample
     d  lSample        s               *
      // to define the sample
        lSample=tree_getNewLink(*null);
        tree_SetOption(lSample:'91');
      // to register the screen
        lScreen1=dsm_setScreen(lScreens
                              :'SCREEN1'
                              :%pAddr(getter)
                              :%pAddr(setter)
                              :*null);
      // to register the area for title
        lHeader=dsm_setArea(lScreen1:'HEADER'
                                   :1:1
                                   :3:132
                                   :%pAddr(Header));
        lBody=dsm_setArea(lScreen1:'BODY'
                                  :4:1
                                  :10:132
                                  :%pAddr(Body));
        lFooter=dsm_setArea(lScreen1:'FOOTER'
                                   :26:1
                                   :1:123
                                   :%pAddr(Footer));
      // set function key
       dsm_setFK(lScreen1:Qsn_Enter:'0':%pAddr(Enter));
       dsm_setFK(lScreen1:Qsn_F3   :'0':%pAddr(F3) :'F3=Exit');
       dsm_setFK(lScreen1:Qsn_F11  :'0':%pAddr(F11):'F11=French'
                                                   :'F11=Anglais');
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
       if dsm_getFKC(lScreens:Qsn_F11)='0';
       dsm_println(lHeader:qsn_sa_blu:'Type options, press Enter');
       else;
       dsm_println(lHeader:qsn_sa_blu:'Saisir options et appuyer sur Entr e');
       endif;
     p                 e
      // ----------------------------------------------------------------------
      // Body
      // ----------------------------------------------------------------------
     pBody             b
     d Body            pi
     d  lBody                          *   const
       dsm_print     (lBody:qsn_sa_grn:'Input field :');
       dsm_printFld(lBody:2:lSample:'o':tree_getOption(lSample):*on);
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
        return tree_getOption(lSample);
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
      // F11=Fran ais/English
      // ----------------------------------------------------------------------
     pF11              b
       dsm_AreaRefresh(lHeader);
       dsm_AreaRefresh(lFooter);
     p                 e
