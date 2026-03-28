       ctl-opt DFTACTGRP(*NO) bnddir('U7') actgrp(*new);
       ctl-opt option(*NOSHOWCPY);
       dcl-f jrnDtaWwD WORKSTN SFILE(SFL1:SFlRRN1) InfDS(wsDS);
      /copy cpy,u7ibm_h
      /copy cpy,u7env_h
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
         lOpts    pointer;
         lFKs     pointer;
         lXViews  pointer;
         lFormats pointer;
         lGrids   pointer;
         lYViews  pointer;
         lForms   pointer;
         lFiles   pointer;
       end-ds;
      // Global fields
       dcl-ds G qualified;
         pScreen       pointer(*proc);
         Row1          int(10);
         Row1_B4       int(10);
         row_Max       int(10);
         fRefresh      ind inz(*on);
         toLoad        ind inz(*on);
         error         ind;
         freePartWidth uns(3);
         fSubEntries   ind;
         lXView        pointer;
       end-ds;
      // Record id
       dcl-ds XView likeDs(tXView) based(pXView);
       dcl-ds file likeDs(tFile) based(pFile);
       dcl-ds format likeDs(tFormat) based(pFormat);
       dcl-ds Rcd likeDs(tRcd);
      // Record type
       dcl-ds tRcd qualified template;
         row      int(10);
         fileName char(10);
         rrn      int(10);
         choice   char(1);
       end-Ds;
      // Record type
       dcl-ds tDta qualified template;
         info     pointer inz(*null);
         choice   char(1) inz('');
       end-ds;
      // Records id for those displayed
       dcl-ds rcds inz likeDs(tRcd) dim(19);
       dcl-ds dtas inz likeDs(tDta) dim(19);
      *
      // --------------------------------------------------------------------
      // main
      // --------------------------------------------------------------------
       dcl-pi JRNDTAWW;
       end-pi;
      *
       // welcome message
       ///msg_SndPM(pgmID:env_getWelcomeMessage());
       // Load function keys
       screen_setFK(A.lFKs:x'33':'0':%pAddr(F3):'F3=Exit');
       screen_setFK(A.lFKs:x'3a':'1':%pAddr(f10):'F10=To top');
       screen_setFK(A.lFKs:x'b7':'1':%pAddr(f19):'F19=Left');
       screen_setFK(A.lFKs:x'b8':'1':%pAddr(f20):'F20=Right');
       screen_setFK(A.lFKs:x'f1':'1':%pAddr(Enter));
       screen_setFK(A.lFKs:x'f4':'1':%pAddr(rollUP));
       screen_setFK(A.lFKs:x'f5':'1':%pAddr(rolldown));
       // Load options
       screen_SetOption(A.lOpts:'5':'5=Data');
       screen_SetOption(A.lOpts:'j':'j=Journal');
       zCH=screen_getChoicesEntitle(A.lOpts);
       // Title display
       zTL='Work with journal entries ';
       g.lXView=xview_getXView(a.lXViews:a.lGrids:a.lFormats:'CLIENT2$');
       pXView=tree_getItem(g.lXView);
       // open the sql cursor + corresponding file
       openSql();
       openFile();
       // work screens
       wrkScreens();
       // close the sql cursor + corresponding file
       openSql();
       openFile();
       *inlr=*on;
      // --------------------------------------------------------------------
      // loop on screens
      // --------------------------------------------------------------------
       dcl-proc  wrkScreens;
      *
       dcl-pr Screen extproc(g.pScreen);
       end-pr;
       // loop on screens
       xview_PosToMostLeft(XView:127);
       g.pScreen=%pAddr(screen1);
       g.row1=1;
       dow g.pScreen<>*null;
         screen();
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // Screen 1 - list of entries about journal analysis
      // --------------------------------------------------------------------
       dcl-proc  Screen1;
       dcl-pr fkProcess extproc(pAction);
       end-pr;
      *
       dcl-s pAction  pointer(*proc);
       dcl-s fcontrol ind;
       // refresh data
       if g.Row1_b4<>g.Row1;
         msg_SndPM(pgmID:'Données relues');
         loadData();
         g.Row1_b4=g.Row1;
         g.fRefresh=*on;
       endIf;
       // refresh subfile
       if g.fRefresh;
         msg_SndPM(pgmID:'Sous-fichier rechargé');
         loadSfl1();
         g.fRefresh=*off;
       endIf;
       zFK=screen_getfkentitle(a.lFKs);
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
       // get/launch function key
       screen_processFK(pgmID:A.lFKs:wsds.kp:%pAddr(control));
       end-proc;
      // --------------------------------------------------------------------
      // load data
      // --------------------------------------------------------------------
       dcl-proc loadData;
       dcl-s iRcd uns(3);
       dcl-s skip      int(10);
       dcl-s rowCount  uns(3);
       // clear the arrea
       reset Rcds;
       // To know the current position
       exec sql fetch current from i1 into :Rcd;
       skip=g.row1-Rcd.row;
       exec sql fetch relative :skip from i1;
       exec sql fetch current from i1 for 19 rows into :Rcds;
       exec sql get diagnostics :rowCount=ROW_COUNT;
       for iRcd=1 to rowCount;
         dtas(iRcd).choice='';
         if dtas(iRcd).info=*null;
           dtas(iRcd).info=%alloc(format.len);
         endif;
         pRIOFB$=rReadd(file.hFile
                       :dtas(iRcd).info
                       :format.len
                       :x'00000001'
                       :rcds(iRcd).rrn);
       endFor;
       end-proc;
      // --------------------------------------------------------------------
      // load sub-file
      // --------------------------------------------------------------------
       dcl-proc loadSfl1;
       dcl-ds rcd likeDs(tRcd);
       dcl-s i int(3);
       dcl-s lColumn   pointer;
       dcl-ds Column likeDs(tColumn) based(pColumn);
       dcl-s string char(32000);
       sflDsp=*off;
       sflClr=*on;
       write ctl1;

       // header
       sflRrn1=1;
       zfil=xview_setHdrs(XView:0);
       // Loop on each row
       for sflRRN1=1 to 19;
         xCho=dtas(sflRRN1).choice;
         xFil1='';
         if rcds(sflRRN1).row=0;
           return;
         endIf;
         format.pBuffer1=dtas(sflrrn1).info;
         // Loop on each cell
         // Loop on each cell
         lColumn=XView.left.lColumn;
         dow 1=1;
           pColumn=tree_getItem(lColumn);
           string=int_FormulaExec(column.lFormula);
           // test column position
           if lColumn=XView.right.lColumn;
             // right column
             %subst(xFil1:Column.pos:XView.right.width)
             =%subst(String:XView.right.pos:XView.right.width);
             if Column.pos+XView.right.width<%len(xFil1);
               // right attribut
               %subst(xFil1:Column.pos+XView.right.width:1)=x'20';
             endif;
             leave;
           elseif lColumn=XView.left.lColumn;
             // left column
             %subst(xFil1:Column.pos:XView.left.width)
             =%subst(String:XView.left.pos:XView.left.width);
           else;
             // mid column
             %subst(xFil1:Column.pos)=%subst(String:1:column.maxWidth);
           endif;
           lColumn=tree_getNext(lColumn);
         endDo;
         write sfl1;
       endFor;
       end-proc;
      // --------------------------------------------------------------------
      // control input
      // --------------------------------------------------------------------
       dcl-proc  Control;
       dcl-pi *n ind;
       end-pi;
       dcl-s error ind inz(*off);
       readc sfl1;
       dow not %eof;
        dtas(sflrrn1).choice=xCho;
        if %scan(xCho:' 5')=0;
         msg_SndPM(pgmID:'Option "'+xCho+'" incorrect');
         error=*on;
         *in01=*on;
        else;
         *in01=*off;
        endIf;
        update sfl1;
        readc sfl1;
       endDo;
       return error;
       end-proc;
      // --------------------------------------------------------------------
      // Roll-down
      // --------------------------------------------------------------------
       dcl-proc  RollDown;
       if g.row1+19>g.row_max;
         msg_SndPM(pgmID:'You have reached the bottom of the list');
       else;
         g.toLoad=*on;
         g.row1+=19;
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Roll-up
      // --------------------------------------------------------------------
       dcl-proc  RollUp;
       if g.row1=1;
         msg_SndPM(pgmID:'You have reached the top of the list');
       elseif g.row1-19<1;
         g.row1=1;
       else;
         g.toLoad=*on;
         g.row1-=19;
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Enter
      // --------------------------------------------------------------------
       dcl-proc  Enter;
       dcl-s i uns(3);
        for i=1 to 19;
          if dtas(i).choice='5';
            msg_SndPM(pgmID:'5 is processed');
            dtas(i).choice='';
            g.fRefresh=*on;
          endIf;
        endFor;
       end-proc;
      // --------------------------------------------------------------------
      // F3=Exit
      // --------------------------------------------------------------------
       dcl-proc  f3;
       G.pScreen=*null;
       end-proc;
      // --------------------------------------------------------------------
      // F10=Move to top
      // --------------------------------------------------------------------
       dcl-proc  f10;
         if sflCsrRrn<=1;
           msg_SndPM(pgmID:'Wrong cursor position.');
         else;
           g.row1=Rcds(SFLCSRRRN).row;
         endIf;
       end-proc;
      // --------------------------------------------------------------------
      // F19=Left tab on all
      // --------------------------------------------------------------------
       dcl-proc  f19;
        dcl-s fF19 ind inz(*off);
        if not XView.Left.most;
          g.fRefresh=*on;
          fF19=*on;
          xview_TabLeft(XView:127);
        endIf;
        if not fF19;
          msg_SndPM(pgmID:'Format is on the most left position');
        endIf;
       end-proc;
      // --------------------------------------------------------------------
      // F20=Right
      // --------------------------------------------------------------------
       dcl-proc  f20;
        dcl-s fF20 ind inz(*off);
        if not XView.Right.most;
          fF20=*on;
          g.fRefresh=*on;
          xview_TabRight(XView:127);
        endIf;
        if not fF20;
          msg_SndPM(pgmID:'Format is on the most right position');
        endIf;
       end-proc;
      // --------------------------------------------------------------------
      // ouverture du sql
      // --------------------------------------------------------------------
       dcl-proc openSql;
       dcl-s sqlStm varChar(200);
       dcl-s lXView pointer;
       dcl-ds XView likeDs(tXView) based(pXView);
       dcl-s lFormat pointer;

        sqlStm='select row_number() over(order by clid)'
              +',''CLIENT2$'',rrn(m) '
              +'from client2$ m '
              +'order by 1';

        exec sql prepare s1 from :sqlStm;
        exec sql declare i1 scroll cursor for s1;
        exec sql open i1;
        // -- the last row is memorized
        exec sql fetch last from i1 into :Rcd;
        g.row_max=rcd.row;
        // --
        lXview=xview_getXView(a.lXViews:a.lGrids:a.lFormats:'CLIENT2$');
        pXview=tree_getItem(lXView);
        xview_posToMostLeft(XView:127);
        // --
        lFormat=fmt_GetFormat(a.lFormats:'CLIENT2$');
        pFormat=tree_getItem(lFormat);
       end-proc;
      // --------------------------------------------------------------------
      // ouverture du fichier
      // --------------------------------------------------------------------
       dcl-proc openFile;
      *
        dcl-s lFile pointer;
      *
        lFile=file_getFile(a.lFiles:'CLIENT2$');
        pFile=tree_getItem(lFile);
        file.hFile=rOpen('*LIBL     /CLIENT2$':'rr,nullcap=Y');
       end-proc;
