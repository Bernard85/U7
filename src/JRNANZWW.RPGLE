       ctl-opt DFTACTGRP(*NO) bnddir('U7') actgrp('A7');
       dcl-f jrnanzwwd WORKSTN SFILE(SFL1:SF1RRN) InfDS(wsDS);
      /copy cpy,u7Ibm_h
      /copy cpy,u7env_h
      /copy cpy,u7ifs_h
      /copy cpy,u7index_h
      /copy cpy,u7jrn_h
      /copy cpy,u7msg_h
      /copy cpy,u7screen_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h

      // Global fields
       dcl-ds G qualified;
         screen    uns(3)      inz(1);
         change    ind        ;
         lAnzs     pointer    ;
         lAnz      pointer     dim(18) inz(*null);
         lAnz1     pointer     inz(*null);
         lAnz1_b4  pointer     inz(*null);
         lAnz9     pointer     inz(*null);
         lAnz9_B4  pointer     inz(*null);
         lOpts     pointer     inz(*null);
         lFKs      pointer     inz(*null);
         jrnPath   varchar(50);
         indexPath varchar(50);
         fToSort   ind        ;
         lIdx      pointer     inz(*null);
       end-ds;
      // --------------------------------------------------------------------
      // main
      // --------------------------------------------------------------------
       dcl-ds index likeDs(tIndex) based(pIndex);
       // welcome message
       msg_SndPM(pgmID:env_getWelcomeMessage());
       // Title
       ZTL='Work with Journals analysis';
       // Load function keys
       screen_setFK(g.lFKs:x'33':'0':%pAddr(F3):'F3=Exit');
       screen_setFK(g.lFKs:x'36':'1':%pAddr(f6):'F6=Save');
       screen_setFK(g.lFKs:x'3a':'1':%pAddr(f10):'F10=Move to top');
       screen_setFK(g.lFKs:x'b8':'1':%pAddr(f20):'F20=Renumber');
       screen_setFK(g.lFKs:x'f1':'1':%pAddr(Enter));
       screen_setFK(g.lFKs:x'f4':*ON :%pAddr(rollUP));
       screen_setFK(g.lFKs:x'f5':*ON :%pAddr(rolldown));
       zFK=screen_getfkentitle(g.lFKs);
       // Load options
       screen_SetOption(g.lOpts:'E':'E=Entries');
       screen_SetOption(g.lOpts:'X':'X=XML');
       screen_SetOption(g.lOpts:'x');
       zCH=screen_getChoicesEntitle(g.lOpts);
       // load index
       g.lAnzs=tree_getNewLink(Tree_getNewItem(%addr(tIndex):%size(tIndex)));
       g.jrnPath=env_getClientPath()+'jrn/';
       g.indexPath=g.jrnPath+'jrn.index';
       g.lIdx=xml_xml2tree(g.indexPath
                          :%pAddr(index_XMLinput));
       // browse files from folder
       ifs_browseFiles(g.jrnPath:%paddr(procFile));
       // Sort elements
       tree_Sort(g.lAnzs:%paddr(index_comparator));
       g.lAnz1=tree_getFirst(g.lAnzs);
       wrkScreen();
       *inlr=*on;
      // --------------------------------------------------------------------
      // work screen
      // --------------------------------------------------------------------
       dcl-proc  wrkScreen;
       dow g.screen>0;
         if G.screen=1;
           Screen1();
         endif;
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - display form
      // --------------------------------------------------------------------
       dcl-proc  Screen1;
       dcl-pr fkProcess extproc(pAction);
       end-pr;
      *
       dcl-s pAction  pointer(*proc);
       dcl-s fcontrol ind           ;
       if g.lAnz9<>g.lAnz9_b4;
         sync();
       endIf;
       if g.lAnz1<>g.lAnz1_b4;
         loadWA1();
         loadSf1();
         // more item or bottom of list
         if tree_getNext(g.lAnz9)=*null;
           mySflEnd='Bottom';
         else;
           mySflEnd='More...';
         endIf;
       endIf;
       // display activation
       write msgCtl;
       write hdr1;
       *in88=*on;
       *in89=*off;
       exfmt ctl1;
       msg_rmvPM(pgmID);
       // get/launch function key
       screen_processFK(pgmID:g.lFKs:wsds.kp:%pAddr(Control));
       end-proc;
      // --------------------------------------------------------------------
      // to process file in directory
      // --------------------------------------------------------------------
       dcl-proc  Control;
       dcl-pi Control ind;
       end-pi;
      *
       dcl-ds Anz likeDs(tElement) based(pAnz);
       dcl-s pCheckProc pointer(*proc);
       dcl-pr checkProc ind extproc(pCheckProc);
         lAnz pointer;
       end-pr;
       dcl-s lOption pointer;
       dcl-s error   ind     inz(*off);
       readc sfl1;
       dow not %eof();
         *in01=*off;
         pAnz=tree_getitem(g.lAnz(sf1rrn));
         if anz.seq<>xSeq;
           anz.seq=xSeq;
           g.fToSort=*on;
         endIf;
         tree_SetOption(g.lAnz(sf1rrn):xChoice);
         if xChoice<>'';
           lOption=tree_getLinkFromList(g.lOpts:'o':xChoice);
           if lOption=*null;
             error=*on;
             msg_SndPM(pgmID:'Option '''+xChoice+''' is not valid');
             *in01=*on;
           endif;
         endif;
         update sfl1;
         readc sfl1;
       enddo;
       return error;
       end-proc;
      // --------------------------------------------------------------------
      // to process file in directory
      // --------------------------------------------------------------------
       dcl-proc  ProcFile;
       dcl-pi procFile;
         wPAth varchar(255) const ;
       end-pi;
      *
       dcl-s lAnz pointer;
       dcl-ds Anz likeDs(tElement) based(pAnz);
       dcl-s lElement pointer;
       dcl-ds element likeDs(tElement) based(pElement);
       // Only take "*.jrn"
       if %scan('.jrn':wPath)=0;
         return;
       endIf;
       // repertori the analysis
       pAnz=Tree_getNewItem(%addr(tElement):%size(tElement));
       anz.ID=wPath;
       tree_linkToParent(g.lAnzs:tree_getNewLink(pAnz));
       // to get the name of the analysis
       xml_read(g.jrnPath+wPath:%paddr(jrnName):pAnz);
       // is the analysis indexed?
       lElement=tree_getLinkFromList(g.lIdx:kElement:anz.ID);
       if lElement<>*null;
         pElement=tree_getItem(lElement);
         anz.seq=element.seq;
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // journal name
      // --------------------------------------------------------------------
       dcl-proc  jrnName;
       dcl-pi jrnName ind;
         ND           likeDs(xml_NodeDefine);
         pAnz_ pointer const;
       end-pi;
      *
       dcl-ds anz likeDs(tElement) based(pAnz);
       if ND.ID='JOURNAL';
         pAnz=pAnz_;
         anz.text=ND.text;
         return *on;
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Loadind work area
      // --------------------------------------------------------------------
       dcl-proc  loadWA1;
      *
       dcl-s lAnz pointer;
       dcl-s i    uns(3) ;
       clear g.lAnz;
       lAnz=g.lAnz1;
       for i=1 to 18;
         g.lAnz(i)=lAnz;
         g.lAnz9=lAnz;
         lAnz=tree_getNext(lAnz);
       endFor;
       end-proc;
      // -----------------------------------------------------------------------
      // Loadind subfile
      // -----------------------------------------------------------------------
       dcl-proc  loadSF1;
      *
       dcl-ds Anz likeDs(tElement) based(pAnz);
       // clear subfile
       *in01=*off;
       *in88=*off;
       *in89=*on;
       WRITE ctl1;
       // Reload subfile
       for sf1rrn=1 to 18;
         if g.lAnz(sf1rrn)=*null;
           leave;
         endIf;
         xChoice=tree_getOption(g.lAnz(sf1rrn));
         pAnz =tree_getItem(g.lAnz(sf1rrn));
         xSeq =anz.seq;
         xID  =anz.ID;
         xTitle=anz.text;
         write sfl1;
       endFor;
       g.lanz1_b4=g.lanz1;
       g.lanz9_b4=g.lanz9;
       end-proc;
      // --------------------------------------------------------------------
      // Roll-UP
      // --------------------------------------------------------------------
       dcl-proc  RollUp;
       dcl-pi Rollup;
       end-pi;
       if G.lAnz1=tree_GetFirst(G.lAnzs);
         msg_SndPM(pgmID:'You have reached the top of the list');
       else;
         g.lAnz9=tree_getPrev(g.lAnz1);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Roll-down
      // --------------------------------------------------------------------
       dcl-proc  RollDown;
       dcl-pi RollDown;
       end-pi;
       if mySflEnd='Bottom';
         msg_SndPM(pgmID:'You have reached the bottom of the list');
       else;
         g.lAnz1=tree_getNext(g.lAnz9);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Enter
      // --------------------------------------------------------------------
       dcl-proc  Enter;
       dcl-pi Enter;
       end-pi;
       dcl-s lAnz    pointer;
       dcl-s Choice  char(1);
       dcl-s pOption pointer;
       dcl-ds Anz likeDs(tElement) based(pAnz);
       dcl-s cmd varchar(80);
      /copy cpy,jrnentww_h
       if g.fToSort;
         g.fToSort=*off;
         // Sort elements
         tree_Sort(g.lAnzs:%paddr(index_comparator));
         g.lAnz1_b4=*null;
         return;
       endIf;
       //
       lAnz=tree_getFirst(g.lAnzs);
       dow lAnz<>*null;
         choice=tree_getOption(lAnz);
         if choice<>'';
           pAnz=tree_getItem(lAnz);
           if choice='X';
             cmd='dspf '''+g.jrnPath+anz.ID+'''';
             qcmdexc(cmd:%len(cmd));
           elseif choice='x';
             cmd='edtf '''+g.jrnPath+anz.ID+'''';
             qcmdexc(cmd:%len(cmd));
           elseif choice='E';
             jrnentww(0:%scanrpl('.jrn':'':anz.ID));
           endIf;
           g.lAnz1_b4=*null;
           tree_setOption(lAnz:'');
         endIf;
         lAnz=tree_getNext(lAnz);
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // F3=Exit
      // --------------------------------------------------------------------
       dcl-proc f3;
       dcl-pi f3;
       end-pi;
       G.screen=0;
       end-proc;
      // --------------------------------------------------------------------
      // F6=Save
      // --------------------------------------------------------------------
       dcl-proc f6;
       dcl-pi f6;
       end-pi;
       f20();
       xml_tree2xml(g.indexPath:g.lAnzs:%paddr(index_XmlOutput));
       g.screen=0;
       end-proc;
      // --------------------------------------------------------------------
      // F10=Move to top
      // --------------------------------------------------------------------
       dcl-proc f10;
       dcl-pi f10;
       end-pi;
       if SFLCSRRRN=0;
         msg_SndPM(pgmID:'Wrong cursor position');
       else;
         g.lAnz1=g.lAnz(sflcsrrrn);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // F20=Renumber
      // --------------------------------------------------------------------
       dcl-proc f20;
       dcl-pi f20;
       end-pi;
      *
       dcl-s Seq  uns(10) inz(0);
       dcl-s lAnz pointer;
       dcl-ds Anz likeDs(tElement) based(pAnz);
       // Resequence elements                                                -
       lAnz=tree_getFirst(g.lAnzs);
       dow lAnz<>*null;
         pAnz=tree_getItem(lAnz);
         if Anz.seq=0;
           leave;
         else;
           Seq+=10;
           Anz.seq=seq;
         endIf;
         lAnz=tree_getNext(lAnz);
       endDo;
       g.lAnz1_b4=*null;
       end-proc;
      // -----------------------------------------------------------------------
      // Synch
      // -----------------------------------------------------------------------
       dcl-proc sync;
       dcl-s i uns(3) ;
       dcl-s lX pointer;
       for i=1 to 18;
         lX=tree_getPrev(G.lAnz1);
         if lX=*null;
           leave;
         endIf;
         G.lAnz1=lX;
       endFor;
       end-proc;
