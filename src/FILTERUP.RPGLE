     H DFTACTGRP(*NO) bnddir('U7') actgrp('A7')
     FFilterupd CF   E             WORKSTN SFILE(SFL1:SFL1RRN) InfDS(wsDS)
     F                                     SFILE(SFL2:SFL2RRN)
      /copy cpy,u7Ibm_h
      /copy cpy,u7env_h
      /copy cpy,u7filter_h
      /copy cpy,u7ifs_h
      /copy cpy,u7index_h
      /copy cpy,u7jrn_h
      /copy cpy,u7msg_h
      /copy cpy,u7screen_h
      /copy cpy,u7Stat_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      // --------------------------------------------------------------------
      // main
      // --------------------------------------------------------------------
       dcl-pi FilterUP;
         rtnCode  int(3) ;
         lStats   pointer const;
         lFilters pointer const;
       end-pi;
      // Global fields (screen 1)
       dcl-ds G1 qualified;
         screen    uns(3)  inz(1);
         fRefresh  ind    ;
         lStat     pointer dim(18) inz(*null);
         lStat1    pointer inz(*null);
         lStat1_b4 pointer inz(*null);
         lStat9    pointer inz(*null);
         lStat9_b4 pointer inz(*null);
         lOpts     pointer inz(*null);
         lFKs      pointer inz(*null);
         fChange   ind     inz(*off);
       end-ds;
      // Global fields (screen 2)
       dcl-ds G2 qualified;
         screen     uns(3)  inz(2);
         lStat      pointer;
         change     ind    ;
         lModel     pointer dim(18) inz(*null);
         lModel1    pointer inz(*null);
         lModel1_b4 pointer inz(*null);
         lModel9    pointer inz(*null);
         lModel9_b4 pointer inz(*null);
         lOpts      pointer inz(*null);
         lFKs       pointer inz(*null);
         fChange    ind     inz(*off);
       end-ds;
       dcl-s lFilter pointer;
       dcl-ds Filter likeDs(tFilter) based(pFilter);
       dcl-s lModel pointer;
       dcl-ds Model likeDs(tModel) based(pModel);
       dcl-s fOmit ind;
       dcl-c iOmit 7;
       // Title
       ZTL1='Select filters';
       // Load function keys
       screen_setFK(g1.lFKs:x'3a':'1':%pAddr(f10_1):'F10=Move to top');
       screen_setFK(g1.lFKs:x'f1':'1':%pAddr(Enter_1));
       screen_setFK(g1.lFKs:x'f4':*ON :%pAddr(rollUP_1));
       screen_setFK(g1.lFKs:x'f5':*ON :%pAddr(rolldown_1));
       zFK1=screen_getfkentitle(g1.lFKs);
       // Load options
       screen_SetOption(g1.lOpts:'1':'1=Select');
       zCH1=screen_getChoicesEntitle(g1.lOpts);
       zHdr1='Opt -- ID -----'
           +' -- Text ------------------------------------------'
           +' Models'
           +'     Items';
       // load items
       g1.lStat1=tree_getFirst(lStats);
       // count stats
       countStats();
       wrkScreen_1();
       *inlr=*on;
      // --------------------------------------------------------------------
      // Screen 1 - work screen
      // --------------------------------------------------------------------
       dcl-proc  wrkScreen_1;
       dow g1.screen>0;
         if g1.screen=1;
           Screen_1();
         endif;
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - display items
      // --------------------------------------------------------------------
       dcl-proc  Screen_1;
       // more item or bottom of list
       if g1.lStat9<>g1.lStat9_b4;
         sync_1();
       endIf;
       if g1.lStat1<>g1.lStat1_b4 or g1.fRefresh;
         loadWA_1();
         loadsfl_1();
         // more item or bottom of list
         screen_setSflEnd(mySfl1End:tree_getNext(g1.lStat9)=*null);
       endIf;
       // display activation
       write msgCtl;
       write hdr1;
       *in88=*on;
       *in89=*off;
       exfmt ctl1;
       // sweep error and messages
       msg_rmvPM(pgmID);
       g1.fRefresh=*off;
       g1.fChange=*off;
       // get/launch function key
       screen_processFK(pgmID:g1.lFKs:wsds.kp:%pAddr(Control_1));
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - inventoried models
      // --------------------------------------------------------------------
       dcl-proc  Control_1;
       dcl-pi Control_1 ind;
       end-pi;
      *
       dcl-s fError ind inz(*off);
       readc sfl1;
       dow not %eof();
         g1.fChange=*on;
         *in02=*off;
         tree_SetOption(g1.lStat(SFL1RRN):xChoice1);
         if %scan(xChoice1:' 1')=0;
           fError=*on;
           msg_SndPM(pgmID:'Option "'+xChoice1+'" is not valid');
           *in02=*on;
         endif;
         //
         update sfl1;
         readc sfl1;
       enddo;
       return fError;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - Load work area
      // --------------------------------------------------------------------
       dcl-proc  loadWA_1;
      *
       dcl-s lStat pointer;
       dcl-s i     uns(3) ;
       clear g1.lStat;
       lStat=g1.lStat1;
       for i=1 to 18;
         g1.lStat(i)=lStat;
         g1.lStat9=lStat;
         lStat=tree_getNext(lStat);
       endFor;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - Load subfile
      // --------------------------------------------------------------------
       dcl-proc  loadsfl_1;
      *
       dcl-ds stat likeDs(tStat) based(pStat);
       // clear subfile
       *in88=*off;
       *in89=*on;
       WRITE ctl1;
       // Reload subfile
       for SFL1RRN=1 to 18;
         if g1.lStat(SFL1RRN)=*null;
           leave;
         endIf;
         xChoice1=tree_getOption(g1.lStat(SFL1RRN));
         pStat =tree_getItem(g1.lStat(SFL1RRN));
         xFil1='';
         %subst(xFil1:1)=stat.ID;
         %subst(xFil1:13)=stat.text;
         %subst(xFil1:64)=%trim(%char(stat.modelsSelect))
                         +' / '
                         +%trim(%char(stat.modelsCount));
         %subst(xFil1:75)=%trim(%char(stat.itemsSelect))
                         +' / '
                         +%trim(%char(stat.itemsCount));
         write sfl1;
       endFor;
       g1.lStat1_b4=g1.lStat1;
       g1.lStat9_b4=g1.lStat9;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - Roll-up
      // --------------------------------------------------------------------
       dcl-proc  RollUp_1;
       dcl-pi Rollup_1;
       end-pi;
       if g1.lStat1=tree_GetFirst(lStats);
         msg_SndPM(pgmID:'You have reached the top of the list');
       else;
         g1.lStat9=tree_getPrev(g1.lStat1);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - Roll-down
      // --------------------------------------------------------------------
       dcl-proc  RollDown_1;
       dcl-pi RollDown_1;
       end-pi;
       if mySfl1End='Bottom';
         msg_SndPM(pgmID:'You have reached the bottom of the list');
       else;
         g1.lStat1=tree_getNext(g1.lStat9);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - Enter
      // --------------------------------------------------------------------
       dcl-proc  Enter_1;
       dcl-pi Enter_1;
       end-pi;
      *
       dcl-s rtnCode int(3)  inz(0);
       dcl-s lStat   pointer;
       lStat=tree_getFirst(lStats);
       dow lStat<>*null;
         if tree_getOption(lStat)='1';
           g1.fChange=*on;
           filter1UP(rtncode:lStat:lFilters);
           if rtnCode=3;
             return;
           endIf;
           tree_setOption(lStat:'');
           countStat(lStat);
           g1.fRefresh=*on;
         endIf;
         lStat=tree_getNext(lStat);
       endDo;
       if not g1.fChange;
         g1.screen=0;
         rtncode=6;
       endif;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - F10=Move to top
      // --------------------------------------------------------------------
       dcl-proc  f10_1;
       dcl-pi f10_1;
       end-pi;
       if SFL1CSRRRN=0;
         msg_SndPM(pgmID:'Wrong cursor position');
       else;
         g1.lStat1=g1.lStat(SFL1CSRRRN);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - Synch
      // --------------------------------------------------------------------
       dcl-proc  Sync_1;
       dcl-pi Sync_1;
       end-pi;
      *
       dcl-s i  uns(3) ;
       dcl-s lX pointer;
       for i=1 to 18;
         lX=tree_getPrev(g1.lStat1);
         if lX=*null;
           leave;
         endIf;
         g1.lStat1=lX;
       endFor;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 - main
      // --------------------------------------------------------------------
       dcl-proc  filter1UP;
       dcl-pi Filter1UP;
         rtnCode  int(3) ;
         lStat    pointer const;
         lfilters pointer const;
       end-pi;
      *
       dcl-ds stat likeds(tStat) based(pStat);
       dcl-s lFilter pointer;
       g2.lStat=lStat;
       pStat=tree_getItem(lStat);
       lFilter=tree_getLinkFromList(lFilters:kFilter:stat.ID);
       // sweep all items to see if it is omit or not
       lModel=tree_getFirst(g2.lStat);
       dow lModel<>*null;
         pModel=tree_getItem(lModel);
         fOmit=tree_getLinkFromList(lFilter:kOmit:Model.ID)<>*null;
         if not fOmit;
           tree_setOption(lModel:'S');
         endIf;
         tree_setFlag(lModel:iOmit:fOmit);
         lModel=tree_getNext(lModel);
       endDo;
       // Title
       ZTL2='Update filter '+stat.text;
       // Load function keys
       screen_setFK(g2.lFKs:x'33':'0':%pAddr(F3_2):'F3=Exit');
       screen_setFK(g2.lFKs:x'3a':'1':%pAddr(f10_2):'F10=Move to top');
       screen_setFK(g2.lFKs:x'f1':'1':%pAddr(Enter_2));
       screen_setFK(g2.lFKs:x'f4':*ON :%pAddr(rollUP_2));
       screen_setFK(g2.lFKs:x'f5':*ON :%pAddr(rolldown_2));
       zFK2=screen_getfkentitle(g2.lFKs);
       // Load options
       tree_dealloc(g2.lOpts);
       screen_SetOption(g2.lOpts:'S':'S=Select');
       zCH2=screen_getChoicesEntitle(g2.lOpts);
       zHdr2='Opt -- ID -----'
            +' -- Text ------------------------------------------'
            +' Items';
       // load items
       g2.lModel1=tree_getFirst(lStat);
       wrkScreen_2();
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 - work screen
      // --------------------------------------------------------------------
       dcl-proc  wrkScreen_2;
       g2.screen=2;
       dow g2.screen>0;
         if g2.screen=2;
           Screen2();
         endif;
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 - display items
      // --------------------------------------------------------------------
       dcl-proc  Screen2;
       // more item or bottom of list
       if g2.lModel9<>g2.lModel9_b4;
         sync_2();
       endIf;
       if g2.lModel1<>g2.lModel1_b4;
         loadWA_2();
         loadsfl_2();
         // more item or bottom of list
         screen_setSflEnd(mySfl2End:tree_getNext(g2.lModel9)=*null);
       endIf;
       // display activation
       write msgCtl;
       write hdr2;
       *in88=*on;
       *in89=*off;
       exfmt ctl2;
       // sweep error and messages
       msg_rmvPM(pgmID);
       g2.fChange=*off;
       // get/launch function key
       screen_processFK(pgmID:g2.lFKs:wsds.kp:%pAddr(Control_2));
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 - To select models
      // --------------------------------------------------------------------
       dcl-proc  Control_2;
       dcl-pi Control_2 ind;
       end-pi;
      *
       dcl-ds Model likeDs(tModel) based(pModel);
       dcl-s fError ind inz(*off);
       readc sfl2;
       dow not %eof();
         *in02=*off;
         g2.fChange=*on;
         pModel=tree_getitem(g2.lModel(SFL2RRN));
         tree_SetOption(g2.lModel(SFL2RRN):xChoice2);
         if %scan(xChoice2:' S')=0;
           ferror=*on;
           msg_SndPM(pgmID:'Option "'+xChoice2+'" is not valid');
           *in02=*on;
         endif;
         //
         tree_setFlag(g2.lModel(SFL2RRN):iOmit:not(xChoice2='S'));
         update sfl2;
         readc sfl2;
       enddo;
       return ferror;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 - Load work area
      // --------------------------------------------------------------------
       dcl-proc  loadWA_2;
      *
       dcl-s lModel pointer;
       dcl-s i      uns(3) ;
       clear g2.lModel;
       lModel=g2.lModel1;
       for i=1 to 18;
         g2.lModel(i)=lModel;
         g2.lModel9=lModel;
         lModel=tree_getNext(lModel);
       endFor;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 -  load subfile
      // --------------------------------------------------------------------
       dcl-proc  loadsfl_2;
      *
       dcl-ds Model likeDs(tModel) based(pModel);
       // clear subfile
       *in88=*off;
       *in89=*on;
       WRITE ctl2;
       // Reload subfile
       for SFL2RRN=1 to 18;
         if g2.lModel(SFL2RRN)=*null;
           leave;
         endIf;
         xChoice2=tree_getOption(g2.lModel(SFL2RRN));
         pModel =tree_getItem(g2.lModel(SFL2RRN));
         xFil2='';
         %subst(xFil2:1)=Model.ID;
         %subst(xFil2:13)=Model.text;
         %subst(xFil2:64)=%trim(%char(Model.itemsCount));
         write sfl2;
       endFor;
       g2.lModel1_b4=g2.lModel1;
       g2.lModel9_b4=g2.lModel9;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 - Roll-UP
      // --------------------------------------------------------------------
       dcl-proc  RollUp_2;
       dcl-pi Rollup_2;
       end-pi;
       if g2.lModel1=tree_GetFirst(g2.lStat);
         msg_SndPM(pgmID:'You have reached the top of the list');
       else;
         g2.lModel9=tree_getPrev(g2.lModel1);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 - Roll-down
      // --------------------------------------------------------------------
       dcl-proc  RollDown_2;
       dcl-pi RollDown_2;
       end-pi;
       if mySfl2End='Bottom';
         msg_SndPM(pgmID:'You have reached the bottom of the list');
       else;
         g2.lModel1=tree_getNext(g2.lModel9);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 - Enter
      // --------------------------------------------------------------------
       dcl-proc  Enter_2;
       dcl-pi Enter_2;
       end-pi;
      *
       dcl-s lFilter pointer;
       dcl-s lModel  pointer;
       dcl-ds Model likeDs(tModel) based(pModel);
       dcl-ds Omit  likeDs(tOmit) based(pOmit);
       dcl-ds stat  likeds(tStat) based(pStat);
       if g2.Fchange;
         msg_SndPM(pgmID:'Press Enter again to confirm');
         return;
       endif;
       pStat=tree_getItem(g2.lStat);
       lFilter=tree_getLinkFromList(lFilters:kFilter:stat.ID);
       tree_deallocChilds(lFilter:*null);
       lModel=tree_getFirst(g2.lStat);
       dow lModel<>*null;
        if tree_getFlag(lModel:iOmit);
          pModel=tree_getItem(lModel);
          pOmit=tree_getNewItem(%addr(tOmit):%size(tOmit));
          Omit.ID=Model.ID;
          tree_linkToParent(lFilter:tree_getNewLink(pOmit));
        endIf;
        lModel=tree_getNext(lModel);
       endDo;
       //
       g2.screen=0;
       rtncode=6;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 - F3=Exit
      // --------------------------------------------------------------------
       dcl-proc  f3_2;
       dcl-pi f3_2;
       end-pi;
       g2.screen=0;
       rtncode=3;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 2 - F10=Move to top
      // --------------------------------------------------------------------
       dcl-proc  f10_2;
       dcl-pi f10_2;
       end-pi;
       if SFL2CSRRRN=0;
         msg_SndPM(pgmID:'Wrong cursor position');
       else;
         g2.lModel1=g2.lModel(SFL2CSRRRN);
       endIf;
       end-proc;
      // -------------------------------------------------------------------
      // Screen 2 - synch
      // -------------------------------------------------------------------
       dcl-proc  Sync_2;
       dcl-pi Sync_2;
       end-pi;
      *
       dcl-s i  uns(3) ;
       dcl-s lX pointer;
       for i=1 to 18;
         lX=tree_getPrev(g2.lModel1);
         if lX=*null;
           leave;
         endIf;
         g2.lModel1=lX;
       endFor;
       end-proc;
      // -------------------------------------------------------------------
      // count selected for all stats
      // -------------------------------------------------------------------
       dcl-proc  countStats;
       dcl-pi countStats;
       end-pi;
      *
       dcl-s lStat pointer;
       lStat=tree_getFirst(lStats);
       dow lStat<>*null;
         countStat(lStat);
         lStat=tree_getNext(lStat);
       endDo;
       end-proc;
      // -------------------------------------------------------------------
      // count selected for stat
      // -------------------------------------------------------------------
       dcl-proc  countStat;
       dcl-pi countStat;
         lStat pointer const;
       end-pi;
      *
       dcl-ds stat likeDs(tStat)   based(pStat);
       dcl-s lFilter pointer;
       dcl-ds filter likeDs(tFilter) based(pFilter);
       pStat=tree_getItem(lStat);
       stat.modelsSelect=0;
       stat.itemsSelect=0;
       stat.modelsCount=0;
       stat.itemsCount=0;
       lFilter=tree_getLinkFromList(lFilters:kFilter:stat.ID);
       lModel=tree_getFirst(lStat);
       dow lModel<>*null;
         pModel=tree_getItem(lModel);
         if tree_getLinkFromList(lFilter:kOmit:model.ID)=*null;
           stat.modelsSelect+=1;
           stat.itemsSelect +=model.itemsCount;
         endIf;
         stat.modelsCount+=1;
         stat.itemsCount +=model.itemsCount;
         lModel=tree_getNext(lModel);
       endDo;
       end-proc;
