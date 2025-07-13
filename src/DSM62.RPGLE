     h nomain                     BndDir('U7')
      /copy cpy,u7ibm_h
      /copy cpy,u7msg_h
      /copy cpy,u7tree_h
      /copy cpy,QSNAPI_H
      /copy cpy,dsm62_h
     d fldSeqKO1       s              3u 0 inz(0)
      // --------------------------------------------------------------------
      // set currenct screen
      // --------------------------------------------------------------------
     pdsm_setCurScreen...
     p                 b                   export
     ddsm_setCurScreen...
     d                 pi
     d  lScreens                       *                               const
     d  screenID                     10a   varying                     const
      //
     d  screens        ds                  likeDs(tScreens) based(pScreens)

       pScreens=tree_getItem(lScreens);
       screens.lCurScreen=tree_getLinkfromList(lScreens:kScreens:screenID);

     p                 e
      // --------------------------------------------------------------------
      // refresh current screen
      // --------------------------------------------------------------------
     pdsm_refresh      b                   export
     d dsm_refresh     pi              *
     d  lScreens                       *   const
     d  screens        ds                  likeDs(tScreens) based(pScreens)
     d  curScreen      ds                  likeDs(tScreen)  based(pCurScreen)

        pScreens=tree_getItem(lScreens);
        pCurScreen=tree_getItem(screens.lCurScreen);
        curScreen.toRefresh=*on;
     p                 e
      // --------------------------------------------------------------------
      // define screen
      // --------------------------------------------------------------------
     pdsm_setScreen    b
     d dsm_setScreen   pi
     d  lScreens                       *                                   const
     d  screenID                     10a   varying                         const
     d  pCliGetter                     *   procptr                         const
     d  pCliTweaker                    *   procptr                         const
     d  pCliChecker                    *   procptr                         const
      //
     d pScreens        s               *
     d Screen          ds                  likeDs(tScreen)  based(pScreen)
     d lScreen         s               *   inz(*null)
       if lScreens=*null;
         pScreen=tree_getNewItem(%addr(tScreens):%size(tScreens));
         lScreens=tree_getNewLink(pScreens);
       endIf;
       lScreen=tree_getLinkFromList(lScreens:kScreen:screenID);
       if lScreen=*null;
         pScreen=tree_getNewItem(%addr(tScreen):%size(tScreen));
         screen.ID=screenID;
         qsnCrtInpBuf(2000:200:0:screen.inpBuf:*omit);
         qsnCrtCmdBuf(2000:200:0:screen.cmdBuf:*omit);
         screen.lFKS=tree_getNewLink(*null);
         screen.pCliGetter =pCliGetter ;
         screen.pCliTweaker=pCliTweaker;
         screen.pCliChecker=pCliChecker;
         lScreen=tree_getNewLink(pScreen);
         tree_linkToParent(lScreens:lScreen);
       endIf;
       return lScreen;
     p                 e
      // --------------------------------------------------------------------
      // define area
      // --------------------------------------------------------------------
     pdsm_setarea      b                   export
     d dsm_setArea     pi              *
     d  lScreen                        *   const
     d  ID                           10a   const
     d  y                             3u 0 const
     d  x                             3u 0 const
     d  height                        3u 0 const
     d  width                         3u 0 const
     d  size                          3u 0 const
     d  pDefiner                       *   const procPtr
      *
     d screen          ds                  likeDs(tScreen) based(pScreen)
     d area            ds                  likeDs(tarea  ) based(pArea  )
     d lArea           s               *
       pScreen=tree_getItem(lScreen);
       lArea=tree_getLinkFromList(lScreen:kArea:ID);
       if lArea=*null;
         pArea=tree_getNewItem(%addr(tArea):%size(tArea));
       else;
         pArea=tree_getItem(lArea);
       endIf;
       area.ID=ID;
       area.y=y;
       area.x=x;
       area.height=height;
       area.width =width;
       qsnCrtCmdBuf(2000:200:0:area.cmdBuf:*omit);
       area.rY=0;
       area.rX=1;

       if size>0;
         area.seq1=screen.seq9+1;
         area.seq =area.seq1;
         area.size=size;
         screen.seq9+=size;
       endif;

       area.pDefiner=pDefiner;
       lArea=tree_getNewLink(pArea);
       tree_linkToParent(lScreen:lArea);
       return lArea;
     p                 e
      // --------------------------------------------------------------------
      // save new function key
      // --------------------------------------------------------------------
       dcl-proc dsm_setFK export;
       dcl-pi dsmSetFK;
         lScreen   pointer        const;
         key       char(1)        const;
         fControl  ind            const;
         pAction   pointer(*proc) const;
         text0     varChar(30)    const options(*nopass);
         text1     varChar(30)    const options(*nopass);
       end-pi;
      *
       dcl-ds screen likeDs(tScreen) based(pScreen);
       dcl-ds FK     likeDs(tFK    ) based(pFK    );
       dcl-s lFK pointer;
       pScreen=tree_getItem(lScreen);
       pFK=tree_getNewItem(%addr(tFK):%size(tFK));
       FK.key=key;
       FK.fControl=fControl;
       FK.pAction=pAction;
       lFK=tree_getNewLink(pfk);
       tree_linkToParent(screen.lFKS:lFK);
       if %parms()=%parmnum(text0);
         dsm_setFKC(lFK:'0':text0);
       endIf;
       if %parms()=%parmnum(text1);
         dsm_setFKC(lFK:'1':text1);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // set function key context
      // --------------------------------------------------------------------
       dcl-proc dsm_setFKC;
       dcl-pi dsm-setFKC;
         lFK pointer      const;
         ID  char(1)      const;
         text varChar(30) const;
       end-pi;
      *
       dcl-ds FKC likeDs(tFKC) based(pFKC);
       pFKC=tree_getNewItem(%addr(tFKC):%size(tFKC));
       FKC.ID=ID;
       FKC.text=text;
       tree_linkToParent(lFK:tree_getNewLink(pFKC));
       end-proc;
      // -----------------------------------------------------------------------
      // get function key entitle
      // -----------------------------------------------------------------------
       dcl-proc dsm_getfkentitle export;
       dcl-pi dsm_getfkentitle varchar(123);
         lScreens pointer const;
       end-pi;
      *
       dcl-ds Screens likeds(tScreens) based(pScreens);
       dcl-ds Screen  likeds(tScreen)  based(pScreen);
       dcl-s lFK pointer;
       dcl-s wFK varchar(123)  inz('');
       dcl-ds FKC likeds(tFKC) based(pFKC);
       dcl-s lFKC pointer;
       pScreens=tree_getItem(lScreens);
       pScreen =tree_getItem(Screens.lCurScreen);
       lFK=tree_getFirst(lFKs);
       dow lFK<>*null;
         lFKC=tree_getFirst(lFK);
         if lFKC<>*null;
           pFKC=tree_getItem(lFKC);
           wFK+=FKC.text+'  ';
         endIf;
         lFK=tree_getNext(lFK);
       endDo;
       return wfk;
       end-proc;
      // --------------------------------------------------------------------
      // clear and initialize the screen
      // --------------------------------------------------------------------
     pDsm_ClrScr       b                   export
     d Dsm_ClrScr      pi
        qsnClrScr('4':*omit:*omit:*omit);
     p                 e
      // --------------------------------------------------------------------
      // clear area
      // --------------------------------------------------------------------
     pdsm_ClearArea    b                   export
     d dsm_ClearArea   pi
     d  lArea                          *                                   const
      *
     d ry              s              3u 0
     d area            ds                  likeDs(tArea)   based(pArea)
     d screen          ds                  likeDs(tScreen) based(pScreen)
       pArea=tree_getItem(lArea);
       qsnClrBuf(area.cmdBuf:*omit);
       area.ry=0;
       area.rx=1;
       if area.size>0;
         pScreen=tree_getItem(tree_getParent(lArea));
         clear %subarr(Screen.fldMap
                      :area.seq1
                      :area.size);
       endIf;
       area.seq=area.seq1;
     p                 e
      // --------------------------------------------------------------------
      // refresh requested
      // --------------------------------------------------------------------
     pdsm_AreaRefresh  b
     ddsm_AreaRefresh  pi
     d  lArea                          *   const
     d  toRefresh                      n   const options(*nopass)
      *
     d screen          ds                  likeDs(tScreen) based(pScreen)
     d area            ds                  likeDs(tArea  ) based(pArea  )
       pScreen=tree_getItem(tree_getParent(lArea));
       pArea=tree_getItem(lArea);
       if %parms()=%parnum(toRefresh);
        area.toRefresh=toRefresh;
       else;
        area.toRefresh=*on;
       endIf;
       if area.toRefresh=*on;
         screen.toRefresh=*on;
       endIf;
     p                 e
      // --------------------------------------------------------------------
      // print text in area
      // --------------------------------------------------------------------
     pdsm_print        b                   export
     d dsm_print       pi
     d  lArea                          *                                   const
     d  atr1                          1a                                   const
     d  text                        100a   varying                         const
      *
     d area            ds                  likeDs(tArea) based(pArea)
       pArea=tree_getItem(lArea);
       if %len(text)>0;
         qsnwrtdta(text
                  :%len(text)
                  :0
                  :area.y+area.ry
                  :area.x+area.rx
                  :x'00':x'00'
                  :atr1:x'20'
                  :area.cmdBuf
                  :0:*omit);
       endIf;
       // new position
       if area.rx+%len(text)+1>=area.width;
         area.rx=1;
         area.ry+=1;
       else;
         area.rx+=%len(text)=1;
       endIf;
     p                 e
      // --------------------------------------------------------------------
      // print text in area
      // --------------------------------------------------------------------
     pdsm_printLN      b                   export
     d dsm_printLN     pi
     d  lArea                          *                                   const
     d  atr1                          1a                                   const
     d  text                        100a   varying                         const
      *
     d area            ds                  likeDs(tArea) based(pArea)
       // print
       dsm_print(lArea:atr1:text);
       // next Line
       pArea=tree_getItem(lArea);
       area.rx=1;
       area.ry+=1;
     p                 e
      // --------------------------------------------------------------------
      // line next
      // --------------------------------------------------------------------
     pdsm_lineNext     b                   export
     d dsm_lineNext    pi
     d  lArea                          *
      *
     d area            ds                  likeDs(tArea) based(pArea)
       // Next line
       pArea=tree_getItem(lArea);
       area.ry+=1;
       area.rx=1;
     p                 e
      // --------------------------------------------------------------------
      // print field in area
      // --------------------------------------------------------------------
     pdsm_printField   b                   export
     d dsm_printField  pi
     d  lArea                          *                                   const
     d  lItem                          *                                   const
     d  origin                       10a                                   const
     d  length                        3u 0                                 const
     d  fLock                          n   options(*nopass)                const
     d  fMDT                           n   options(*nopass)                const
      *
     d  fLock_         s               n   inz(*off)
     d  fMDT_          s               n   inz(*off)
     d  lScreen        s               *
     d  Screen         ds                  likeDS(tScreen) based(pScreen)
     d  Area           ds                  likeDS(tArea  ) based(pArea  )
     d  FFW            s              2a   inz(QSN_FFW_ALPHA_SHIFT)
     d A1000           s           1000a
     d strColAtrDef    s              1a   inz(QSN_SA_GRN_UL)
     d cliGetter       pr          1000A   extProc(screen.pCliGetter)
     d  lX                             *   const
     d  origin                       10a   varying const
      *
       if %parms()>=%parmNum(fMDT);
         fMdt_=fMdt;
       endif;
       pArea=tree_getItem(lArea);
       lScreen=tree_getParent(lArea);
       pScreen=tree_getItem(lScreen);
       qsnSetFld(area.seq
                :length
                :area.y+area.rY
                :area.x+area.rX
                :ffw
                :*omit
                :0
                :*omit
                :strColAtrDef
                :area.cmdBuf
                :*omit
                :*omit);

       screen.fldMap(area.seq).y           =area.y+area.ry;
       screen.fldMap(area.seq).x           =area.x+area.rx;
       screen.fldMap(area.seq).lItem       =lItem;
       screen.fldMap(area.seq).fMdt        =fMdt_;
       screen.fldMap(area.seq).strColAtrDef=strColAtrDef;
       screen.fldMap(area.seq).length      =length      ;
       screen.fldMap(area.seq).origin      =origin      ;

       // new position
       if area.rx+length+1>=area.width;
         area.rx=1;
         area.ry+=1;
       else;
         area.rx+=length+1;
       endIf;

       area.seq+=1;
     p                 e
      // --------------------------------------------------------------------
      // receive program message to dedicated box
      // --------------------------------------------------------------------
     pdsm_rcvPM        b                   export
     d dsm_rcvPM       pi
     d  pn                           10    const
     D QMHRCVPM        PR                  ExtPgm('QMHRCVPM')
     D   MsgInfo                  32766A   options(*varsize)
     D   MsgInfoLen                  10I 0 const
     D   Format                       8A   const
     D   StackEntry                  10A   const
     D   StackCount                  10I 0 const
     D   MsgType                     10A   const
     D   MsgKey                       4A   const
     D   WaitTime                    10I 0 const
     D   MsgAction                   10A   const
     D   ErrorCode                 1024A   options(*varsize)
     D rcvm0100        ds                  qualified
     D  BytesReturned                10i 0 overlay(rcvm0100:1)
     D  BytesAvail                   10i 0 overlay(rcvm0100:5)
     d  msgKey                        4a   overlay(rcvm0100:22)
     D  LenOfMsg                     10i 0 overlay(rcvm0100:41)
     D  MsgTxt                      130a   overlay(rcvm0100:49)
      *
     d msgKey          s              4a
       clear msgBox;
       clear rcvm0100;
       dow 1=1;
         QMHRCVPM(Rcvm0100
                 :%size(RCVM0100)
                 :'RCVM0100'
                 :pn
                 :0
                 :'*INFO'
                 :'    '
                 :0
                 :'*REMOVE'
                 :APIErr);
         if rcvm0100.bytesAvail=0;
           leave;
         endif;
         if msgBox.msgSeq>0;
           %subst(msgBox.msgTxt(msgBox.msgSeq):130:1)='+';
         endIf;
         msgBox.msgSeq+=1;
         msgBox.msgTxt(msgBox.msgSeq)=rcvm0100.msgTxt;
         msgBox.msgMax+=1;
       endDo;
     p                 e
      // --------------------------------------------------------------------
      // Display the screen
      // --------------------------------------------------------------------
     pdsm_DspScr       b                   export
     ddsm_DspScr       pi
     d  lScreen                        *                                   const
      *
     d  screen         ds                  likeDs(tScreen) based(pScreen)

       pScreen=tree_getItem(lScreen);

       if screen.toRefresh;
         dsm_DspScr2(lScreen);
       endIf;
       // First message (can be empty)
       qsnWrtDta(msgBox.msgTxt(1)
                :130:0
                :27:2
                :x'00':x'00'
                :qsn_sa_wht:x'20'
                :*omit
                :0:*omit);
       // position
       if fldSeqKO1>0;
         qsnInsCsr(fldSeqKO1
                  :0
                  :0
                  :*omit
                  :*omit
                  :*omit);
       endif;
       fldSeqKO1=0;
     p                 e
      // --------------------------------------------------------------------
      // Display the screen 2
      // --------------------------------------------------------------------
     pdsm_DspScr2      b
     ddsm_DspScr2      pi
     d  lScreen                        *   const
      *
     d screen          ds                  likeDs(tScreen) based(pScreen)
     d lArea           s               *
     d area            ds                  likeDs(tArea)   based(pArea)
     d fldSeq          s              3u 0
     d lX              s               *
      *
     d A1000           s           1000a
     d onError         s               n
     d strColAtr       s              1a
      *
     d areaDefiner     pr                  extProc(area.pDefiner)
      *
     d cliGetter       pr          1000a   extProc(screen.pCliGetter)
     d  lX                             *   const
     d  origin                       10a   const
     d  onError                        n
      *
       pScreen=tree_getItem(lScreen);
       qsnclrbuf(screen.cmdbuf:*omit:*omit);
       qsnclrScr('0':screen.cmdBuf:*omit:*omit);
       screen.toRefresh=*off;
       // loop on each area
       lArea=tree_getFirst(lScreen);
       dow lArea<>*null;
         pArea=tree_getItem(lArea);
         // refresh requested
         if area.toRefresh
        and area.pDefiner<>*null;
          area.toRefresh=*off;
          dsm_clearArea(lArea);
          areaDefiner();
        endIf;
        // merge buffers
        qsncpybuf(area.cmdBuf:screen.cmdBuf:*omit);
        // loop on each place bokked for the area
        if area.seq1>0;
          for fldSeq=area.seq1 to area.seq1+area.size-1;
            lX=screen.fldMap(fldSeq).lItem;
            if lX=*null;
              leave;
            endIf;

            a1000=cliGetter(lX
                           :screen.fldMap(fldSeq).origin
                           :onError);

            if onError;
              strColAtr=QSN_SA_GRN_UL_RI;
            else;
              strColAtr=screen.fldMap(fldSeq).strColAtrDef;
            endIf;

            qsnWrtDta(A1000
                     :screen.fldMap(fldSeq).length
                     :fldSeq
                     :0:0
                     :*omit:*omit
                     :strColAtr:*omit
                     :screen.cmdBuf
                     :0:*omit);

             endFor;
           endIf;
           lArea=tree_getNext(lArea);
         endDo;
         // send buffer to screen
         qsnputbuf(screen.cmdBuf:0:*omit);
     p                 e
      // --------------------------------------------------------------------
      // get AID
      // --------------------------------------------------------------------
     pdsm_getAID       b                   export
     d dsm_getAID      pi             1a
     d  lScreen                        *                                   const
     d  csrx                         10i 0
     d  csry                         10i 0
      *
     d screen          ds                  likeDs(tScreen) based(pScreen)
     d fldMdtCount     s             10i 0
     d AID             s              1a
     d msgTxt          s            130a
       pScreen=tree_getItem(lScreen);
       qsnGetCsrAdrAID(csry:csrx:aid:0:*omit);
       qsnReadMDTImmAlt(fldMdtCount
                       :screen.inpBuf
                       :*omit:*omit:*omit);
       dsm_readMdt2(screen:fldMdtCount);
       if csrY=27;
         msgBox.msgSeq=1;
         dow csrY=27 and (aid=Qsn_RollDown or aid=Qsn_RollUp);
           QsnInsCsr(0
                    :csrY
                    :csrX
                    :*omit
                    :*omit
                    :*omit);
           if msgBox.msgSeq>1 and aid=Qsn_RollDown;
             msgBox.msgSeq-=1;
           elseif msgBox.msgSeq<msgBox.msgMax and aid=Qsn_RollUp;
             msgBox.msgSeq+=1;
           else;
             msgTxt='Roll up or down past the first or last record in file.';
             qsnSetErr(MsgTxt
                      :%len(%trim(MsgTxt))
                      :*omit
                      :csrY
                      :csrX
                      :*omit
                      :*omit
                      :qsn_sa_wht
                      :*omit
                      :*omit
                      :*omit
                      :*omit);
           endIf;
           qsnWrtDta(msgBox.msgTxt(msgBox.msgSeq)
                    :130
                    :0
                    :27
                    :2
                    :x'00':x'00'
                    :qsn_sa_wht:x'20'
                    :*omit
                    :0:*omit);
           qsnGetCsrAdrAID(csry:csrx:aid:0:*omit);
         enddo;
         QsnReadMDTImmAlt(FldMdtCount
                         :screen.inpBuf
                         :*omit:*omit:*omit);
         dsm_readMdt2(screen:fldMdtCount);
       endIf;
       reset msgBox;
       return aid;
     p                 e
      // --------------------------------------------------------------------
      // read modified fields (part 2)
      // --------------------------------------------------------------------
     pdsm_ReadMdt2     b
     d dsm_ReadMdt2    pi
     d screen                              likeDs(tScreen)
     d fldMdtCount                   10i 0
      *
     d cliTweaker      pr                  extproc(screen.pCliTweaker)
     d  lX                             *                                   const
     d  origin                       10a                                   const
     d  v1000                      1000a   varying                         const
      *
     d fldMdtIdx       s             10i 0
     d fldInf          ds                  likeDs(tFldInf)
     d i               s             10i 0
     d a1000           s           1000a   inz('')
     d v1000           s           1000a   varying
       for FldMdtIdx=1 to FldMdtCount;
         QsnRtvFldInf(screen.inpBuf
                     :FldMdtIdx
                     :fldInf
                     :%len(fldInf)
                     :*omit:*omit);
         i=%lookup(fldInf.rowcol:screen.FldMap(*).yx);
         screen.fldMap(i).fMDT=*on;
         a1000='';
         memCpy(%addr(a1000)
               :fldInf.pDta
               :fldInf.Dtalen);

         v1000=%subst(a1000:1:fldInf.dtaLen);

         cliTweaker(screen.fldMap(i).lItem
                   :screen.fldMap(i).origin
                   :v1000);
       endFor;
     p                 e
      // --------------------------------------------------------------------
      // read modified fields (part 2)
      // --------------------------------------------------------------------
       dcl-proc dsm_processFK export;
       dcl-pi dsm_processFK;
         pgmid   char(10)        const;
         lScreen pointer         const;
         FKID    char(1)         const;
       end-pi;
      *
       dcl-ds screen likeDS(tScreen) based(pScreen);
       dcl-ds FK     likeDs(tFK)     based(pFK);
       dcl-s  lFK    pointer;
     d fkAction        pr            extproc(FK.pAction)
     d ko              c             const(*on)
       // Check if the function key is allowed
       pScreen=tree_getItem(lScreen);
       // Check if the function key is allowed
       lFK=tree_getLinkFromList(screen.lFKs:kFK:FKID);
       if lFK=*null;
         msg_sndPM(pgmID:'Function key invalid');
         return;
       endIf;
       // get the function key
       pFK=tree_getItem(lFK);
       // if control needed process it
       if FK.fControl
       and dsm_control(lScreen)=ko:
         return;
       endIf;
       // no errors : perform the action seek to function key
       if FK.pAction<>*null;
         fKaction();
       endIf;
       end-Proc;
      // -----------------------------------------------------------------------
      // control
      // -----------------------------------------------------------------------
     pdsm_control      b                   export
     d dsm_control     pi              n
     d  lScreen                        *                                   const
      *
     d screen          ds                  likeDs(tScreen) based(pScreen)
     d clichecker      pr                  extproc(screen.pCliChecker)
     d  lItem                          *                                   const
     d  origin                       10a                                   const
     d  A1000                      1000a                                   const
      *
     d fldSeq          s              3u 0
     d fError          s               n   inz(*off)
     d ko              c                   const(*on)
     d a1000           s           1000a   inz('')
     d strColAtr       s              1a
      *
       fldSeqKO1=0;
       pScreen=tree_getItem(lSCreen);
       for fldSeq=1 to screen.seq9;
         // empty
         if screen.fldMap(fldSeq).lItem=*null;
           leave;
         endif;
         // not modified
         if not screen.fldMap(fldSeq).fMDT;
           iter;
         endIf;
         if cliChecker(screen.fldMap(fldSeq).lItem
                      :screen.fldMap(fldSeq).origin
                      :a1000)=ko;
           tree_setError(screen.fldMap(fldSeq).lItem:*on);
           screen.fldMap(fldSeq).fMdt=*on;
           strColAtr=QSN_SA_GRN_UL_RI;
           fError=*on;
           if fldSeqKO1=0;
             fldSeqKO1=fldSeq;
           endIf;
         else;
           tree_setError(screen.fldMap(fldSeq).lItem:*off);
           screen.fldMap(fldSeq).fMDT=*off;
           strColAtr=screen.fldMap(fldSeq).strcolAtrDef;
         endIf;
      // 2) rewrite the field with current attribute
       qsnWrtDta(a1000
                :screen.fldMap(fldSeq).length
                :fldSeq
                :0:0
                :*omit:*omit
                :strColAtr:*omit
                :*omit
                :0:*omit);
       endfor;
      * cursor position on first error
       if fldSeqKO1>0;
         QsnInsCsr(fldSeqKO1
                  :0
                  :0
                  :*omit
                  :*omit
                  :*omit);
       endIf;
       return fError;
     p                 e
      // -----------------------------------------------------------------------
      // 
      // -----------------------------------------------------------------------
     pdsm_go           B                   export
     d dsm_go          pi
     d  pgmID                        10a            const
     d  lScreens                       *
     d  screenID                     10a   varying  const
      *
     d screens         ds                  likeDs(tScreens) based(pScreens)
     d curScreen       ds                  likeDs(tScreen)  based(pCurScreen)
     d AID             s              1a
     d csrX            s             10i 0
     d csrY            s             10i 0
        dsm_clrScr();
        dsm_setCurScreen(lScreens:screenID);
        // receive the messages
        dsm_RCVPM(pgmID);
        // display the screen
        dsm_dspScr(screens.lCurScreen);
        // get AID
        AID=dsm_getAID(screens.lCurScreen:csrX:csrY);
        // process the FK
        dsm_processFK(pgmID:screens.lCurScreen:AID);
     p                 e
