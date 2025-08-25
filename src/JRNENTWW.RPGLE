     H DFTACTGRP(*NO) bnddir('U7') actgrp('A7')
     FJRNENTWWd CF   E             WORKSTN SFILE(SFL1:SFlRRN1) InfDS(wsDS)

      /copy cpy,u7ibm_h
      /copy cpy,u7env_h
      /copy cpy,u7filter_h
      /copy cpy,u7file_h
      /copy cpy,u7fmt_h
      /copy cpy,u7grid_h
      /copy cpy,u7ifs_h
      /copy cpy,u7int_h
      /copy cpy,u7jrn_h
      /copy cpy,u7msg_h
      /copy cpy,u7screen_h
      /copy cpy,u7screen_s
      /copy cpy,u7stat_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,u7xview_h
      /copy cpy,u7yview_h

      // Anchors
       dcl-ds A qualified;
         lOpts   pointer;
         lFKs    pointer;
         lXViews pointer;
         lFmts   pointer;
         lGrids  pointer;
         lYViews pointer;
         lForms  pointer;
       end-ds;
      // Global fields
       dcl-ds G qualified;
         pScreen       pointer(*proc);
         lVariant1     pointer       ;
         lVariant1_b4  pointer       ;
         lVariant9     pointer       ;
         lVariant9_b4  pointer       ;
         fRefresh      ind           ;
         Item                        dim(20) likeds(tItem);
         anzJrnPath    varchar(255)  ;
         lJournal      pointer       ;
         lFiles        pointer       ;
         lEntries      pointer       ;
         lStats        pointer       ;
         lFilters      pointer       ;
         hdta          int(10)       ;
         error         ind           ;
         CanTabRight   ind            inz(*off);
         CanTabLeft    ind            inz(*on);
         freePartWidth uns(3)        ;
         lVariant_last pointer       ;
         fSubEntries   ind           ;
       end-ds;
      *
       dcl-ds jrnXView likeDs(tXView) based(pJrnXView);
       dcl-s lJrnXView pointer;
       dcl-c margin 4;
      *
       dcl-ds tItem qualified;
         lXView   pointer;
         lYView   pointer;
         lVariant pointer;
         lReal    pointer;
       end-ds;
      *
       dcl-ds journal likeDs(tJournal) based(pJournal);
       dcl-ds filters likeds(tFilters) based(pFilters);
       dcl-s lJrnEntryFmt pointer;
       dcl-ds JrnEntryFmt likeDs(tFormat)based(pJrnEntryFmt);
      // --------------------------------------------------------------------
      // main
      // --------------------------------------------------------------------
       dcl-pi JRNENTWW;
         rtncode int(3)  ;
         AnzID   char(35);
       end-pi;
      *
       dcl-s lColumn   pointer;
       dcl-s lFmtEntry pointer;
       dcl-ds Column likeDs(tColumn) based(pColumn);
       // get path for journal analysis
       g.anzJrnPath=env_getClientPath()+'jrn/'+%trim(anzID)+'.jrn';
       // welcome message
       msg_SndPM(pgmID:env_getWelcomeMessage());
       // Load special procedure
       int_loadprocs();
       // load journal entry format
       lJrnEntryFmt=fmt_getFormat(a.lFmts:'JRNENTRY':'Y');
       pJrnEntryFmt=tree_getItem(lJrnEntryFmt);
       // Load journal
       g.lJournal=xml_xml2tree(g.anzJrnPath:%paddr(jrn_xmlinput));
       pJournal=tree_getItem(g.lJournal);
       g.lEntries=tree_getLinkFromList(g.lJournal:kEntries);
       g.lFilters=tree_getLinkFromList(g.lJournal:kFilters);
       if g.lFilters=*null;
         g.lFilters=
         tree_getNewLink(tree_getNewItem(%addr(tFilters):%size(tFilters)));
         tree_linkToparent(g.lJournal:g.lFilters:g.lEntries);
       endIf;
       pFilters=tree_getItem(g.lFilters);
       // To tie record entry data with the previous
       jrn_tieEntries(g.lEntries);
       // load view for journal (fixed part)
       lJrnXView=xview_getXView(a.lXViews:a.LGrids:a.lfmts:'JRNENTRY':'Y');
       pJrnXView=tree_getItem(lJrnXView);
       lFmtEntry=jrnXView.lFmt;
       jrnXView.hdrColor=x'22';
       xview_posToMostLeft(jrnXView:%len(xFil)/2);
       xview_sethdrs(jrnXView:0);

       g.freePartWidth=%len(xFil)-%len(jrnxView.hdrs)-2;

       // get handle on data journal
       G.hDta=ifs_openForRead(env_getClientPath()+'jrn/'+%trim(AnzID)+'.dta');
       // load other views (free part)
       loadEntries();
       // load models
       loadModels();
       // Enrich models
       richModelEntt();
       richModelObj();
       // position on the left
       f18();
       // Load function keys
       screen_setFK(A.lFKs:x'31':'1':%pAddr(f1));
       screen_setFK(A.lFKs:x'32':'1':%pAddr(f2):'F2=Filters');
       screen_setFK(A.lFKs:x'33':'0':%pAddr(F3):'F3=Exit');
       screen_setFK(A.lFKs:x'36':'1':%pAddr(f6):'F6=To left');
       screen_setFK(A.lFKs:x'37':'1':%pAddr(f7):'F7/F19=Left/all');
       screen_setFK(A.lFKs:x'38':'1':%pAddr(f8):'F8/F20=Right/all');
       screen_setFK(A.lFKs:x'3a':'1':%pAddr(f10):'F10=To top');

       screen_setFK(A.lFKs:x'3b':'1':%pAddr(f11):'F11=Filtered   '
                                                :'F11=Display all');
       screen_setFKcontext(a.lFKs:x'3b':%char(%int(filters.activated)));

       screen_setFK(A.lFKs:x'b7':'1':%pAddr(f19));
       screen_setFK(A.lFKs:x'b8':'1':%pAddr(f20));
       screen_setFK(A.lFKs:x'bc':'1':%pAddr(f24):'F24=Grid');
       screen_setFK(A.lFKs:x'f1':'1':%pAddr(Enter));
       screen_setFK(A.lFKs:x'f4':'1':%pAddr(rollUP));
       screen_setFK(A.lFKs:x'f5':'1':%pAddr(rolldown));
       // Load options
       screen_SetOption(A.lOpts:'5':'5=Data');
       screen_SetOption(A.lOpts:'j':'j=Journal');
       if g.fSubEntries;
         screen_SetOption(A.lOpts:'d':'d=develop');
         screen_SetOption(A.lOpts:'r':'r=reduce');
       endIf;
       zCH=screen_getChoicesEntitle(A.lOpts);
       // Title display
       zTL='Work with journal entries '
          +journal.text
          +' ['+journal.ID+']';
       // work screens
       g.pScreen=%pAddr(screen1);
       g.lVariant1=tree_getFirst(g.lEntries);
       wrkScreens();
       // end of program
       ifs_Close(g.hDta);
       tree_dealloc(a.lFKs);
       tree_dealloc(g.lJournal);
       *inlr=*on;
      // --------------------------------------------------------------------
      // loop on screens
      // --------------------------------------------------------------------
       dcl-proc  wrkScreens;
       dcl-pi *n;
       end-pi;
      *
       dcl-pr Screen extproc(g.pScreen);
       end-pr;
       // loop on screens
       dow g.pScreen<>*null;
         screen();
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - list of entries about journal analysis
      // --------------------------------------------------------------------
       dcl-proc  Screen1;
       dcl-pi *n;
       end-pi;
       dcl-pr fkProcess extproc(pAction);
       end-pr;
      *
       dcl-s pAction  pointer(*proc);
       dcl-s fcontrol ind           ;
       // refresh the work area
       if g.lVariant1<>g.lVariant1_b4
       or g.fRefresh
       or screen_FKsToRefresh();
         zFK=screen_getfkentitle(A.lFKs);
         loadLabel();
         loadwa1();
       endif;
       // refresh the subfile
       if g.lVariant1<>g.lVariant1_b4
       or g.fRefresh
       or screen_FKsToRefresh();
         loadSfl1();
       endIf;
       // display the limits
       displayLimits();
       // display activation
       write msgCtl;
       write hdr1;
       sflDsp=*on;
       sflClr=*off;
       exfmt ctl1;
       msg_rmvPM(pgmID);
       csrtorow=0;
       csrtocol=0;
       g.error=*off;
       g.lVariant_last=*null;
       // get/launch function key
       screen_processFK(pgmID:A.lFKs:wsds.kp:%pAddr(control));
       end-proc;
      // --------------------------------------------------------------------
      // display the limits
      // --------------------------------------------------------------------
       dcl-proc  displayLimits;
       dcl-s lXView pointer;
       dcl-ds XView       likeDS(tXView) based(pXView);
       dcl-ds leftColumn  likeDs(tColumn) based(pLeftcolumn);
       dcl-ds rightColumn likeDs(tColumn) based(pRightColumn);
       lXView=tree_getfirst(a.lXViews);
       dow lXView<>*null;
         pXView=tree_getItem(lXView);
         pleftColumn=tree_getItem(XView.left.lColumn);
         prightColumn=tree_getItem(XView.right.lColumn);

         lXView=tree_getNext(lXView);
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // Load label
      // --------------------------------------------------------------------
       dcl-proc  loadLabel;
       if filters.activated;
         zLabel=x'2b'+' FILTER ACTIVATED ';
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Load screen work area
      // --------------------------------------------------------------------
       dcl-proc  loadwa1;
      *
       dcl-s lVariant pointer;
       dcl-s lParent  pointer;
       dcl-s NO       uns(3)  inz(0);
       dcl-s NO1      uns(3)  inz(0);
       dcl-s lXview   pointer;
       dcl-s lYview   pointer;
       dcl-s lXview$  pointer;
       dcl-ds wItem likeDs(tItem);
       // clear the work area of items
       clear g.Item;
       // Take the item validated
       lVariant=tree_getCurrent(g.lEntries:g.lVariant1:%pAddr(filterValidator));
       // Display ancestors
       lParent=tree_getParent(lVariant);
       dow lParent<>g.lEntries;
         NO=tree_getLevel(lParent)-tree_getLevel(g.lEntries);
         g.item(NO).lVariant=lParent;
         g.item(NO).lReal   =lParent;
         lParent=tree_getParent(lParent);
       endDo;
       NO=tree_getLevel(lVariant)-tree_getLevel(g.lEntries);
       // Display brothers and childs
       dow lVariant<>*null;
         // Check if enought row remains
         if NO>20;
           leave;
         endif;
         // store view+entry
         g.lVariant9=lVariant;
         if breakOnXView(lVariant:lXView:lYView:lXView$);
           g.Item(no).lVariant=lXView;
           g.Item(no).lReal   =lVariant;
           g.Item(no).lXView=lXView;
         else;
           g.Item(no).lVariant=lVariant;
           g.Item(no).lReal   =lVariant;
           g.Item(no).lXView=lXView$;
           g.Item(no).lYView=lYView;
           lVariant=
           tree_getNextToDisplay(g.lEntries:lVariant:%pAddr(filterValidator));
         endIf;
         NO+=1;
       endDo;
       // to force grid on 1st row
       for no=1 to 20;
         if tree_isofthekind(kXView:g.Item(no).lVariant);
           no1=no;
           wItem=g.Item(no);
           leave;
         endIf;
       endFor;
       if NO1=0;
         return;
       endIf;
       for no=no1 downto 2;
         g.Item(no)=g.Item(no-1);
       endFor;
       g.item(1)=wItem;
       end-proc;
      // --------------------------------------------------------------------
      // break on XView
      // --------------------------------------------------------------------
       dcl-proc  breakOnXView;
       dcl-pi *n ind;
         lVariant pointer const;
         lXView   pointer;
         lYView   pointer;
         lXView$  pointer;
       end-pi;
      *
       dcl-ds entry    likeDS(tEntry)    based(pEntry);
       dcl-ds subEntry likeDS(tSubEntry) based(pSubEntry);
       if tree_isofthekind(kEntry:lVariant:pEntry);
         lYView=Entry.lYView;
         lXView$=Entry.lXView;
       elseif tree_isofthekind(kSubEntry:lVariant:pSubEntry);
         lYView=SubEntry.lYView;
         lXView$=SubEntry.lXView;
       endIf;
       if lXView$<>*null and lXView<>lXView$;
         lXView=lXView$;
         return *on;
       endIf;
       return *off;
       end-proc;
      // --------------------------------------------------------------------
      // filter validator  0=Skip 1=Take it
      // --------------------------------------------------------------------
       dcl-proc  filterValidator;
       dcl-pi *n int(3);
         lVariant pointer const;
       end-pi;
      *
       dcl-s lParent pointer;
       dcl-ds entry likeDs(tEntry)    based(pEntry);
       dcl-s lFilter pointer;
       dcl-ds filters likeDs(tFilters) based(pFilters);
       dcl-ds filter  likeDs(tFilter) based(pFilter);
       dcl-s lStat pointer;
       dcl-ds stat likeDs(tStat) based(pStat);
       dcl-s val varchar(50);
       // Check ancestors
       lParent=tree_getParent(lVariant);
       if  lParent<>g.lEntries
       and not tree_isOpen(lParent);
         return 0;
       endIf;
       // No filter input
       if g.lFilters=*null;
         return 1;
       endIf;
       // Entry only taken in account for the filter
       if not tree_isofthekind(kEntry:lVariant:pEntry);
         return 1;
       endif;
       // filter is activated?
       pFilters=tree_getItem(g.lFilters);
       if not Filters.activated;
         return 1;
       endif;
       JrnEntryFmt.pBuffer1=%addr(Entry.det);
       // loop on filter
       lFilter=tree_getFirst(g.lFilters);
       dow lFilter<>*null;
         pFilter=tree_getItem(lFilter);
         val=int_formulaExec(filter.lFormula);
         if tree_getLinkFromList(lFilter:kOmit:val)<>*null;
           return 0;
         endif;
         lFilter=tree_getNext(lFilter);
       endDo;
       // Take it
       return 1;
       end-proc;
      // --------------------------------------------------------------------
      // Load lines of subfile
      // --------------------------------------------------------------------
       dcl-proc  loadSFl1;
       dcl-pi *n;
       end-pi;
      *
       dcl-s fJrnHdrs ind     inz(*off);
       dcl-s lVariant pointer;
       dcl-s lXView   pointer;
       dcl-s fCase    int(3) ;
       dcl-ds section likeDs(tSection) based(pSection);
       // clear subfile
       sflDsp=*off;
       sflClr=*on;
       WRITE ctl1;
       g.cantabRight=*off;
       g.cantabLeft =*off;
       if g.item(1).lVariant=*null;
         sflRrn1=1;
         *in01=*on;
         xFil1=x'20'+'(No entries displayable)';
         write sfl1;
       endif;
       // load the subfile according to the work table
       for sflRrn1=1 to 20;
         lVariant=g.Item(sflRrn1).lVariant;
         xFil='';
         xFil1='';
         // Leave if no item
         if lVariant=*null;
           leave;
         elseif tree_isofthekind(kSection:lVariant:pSection);
           *in01=*off;
           *in03=*on;
           xCho=tree_getOption(lVariant);
           %subst(xfil:%len(jrnXView.hdrs)+1)=x'22'+'!'+x'39'+section.text;
         elseif tree_isofthekind(kXView:lVariant);
           // 1) Load headers
           *in01=*on;
           loadSFL1A(lVariant:fJrnHdrs);
         else;
           *in01=*off;
           lXView=g.Item(sflRrn1).lXView;
           // 2) Load option
           loadSFL1B(lVariant);
           // 3) Determine if the current entry is linked to another
           fCase=getCase(lVariant);
           // 4) journal part
           loadSFL1c(lVariant:fCase);
           // 5) data part
           loadSFL1d(lXView:lVariant:fCase);
           // 6) To avoid no displayable characters
           xfil=int_chkDisplay(Min+Maj+num+spec+spec2+colors+' '
                              :xfil);
           // 7) Sub-format?
           *in03=tree_getFirst(lVariant)<>*null;
         endIf;
         write sfl1;
       endFor;
       //
       g.lVariant1_b4=g.lVariant1;
       g.lVariant9_b4=g.lVariant9;
       g.fRefresh=*off;
       // more item or bottom of list
       screen_setSflEnd(mySflEnd:
        tree_getNextToDisplay(g.lEntries:g.lVariant9:%pAddr(filterValidator))
                       =*null);
       end-proc;
      // --------------------------------------------------------------------
      // Load lines of subfile / headers
      // --------------------------------------------------------------------
       dcl-proc  loadSFl1A;
       dcl-pi *n;
         lVariant pointer const;
         fJrnHdrs ind    ;
       end-pi;
      *
       dcl-ds xView likeDs(tXView)  based(pXView);
       // Load line according to the kind of corresponding item
       if not tree_isofthekind(kXView:lVariant:pXView);
         return;
       endIf;
       // header
       if not fJrnHdrs;
         fJrnHdrs=*on;
         xFil1='Opt'+jrnXView.hdrs;
       endif;
       %subst(xfil1:%len(jrnXView.hdrs)+4)=x'22'+'!';
       %subst(xfil1:%len(jrnXView.hdrs)+6)
       =xview_setHdrs(XView:%len(jrnXView.hdrs)+2);
       g.canTabRight=g.canTabRight or not XView.right.most;
       g.canTabLeft =g.canTabLeft  or not XView.Left.most;
       end-proc;
      // --------------------------------------------------------------------
      // Load lines of subfile / option
      // --------------------------------------------------------------------
       dcl-proc  loadSFl1B;
       dcl-pi *n;
         lVariant pointer const;
       end-pi;
      *
       xCho=tree_getOption(lVariant);
       if g.lVariant_last=lVariant;
         csrToCol=3;
         csrToRow=sflRrn1+6-1;
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Load journal part
      // --------------------------------------------------------------------
       dcl-proc  loadSFl1C;
       dcl-pi *n;
         lVariant pointer const;
         fCase    int(3)  const;
       end-pi;
      *
       dcl-ds fmt    likeds(tFormat) based(pFmt);
       dcl-ds entry  likeDs(tEntry) based(pEntry);
       dcl-ds entry0 likeDs(tEntry) based(pEntry0);
       xFil='';
       if tree_isofthekind(kEntry:lVariant:pEntry);
         pFmt=tree_getitem(jrnXView.lFmt);
         fmt.pBuffer1=%addr(entry.det);
         if entry.pEntry0<>*null;
           pEntry0=entry.pEntry0;
           fmt.pBuffer0=%addr(entry0.det);
         endif;
         loadSFC1(jrnXView:xFil:fCase);
       endIf;
       %subst(xfil:%len(jrnXView.hdrs)+1)=x'22'+'!';
       end-proc;
      // --------------------------------------------------------------------
      // Load data part
      // --------------------------------------------------------------------
       dcl-proc  loadSFl1D;
       dcl-pi *n;
         lXView   pointer const;
         lVariant pointer const;
         fCase    int(3)  const;
       end-pi;
      *
       dcl-ds XView    likeDs(tXView) based(pXView);
       dcl-ds fmt      likeds(tFormat) based(pFmt);
       dcl-ds entry    likeDs(tEntry) based(pEntry);
       dcl-ds entry0   likeDs(tEntry) based(pEntry0);
       dcl-ds subEntry likeDs(tSubEntry) based(pSubEntry);
       dcl-s pos uns(10);
       if lXView=*null;
         return;
       endIf;
       pXView=tree_getItem(g.Item(sflRrn1).lXView);
       pFmt=tree_getItem(xView.lFmt);
       if tree_isofthekind(kEntry:lVariant:pEntry);
         pos=0;
       elseif tree_isofthekind(kSubEntry:lVariant:pSubEntry);
         pEntry=tree_getItem(tree_getParent(lVariant));
         pos=subEntry.pos;
       endIf;
       ifs_lseek(g.hDta:entry.det.apos+pos:0);
       ifs_read(g.hDta:Fmt.pBuffer1:Fmt.len);
       if Entry.pEntry0<>*null;
         pEntry0=Entry.pEntry0;
         ifs_lseek(g.hDta:entry0.det.apos+pos:0);
         ifs_read(g.hDta:Fmt.pBuffer0:Fmt.len);
       endif;
       loadSFC1(XView:xFil:fCase);
       end-proc;
      // --------------------------------------------------------------------
      // case -1=Deleted,0=Not changed,1=Changed
      // --------------------------------------------------------------------
       dcl-proc  getCase;
       dcl-pi *n int(3);
         lVariant pointer const;
       end-pi;
      *
       dcl-ds entry likeds(tEntry) based(pEntry);
       // validate the entry
       if not tree_isofthekind(kEntry:lVariant:pEntry);
         pEntry=tree_getItem(tree_getParent(lVariant));
       endif;
       // 4) to setup the color
       if entry.det.ENTT='DL'
       or entry.det.ENTT='DR';
         return -1;
       else;
         return %int(entry.pEntry0<>*null);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Load subfile columns
      // --------------------------------------------------------------------
       dcl-proc  loadSFC1;
       dcl-pi *n;
         XView          likeDs(tXView) const;
         xFil  char(128);
         fCase int(3)    const;
       end-pi;
      *
       dcl-s lColumn pointer;
       dcl-ds Column likeDs(tColumn) based(pColumn);
       dcl-s string char(32000);
       // Loop on each cell
       lColumn=XView.left.lColumn;
       dow 1=1;
         pColumn=tree_getItem(lColumn);
         string=int_FormulaExec(column.lFormula);
         // 1) Attribut of the cell
         if fCase=0;
           // no change on the record
           %subst(xFil:Column.pos-1:1)=XView.Detcolor;
         elseif fCase=-1;
           // record deleted
           %subst(xFil:Column.pos-1:1)=x'2b';
         elseif int_FormulaExec(column.lFormula:0)<>string;
           // field has been changed
           %subst(xFil:Column.pos-1:1)=XView.ChgColor;
         else;
           // no change on the field
           %subst(xFil:Column.pos-1:1)=XView.Detcolor;
         endIf;
         // 2) Fill the value of the field
         if lColumn=XView.right.lColumn;
           // right column
           %subst(xFil:Column.pos:XView.right.width)
           =%subst(String:XView.right.pos:XView.right.width);
           if Column.pos+XView.right.width<%len(xFil);
             // right attribut
             %subst(xFil:Column.pos+XView.right.width:1)=x'20';
           endif;
           return;
         elseif lColumn=XView.left.lColumn;
           // left column
           %subst(xFil:Column.pos:XView.left.width)
           =%subst(String:XView.left.pos:XView.left.width);
         else;
           // mid column
           %subst(xFil:Column.pos)=%subst(String:1:column.maxWidth);
         endif;
         lColumn=tree_getNext(lColumn);
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // control input
      // --------------------------------------------------------------------
       dcl-proc  Control;
       dcl-pi *n ind;
       end-pi;
      *
       dcl-s lVariant pointer;
       dcl-ds entry    likeDS(tEntry)    based(pEntry);
       dcl-ds subEntry likeDS(tSubEntry) based(pSubEntry);
       readc sfl1;
       dow not %eof();
         *in02=*off;
         if %scan(xCho:' 5jdr')=0;
           msg_SndPM(pgmID:'Option "'+xCho+'" is not valid');
           g.error=*on;
           *in02=*on;
         elseif %scan(xCho:'dr')>0
         and tree_getfirst(g.Item(sflRrn1).lVariant)=*null;
           msg_SndPM(pgmID:'Option "'+xCho
                    +'" is only valid on section or entry with sub-format');
           g.error=*on;
           *in02=*on;
         elseif xCho='5' and g.item(sflrrn1).lYView=*null
         or xCho='j' and tree_isofthekind(kSection:g.item(sflrrn1).lVariant);
           msg_SndPM(pgmID:'Option "'+xCho+'" is not valid');
           g.error=*on;
           *in02=*on;
         endif;
         *in03=tree_getFirst(g.Item(sflRrn1).lVariant)<>*null;
         update sfl1;
         tree_setOption(g.Item(sflRrn1).lVariant:xCho);
         readc sfl1;
       enddo;
       return g.error;
       end-proc;
      // --------------------------------------------------------------------
      // Roll-UP
      // --------------------------------------------------------------------
       dcl-proc  RollUp;
       dcl-pi *n;
       end-pi;
      *
       dcl-s lVariant pointer;
       dcl-s lXView   pointer;
       dcl-s lYView   pointer;
       dcl-s lXView$  pointer;
       dcl-s NO       uns(3)  inz(0);
       if tree_getPrevToDisplay(g.lEntries:g.lVariant1:%pAddr(filterValidator))
       =*null;
         msg_SndPM(pgmID:'You have reached the top of the list');
         return;
       endIf;
       lVariant
       =tree_getPrevtoDisplay(g.lEntries:g.lVariant1:%pAddr(filterValidator));
       no=20;
       dow lVariant<>*null;
         if no<tree_getLevel(lVariant)-tree_getLevel(g.lEntries);
           return;
         endif;
         g.lVariant1=lVariant;
         if breakOnXView(lVariant:lXView:lYView:lXView$);
           no-=1;
         else;
           no-=1;
           lVariant
           =tree_getPrevtoDisplay(g.lEntries:lVariant:%pAddr(filterValidator));
         endif;
       enddo;
       end-proc;
      // --------------------------------------------------------------------
      // Roll-down
      // --------------------------------------------------------------------
       dcl-proc  RollDown;
       dcl-pi *n;
       end-pi;
       if mySflEnd='Bottom';
         msg_SndPM(pgmID:'You have reached the bottom of the list');
       else;
         g.lVariant1=
         tree_getNextToDisplay(g.lEntries:g.lVariant9:%pAddr(filterValidator));
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Enter
      // --------------------------------------------------------------------
       dcl-proc  Enter;
       dcl-pi Enter;
       end-pi;
      *
       dcl-s lVariant pointer;
       dcl-s rtnCode  int(3) ;
       dcl-s option   char(1);
      *
      /copy cpy,jrnentdp_h
       // loop on each entry
       lVariant=tree_getFirst(g.lEntries);
       dow lVariant<>*null;
         option=tree_getOption(lVariant);
         if option='r';
           tree_closeLink(lVariant);
           g.fRefresh=*on;
           tree_setOption(lVariant:'');
           g.lVariant_last=lVariant;
         elseif option='d';
           tree_openLink(lVariant);
           g.fRefresh=*on;
           tree_setOption(lVariant:'');
           g.lVariant_last=lVariant;
         elseif %scan(option:'5j')>0;
           g.fRefresh=*on;
           jrnEntDp(rtncode:option
                   :journal.text+' ['+journal.ID+']'
                   :lVariant
                   :g.hDta
                   :a.lYViews:a.lFmts:a.lForms:g.lStats);
           g.lVariant_last=lVariant;
           if rtnCode>0;
             tree_setOption(lVariant:'');
           elseif rtnCode=0;
             leave;
           else;
             leave;
           endIf;
         endIf;
         lVariant=tree_getNexttoDisplay(g.lEntries:lVariant);
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // F1=Where am I?
      // --------------------------------------------------------------------
       dcl-proc  f1;
       dcl-pi *n;
       end-pi;
      *
       dcl-s lColumn pointer;
       dcl-ds column likeds(tColumn) based(pColumn);
       dcl-s posOnColumn uns(5);
       csrtorow=wsds.csrfromrow;
       csrtocol=wsds.csrfromcol;
       if SFLCSRRRN=0
       or wsds.CsrFromCol<=margin
       or  wsds.CsrFromCol>margin+%len(jrnxView.hdrs)
       and wsds.CsrFromCol<margin+%len(jrnxView.hdrs)+3;
         msg_SndPM(pgmID:'Wrong cursor position');
       elseif wsds.CsrFromCol-margin<=%len(jrnxView.hdrs);
         xview_getColumnAtPos(lJrnXView
                             :wsds.CsrFromCol-margin
                             :lColumn
                             :posOnColumn);
         pColumn=tree_getItem(lColumn);
         msg_SndPM(pgmID:'You are on the column '+%trim(column.formula)
                        +' '+%char(posOnColumn));
       elseif xview_getColumnAtPos(g.Item(sflcsrrrn).lXView
                                  :wsds.CsrFromCol-margin
                                  :lColumn
                                  :posOnColumn);
         pColumn=tree_getItem(lColumn);
         msg_SndPM(pgmID:'You are on the column '+%trim(column.formula)
                        +' '+%char(posOnColumn));
       else;
         msg_SndPM(pgmID:'No displayed column at the specified position');
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // F2=Filters
      // --------------------------------------------------------------------
       dcl-proc  f2;
       dcl-pi f2;
       end-pi;
       dcl-s rtnCode int(3);
      /copy cpy,filterup_h
       filterUP(rtncode:g.lStats:g.lFilters);
       g.fRefresh=*on;
       end-proc;
      // --------------------------------------------------------------------
      // F3=Exit
      // --------------------------------------------------------------------
       dcl-proc  f3;
       dcl-pi f3;
       end-pi;
       G.pScreen=*null;
       xml_tree2xml(g.anzJrnPath:g.lJournal:%paddr(jrn_xmloutput));
       end-proc;
      // --------------------------------------------------------------------
      // F6=to left
      // --------------------------------------------------------------------
       dcl-proc  f6;
       dcl-pi f6;
       end-pi;
      *
       dcl-s lColumn     pointer;
       dcl-s posOnColumn uns(5) ;
       dcl-ds XView likeDS(tXView) based(pXView);
       csrtorow=wsds.csrfromrow;
       csrtocol=wsds.csrfromcol;
       if SFLCSRRRN>0
       and xview_getColumnAtPos(g.Item(sflcsrrrn).lXView
                               :wsds.CsrFromCol-margin
                               :lcolumn
                               :posOnColumn);
         pXView=tree_getItem(g.Item(sflcsrrrn).lXView);
         xview_posAtLeft(XView
                        :g.freePartWidth
                        :lcolumn
                        :posOnColumn);
         csrtocol=3;
         g.fRefresh=*on;
       else;
         msg_SndPM(pgmID:'No displayed column at the specified position');
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // F7=Left tab
      // --------------------------------------------------------------------
       dcl-proc  f7;
       dcl-pi f7;
       end-pi;
      *
       dcl-ds XView likeDs(tXView) based(pXView);
       csrtorow=wsds.csrfromrow;
       csrtocol=wsds.csrfromcol;
       if SFLCSRRRN=0
       or g.item(SFLCSRRRN).lXView=*null;
         msg_SndPM(pgmID:'Wrong cursor position');
       else;
         csrtocol=3;
         pXView=tree_getItem(g.item(SFLCSRRRN).lXView);
         if XView.left.most;
           msg_SndPM(pgmID:'Format is on the most left position');
         else;
           xview_TabLeft(XView:g.freePartWidth);
           g.fRefresh=*on;
         endIf;
       endif;
       end-proc;
      // --------------------------------------------------------------------
      // F8=Right tab
      // --------------------------------------------------------------------
       dcl-proc  f8;
       dcl-pi f8;
       end-pi;
      *
       dcl-ds XView likeDs(tXView) based(pXView);
       csrtorow=wsds.csrfromrow;
       csrtocol=wsds.csrfromcol;
       if SFLCSRRRN=0
       or g.item(SFLCSRRRN).lXView=*null;
         msg_SndPM(pgmID:'Wrong cursor position');
       else;
         csrtocol=3;
         pXView=tree_getItem(g.item(SFLCSRRRN).lXView);
         if XView.Right.most;
           msg_SndPM(pgmID:'Format is on the most right position');
         else;
           xview_TabRight(XView:g.freePartWidth);
           g.fRefresh=*on;
         endIf;
       endif;
       end-proc;
      // --------------------------------------------------------------------
      // F10=Move to top
      // --------------------------------------------------------------------
       dcl-proc  f10;
       dcl-pi f10;
       end-pi;
       if SFLCSRRRN=0 or g.Item(1).lVariant=*null;
         msg_SndPM(pgmID:'Wrong cursor position');
       else;
         g.lVariant1=g.Item(sflcsrrrn).lReal;
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // F11=display all/apply filter
      // --------------------------------------------------------------------
       dcl-proc  f11;
       dcl-pi f11;
       end-pi;
      *
       dcl-ds filters likeDS(tFilters) based(pFilters);
       pFilters=tree_getItem(g.lFilters);
       filters.activated=not filters.activated;
       zLabel='';
       g.fRefresh=*on;
       end-proc;
      // --------------------------------------------------------------------
      // F18=Position all views on the left
      // --------------------------------------------------------------------
       dcl-proc  f18;
       dcl-pi f18;
       end-pi;
      *
       dcl-s lXView pointer;
       dcl-ds XView likeDs(tXView) based(pXView);
       if g.canTabLeft;
         lXView=tree_getFirst(a.lXViews);
         dow lXView<>*null;
           if lXView<>lJrnXView;
             pXView=tree_getItem(lXView);
             xview_posToMostLeft(XView:g.freePartWidth);
           endIf;
           lXView=tree_getNext(lXView);
         endDo;
         g.fRefresh=*on;
       else;
         msg_SndPM(pgmID:'Formats displayed are on the most left position');
       endif;
       end-proc;
      // --------------------------------------------------------------------
      // F19=Left tab on all
      // --------------------------------------------------------------------
       dcl-proc  f19;
       dcl-pi f19;
       end-pi;
      *
       dcl-s lXView pointer;
       dcl-ds XView likeDs(tXView) based(pXView);
       if g.canTabLeft;
         lXView=tree_getFirst(a.lXViews);
         dow lXView<>*null;
           pXView=tree_getItem(lXView);
           xview_TabLeft(XView:g.freePartWidth);
           lXView=tree_getNext(lXView);
         endDo;
         g.fRefresh=*on;
       else;
         msg_SndPM(pgmID:'Formats displayed are on the most left position');
       endif;
       end-proc;
      // --------------------------------------------------------------------
      // F20=Right
      // --------------------------------------------------------------------
       dcl-proc  f20;
       dcl-pi f20;
       end-pi;
      *
       dcl-s lXView pointer;
       dcl-ds XView likeDs(tXView) based(pXView);
       if g.canTabRight;
         lXView=tree_getFirst(a.lXViews);
         dow lXView<>*null;
           pXView=tree_getItem(lXView);
           if xView.ID<>'JRNENTRY';
             xview_tabRight(XView:g.freePartWidth);
           endIf;
           lXView=tree_getNext(lXView);
         endDo;
         g.fRefresh=*on;
       else;
        msg_SndPM(pgmID:'Formats displayed are on the most right position');
       endif;
       end-proc;
      // --------------------------------------------------------------------
      // F24=Grid
      // --------------------------------------------------------------------
       dcl-proc  f24;
       dcl-pi f24;
       end-pi;
      /copy cpy,gridup_h
       dcl-s lXView pointer;
       dcl-ds XView likeDs(tXView) based(pXView);
       dcl-s lGrid pointer;
       dcl-ds Grid likeDs(tGrid) based(pGrid);
       dcl-s gridID varchar(10);
       dcl-ds Column likeDs(tColumn) based(pColumn);
       dcl-s columnID varchar(10);
       if SFLCSRRRN=0
       or tree_isofthekind(kSection:g.item(sflcsrrrn).lVariant);
         msg_SndPM(pgmID:'Wrong cursor position');
       elseif wsds.CsrFromCol<%len(jrnXView.hdrs);
         lGrid=jrnXView.lGrid;
         gridUP(rtnCode:lGrid:'Y');
         xview_posToMostLeft(jrnXView:%len(xFil)/2);
         xview_sethdrs(jrnXView:0);
         g.freePartWidth=%len(xFil)-%len(jrnxView.hdrs)-2;
         g.canTabLeft=*on;
         f18();
       else;
         lXView=g.item(sflcsrrrn).lXview;
         pXView=tree_getItem(lXView);
         lGrid=XView.lGrid;
         gridUP(rtnCode:lGrid);
         if rtnCode=fContinue;
          xview_posAtLeft(XView
                         :g.freePartWidth
                         :xview.left.lColumn
                         :xview.left.pos);
           g.fRefresh=*on;
         endIf;
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Entries load
      // --------------------------------------------------------------------
       dcl-proc  loadEntries;
       dcl-pi loadEntries;
       end-pi;
       dcl-s lVariant pointer;
       dcl-ds Entry likeDs(tEntry) based(pEntry);
       dcl-s lFile pointer;
       dcl-ds File likeDs(tFile) based(pFile);
       dcl-s lFmt pointer;
       // Files are loaded from analysis
       lVariant=tree_getFirst(g.lEntries);
       dow lVariant<>*null;
         if  tree_isofthekind(kEntry:lVariant:pEntry)
         and entry.det.code='R' and entry.det.entt<>'IL';
           // Files are loaded from object
           lFile=file_getFile(g.lFiles:%trim(entry.det.obj));
           // Load the corresponding XVIew
           if lFile<>*null;
            pFile=tree_getItem(lFile);
            lFmt=fmt_getFormat(a.lFmts:File.format);
            entry.lXView=xview_getXView(a.lXViews:a.lGrids:a.lFmts:File.format);
            entry.lYView=yview_getYView(a.lYViews:a.lForms:a.lFmts:File.format);
            loadSubEntries(lVariant:lFmt:0);
           endif;
         endif;
         lVariant=tree_getNexttodisplay(g.lEntries:lVariant);
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // Sub-Entries load
      // --------------------------------------------------------------------
       dcl-proc  loadSubEntries;
       dcl-pi loadSubEntries;
         lEntry     pointer const;
         lParentFmt pointer const;
         pos        uns(10) value;
       end-pi;
      *
       dcl-ds entry     likeDs(tEntry)  based(pEntry);
       dcl-ds ParentFmt likeDs(tFormat) based(pParentFmt);
       dcl-s lSubFormats pointer;
       dcl-s lSubFormat  pointer;
       dcl-ds SubFormat likeDs(tSubFormat) based(pSubFormat);
       dcl-s formatID varchar(10);
       dcl-s lFormat  pointer    ;
       dcl-ds SubEntry likeDs(tSubEntry) based(pSubEntry);
      *
       lSubFormats=tree_getLinkFromList(lParentFmt:kSubFormats);
       if lSubFormats=*null;
         return;
       endif;
       pEntry=tree_getItem(lEntry);
       pParentFmt=tree_getItem(lParentFmt);
       ifs_lseek(g.hDta:entry.det.aPos+pos:0);
       ifs_read(g.hDta:ParentFmt.pBuffer1:ParentFmt.len);
       lSubFormat=tree_getFirst(lSubformats);
       dow lSubFormat<>*null;
         pSubFormat=tree_getItem(lSubFormat);
         formatID=int_FormulaExec(SubFormat.lFormula);
         lFormat=fmt_getFormat(a.lFmts:formatID);
         if lFormat<>*null;
          if tree_getLinkFromList(lFormat:kFields)<>*null;
            g.fSubEntries=*on;
            pSubEntry=tree_getNewItem(%addr(tSubEntry):%size(tSubEntry));
            SubEntry.lXView=xview_getXView(a.lXViews:a.lGrids:a.lfmts:formatID);
            SubEntry.lYView=yview_getYView(a.lYViews:a.lForms:a.lfmts:formatID);
            SubEntry.pos=subFormat.pos+pos;
            SubEntry.fmtID=formatID;
            tree_linktoparent(lEntry:tree_getnewlink(pSubEntry));
            tree_closeLink(lEntry);
          endIf;
          loadSubEntries(lEntry:lFormat:subFormat.pos+pos);
         endIf;
         lSubFormat=tree_getNext(lSubformat);
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // load models
      // --------------------------------------------------------------------
       dcl-proc  loadModels;
       dcl-pi loadModels;
       end-pi;
      *
       dcl-s lVariant pointer;
       dcl-ds Entry likeDs(tEntry) based(pEntry);
       dcl-s lStat pointer;
       dcl-ds stat likeDS(tStat) based(pStat);
       dcl-s lFilter pointer;
       dcl-ds filter likeDs(tFilter) based(pFilter);
       // load formulas for stat
       g.lStats=xml_Xml2Tree(env_getAppliPath()+'jrn/'+'jrnAnzStat.xml'
                            :%pAddr(stat_XmlInput));
       lStat=tree_getFirst(g.lStats);
       dow lStat<>*null;
         pStat=tree_getItem(lStat);
         stat.lFormula=int_FormulaLoad(stat.formula:lJrnEntryFmt);
         // Check filter
         lFilter=tree_getLinkFromList(g.lFilters:kFilter:Stat.ID);
         if lFilter=*null;
           pFilter=tree_getNewItem(%addr(tFilter):%size(tFilter));
           Filter.ID=Stat.ID;
           tree_linkToParent(g.lFilters:tree_getNewLink(pFilter));
         else;
           pFilter=tree_getItem(lFilter);
         endIf;
         Filter.lFormula=stat.lFormula;
         lStat=tree_getNextToDisplay(g.lStats:lStat);
       endDo;
       // loop on each entries
       lVariant=tree_getFirst(g.lEntries);
       dow lVariant<>*null;
         if tree_isofthekind(kEntry:lVariant:pEntry);
           JrnEntryFmt.pBuffer1=%addr(Entry.det);
           loadModels2(g.lStats);
         endIf;
         lVariant=tree_getNextToDisplay(g.lEntries:lVariant);
       endDo;
       // Sort models in stat
       lStat=tree_getFirst(g.lStats);
       dow lStat<>*null;
         tree_sort(lStat);
         lStat=tree_getNextToDisplay(g.lStats:lStat);
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // load models (part 2)
      // --------------------------------------------------------------------
       dcl-proc  loadModels2;
       dcl-pi loadModels2;
         lStats pointer const;
       end-pi;
      *
       dcl-s lModel pointer;
       dcl-s lStat  pointer;
       dcl-ds stat  likeDS(tStat)  based(pStat);
       dcl-ds model likeDS(tModel) based(pModel);
       dcl-s modelID varchar(50);
       lStat=tree_getFirst(lStats);
       dow lStat<>*null;
         pStat=tree_getItem(lStat);
         modelID=int_formulaExec(stat.lFormula);
         lModel=tree_getLinkFromList(lStat:kModel:modelID);
         if lModel=*null;
           pModel=tree_getNewItem(%addr(tModel):%size(tModel));
           model.ID=modelID;
           tree_linkToParent(lStat:tree_getNewLink(pModel));
           stat.modelsCount+=1;
         else;
           pModel=tree_getItem(lModel);
         endIf;
         model.itemsCount+=1;
         lStat=tree_getNext(lStat);
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // enrichment models (Entry code and type)
      // --------------------------------------------------------------------
       dcl-proc  richModelEntt;
       dcl-pi richModelEntt end-pi;
      *
       dcl-ds l2 qualified;
         lCode pointer;
         lEntt pointer;
       end-ds;
       // Get stat on Entry type
       l2.lCode=tree_getLinkFromList(g.lStats:kStat:'CODE');
       l2.lEntt=tree_getLinkFromList(g.lStats:kStat:'ENTT');
       // Read the xml to find out definition of entry type
       xml_read(env_getAppliPath()+'jrn/'+'ENTT.xml'
               :%pAddr('RICHMODELENTT2')
               :%Addr(l2));
       end-proc;
      // --------------------------------------------------------------------
      // enrichment models (Entry code and type) part 2
      // --------------------------------------------------------------------
       dcl-proc  richModelEntt2;
       dcl-pi richModelEntt2;
         ND         likeDs(xml_NodeDefine);
         pL2 pointer;
       end-pi;
      *
       dcl-s codeID char(1);
       dcl-s typeID char(2);
       dcl-ds l2 qualified based(pL2);
         lCode pointer;
         lEntt pointer;
       end-ds;
       dcl-s lModel pointer;
       dcl-ds model likeDs(tModel) based(pModel);
       dcl-s wFormula varchar(80);
       if not ND.isOpen;
         return;
       endif;
       if ND.ID='CODE';
         codeID=xml_getAttAsString('ID':ND.atts);
         lModel=tree_getLinkfromList(l2.lCode:kModel:codeID);
         if lModel<>*null;
           pModel=tree_getItem(lModel);
           model.text=ND.text;
         endIf;
       elseif ND.ID='TYPE';
         typeID=xml_getAttAsString('ID':ND.atts);
         lModel=tree_getLinkfromList(l2.lEntt:kModel:typeID);
         if lModel<>*null;
           pModel=tree_getItem(lModel);
           model.text=ND.text;
           wFormula=xml_getAttAsString('FORMULA':ND.atts);
           if wFormula='';
             wFormula=''''+model.text+'''';
           endif;
           model.lFormula=int_formulaLoad(wFormula:lJrnEntryFmt);
         endIf;
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // enrichment models (Object)
      // --------------------------------------------------------------------
       dcl-proc  richModelObj;
       dcl-pi richModelObj;
       end-pi;
      *
       dcl-s lObjs pointer;
       dcl-s lObj pointer;
       dcl-ds obj likeDs(tModel) based(pObj);
       dcl-s lFile pointer;
       dcl-ds file likeDs(tFile)  based(pFile);
       // Get stat on Entry type
       lObjs=tree_getLinkFromList(g.lStats:kStat:'OBJ');
       // loop on each object to find out the corresponding description
       lObj=tree_getFirst(lObjs);
       dow lObj<>*null;
         pObj=tree_getItem(lObj);
         lFile=tree_getLinkFromList(g.lFiles:kFile:obj.ID);
         if tree_isOfTheKind(kFile:lFile:pFile);
           obj.text=file.text;
         endIf;
         lObj=tree_getNext(lObj);
       endDo;
       end-proc;
