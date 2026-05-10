      /If Defined(*CRTBNDRPG)
     h oPTION(*NODEBUGIO:*SRCSTMT:*noshowcpy)
     h DFTACTGRP(*NO) BndDir('U7')
     h main(PGMWW)
      /endif
       dcl-f pgmwwd WORKSTN SFILE(SFL1:SFlRRN) InfDS(wsDS);
      /include cpy,pgmww_h
      /include cpy,U7env_h
      /include cpy,U7xml_h
      /include cpy,U7tree_h
      /include cpy,U7ibm_h
      /include cpy,U7msg_h
      /include cpy,U7Screen_h
     d screen          s              3u 0
      // Screen relatives
     d lRows           s               *   dim(19) inz(*null)
     d lRow1           s               *
     d lRow1_b4        s               *
     d lRow9           s               *   inz(*null)
     d lRow9_b4        s               *   inz(*null)
     d refresh         s               n
     d lastProcessed   s               *   inz(*null)
      // Main link
     d  lRoot          s               *
      // link for function keys
     d lFKs            s               *
      // --------------------------------------------------------------------
      // main
      // --------------------------------------------------------------------
     ppgmww            b
     d pgmww           pi
     d   ID                          30    const

       msg_sndPM  (pgmID:'(C) COPYRIGHT BMI. 2008, 2017.');
       lRoot=xml_xml2tree(env_getClientpath()+'pgm/'+%trim(Id)+'.pgm'
                         :%pAddr(pgm_XmlInput));
       loadfkS();
       interact();
       close pgmwwd;
     p                 e
      // ------------------------------------------------------------------*
      // loading function keys
      // -------------------------------------------------------------------
     ploadFKS          b
       // Load function keys
       screen_setFK(lFKs:x'33':'0':%pAddr(F3):'F3=Exit');
       screen_setFK(lFKs:x'3a':'1':%pAddr(f10):'F10=Move to top');
       screen_setFK(lFKs:x'f1':'1':%pAddr(Enter));
       screen_setFK(lFKs:x'f4':*ON :%pAddr(rollUP));
       screen_setFK(lFKs:x'f5':*ON :%pAddr(rolldown));
       zFKs=screen_getfkentitle(lFKs);
     p                 e
      // -------------------------------------------------------------------
      // interactive
      // -------------------------------------------------------------------
     pinteract         b
     d root            ds                  likeds(tRoot) based(pRoot)
     d wtitle          s            129a   varying
       // Main title
       pRoot=tree_getItem(lRoot);
       wTitle='Work with cross references : ' +
       Root.ID + ' ' + Root.title;
       // first row to display
       Screen=1;
       lRow1=tree_GetFirstToDisplay(lRoot);
       // Work screens
       wrkScreen();
     p                 e
      // -------------------------------------------------------------------
      // work screens
      // -------------------------------------------------------------------
     pwrkScreen        b
       dow screen>0;
         if screen=1;
           Screen1();
         endif;
       endDo;
     p                 e
      // --------------------------------------------------------------------
      // Screen 1 - display XRef
      // --------------------------------------------------------------------
     pScreen1          b
       if lRow9<>lRow9_b4;
         sync();
       endIf;
       // Load rows
       if lRow1<>lRow1_b4 or refresh;
         loadRows();
         lRow1_B4=lRow1;
         Refresh=*Off;
         reset lastProcessed;
       endIf;
       // more item or bottom of list
       if tree_getnexttodisplay(lRoot:lRow9)=*null;
         mySflEnd='Bottom';
       else;
         mySflEnd='More...';
       endIf;
       // write and read screen formats
       csrToRow=15;
       write msgctl;
       write hdr1;
       if SflRRN=0;
         write empty1;
       else;
         *in88=*on;
       endif;
       *in89=*off;
       write ctl1;
       read hdr1;
       read ctl1;
       // Clear messages
       msg_rmvPM(pgmID);
       // get/launch function key
       screen_processFK(pgmID:lFKs:wsds.kp:%pAddr(Control));
     p                 e
      // -----------------------------------------------------------------------
      // Load rows
      // -----------------------------------------------------------------------
     ploadRows         b
     d lRowx           s               *
     d NO              s              3u 0
     d level           s              3u 0
     d wFil            s             60    varying
     d wFil2           s             60
     d pgm             ds                  likeds(tPgm) based(pPgm)
       // *) Clear screen
       *in88=*off;
       *in89=*on;
       WRITE ctl1;
       reset lRows;
       reset csrToRow;
       // *) Load ancestors                                                  s
       lRowx=tree_getParent(lRow1);
       dow lRowx<>*null;
         if lRowx=lRoot;
           leave;
         endIf;
         lRows(tree_getLevel(lRowx))=lRowx;
         lRowx=tree_getParent(lRowx);
       endDo;
       // *) Load nexts                                                      s
       lRowx=lRow1;
       for NO=tree_getLevel(lRowx) to 19;
          lRows(NO)=lRowx;
          lRowx=tree_getNextToDisplay(lRoot:lRowx);
          if lRowx=*null;
            leave;
          endIf;
       endFor;
       // *) Load subfile
       for SflRRN=1 to 19;
         if lRows(SflRRN)=*Null;
           leave;
         endIf;
         lRowx=lRows(sflRRN);
         lRow9=lRowX;
         // get item pgm
         pPgm=tree_getItem(lRowx);
         // get level
         level=tree_getLevel(lRowx);
         // Clear indicators
         clear %SubArr(*in:1:8);
         // Set option
         xOpts(level)=tree_getOption(lRowx);
         // +/-
         if tree_GetFirst(lRowx)=*null;
           xButs(level)='';
         elseif tree_isOpen(lRowx);
           xButs(level)='-';
         else;
           xButs(level)='+';
         endif;
         wFil=pgm.text;
         wFil+=' ';
         wFil2=*all'. ';
         *in(level)=*on;
         %subst(wFil2:1:%len(wFil))=wFil;
         memcpy(pXFils(level)
               :%addr(wFil2)
               :62-level*2);
         xText=Pgm.id;
         *in87=lRows(SflRRN)=lastProcessed;
         // Error
         *in88=tree_onError(lRows(SflRRN));
         write sfl1;
       endFor;
       lRow9_b4=lRow9;
     p                 e
      // -----------------------------------------------------------------------
      // sync
      // -----------------------------------------------------------------------
     psync             b
     d pX              s               *
     d i               s              3u 0
     d level           s              3u 0
     d pgm             ds                  likeds(tPgm) based(pPgm)
       lRow1=lRow9;
       pX=lRow9;
       for i=19 downto 1;
         if px=*null;
           leave;
         endIf;
         level=tree_getLevel(pX);
         if level=0 or level>i;
           leave;
         endIf;
         lRow1=pX;
         pX=tree_getPrevtodisplay(lRoot:pX);
       endfor;
     p                 e
      // -----------------------------------------------------------------------
      // control
      // -----------------------------------------------------------------------
     pcontrol          b

     d wOpt            s              1a
     d lRow            s               *
     d i               s              3u 0
       //
       for i=1 to 19;
         lRow=lRows(sflrrn);
         if lRow=*null;
           leave;
         endIf;
         tree_seterror(lRow:*off);
       endFor;

       readc sfl1;
       dow not %eof();

         refresh=*on;

         lRow=lRows(sflrrn);
         wOpt=xOpts(tree_getLevel(lRow));

         tree_setOption(lRow:wOpt);
         tree_seterror(lRow:%scan(wopt:'+-5 ')=0);

         if tree_onError(lRow);
           msg_sndPM (pgmID:'Option '+ wOpt +' is not valid.');
         endIf;
         readc sfl1;
       endDo;
     p                 e
      // --------------------------------------------------------------------
      // get item for PGM family
      // --------------------------------------------------------------------
       dcl-proc pgm_XMLinput export;
       dcl-pi pgm_XMLinput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pi;

       dcl-ds root    likeds(tRoot)   based(pRoot);
       dcl-ds pgm     likeds(tPgm)    based(pPgm);

       if ND.ID='ROOT';
         pRoot=tree_getnewitem(%addr(tRoot):%size(tRoot));
         root.ID  =xml_getAttAsString('ID':ND.atts);
         root.title=ND.text;
         return pRoot;
       elseIf ND.ID='PGM';
         pPgm=tree_getnewitem(%addr(tPgm):%size(tPgm));
         pgm.ID  =xml_getAttAsString('ID':ND.atts);
         Pgm.text=ND.text;
         return pPgm;
       endIf;

       return *null;

       end-proc;
      // --------------------------------------------------------------------
      // F3=Exit
      // --------------------------------------------------------------------
       dcl-proc f3;
       screen=0;
       end-proc;
      // --------------------------------------------------------------------
      // F10=Move to top
      // --------------------------------------------------------------------
       dcl-proc f10;
         if SflCsrRRN=0;
           msg_sndPM(pgmID:'Wrong cursor position.');
         else;
           lRow1=lRows(SflCsrRRN);
         endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Roll-UP
      // --------------------------------------------------------------------
       dcl-proc RollUp;
         if lRow1=tree_GetFirstToDisplay(lRoot);
           msg_sndPM(pgmID:'You have reached the top of the list.');
         else;
           lRow9=tree_getPrevToDisplay(lRoot:lRow1);
         endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Roll-down
      // --------------------------------------------------------------------
       dcl-proc RollDown;
         if mySflEnd='Bottom';
           msg_sndPM(pgmID:'You have reached the bottom of the list.');
         else;
           lRow1=tree_getnexttodisplay(lRoot:lRow9);
         endif;
       end-proc;
      // --------------------------------------------------------------------
      // Enter
      // --------------------------------------------------------------------
       dcl-proc Enter;
       dcl-s lRow pointer;
       dcl-c cmd_ const('STRSEU SRCFILE(SRC) SRCMBR(&1) OPTION(5)');
       dcl-s cmd  varChar(200);
       dcl-ds pgm likeDs(tPgm) based(pPgm);
       dcl-s option char(1);
       lRow=tree_GetFirstToDisplay(lRoot);
       dow lRow<>*null;
         option=tree_getOption(lRow);
         if option='+';
           tree_openLink(lRow);
         elseIf option='-';
           tree_Closelink(lRow);
         elseif option='5';
           pPgm=tree_getItem(lRow);
           cmd=%scanRpl('&1':pgm.id:cmd_);
           monitor;
             qcmdExc(cmd:%len(cmd));
           on-error;
             msg_sndPM(pgmID:'Problem during option processing');
             tree_setError(lRow:*on);
             refresh=*on;
             return;
           endMon;
         endIf;
         if %scan(option:'+-5')>0;
           tree_setOption(lRow:'');
           refresh=*on;
           lastProcessed=lRow;
         endIf;
         lRow=tree_GetNextToDisplay(lRoot:lRow);
       endDo;
       end-proc;
