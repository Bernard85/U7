     h nomain                     BndDir('U7')
      /copy cpy,u7ibm_h
      /copy cpy,u7msg_h
      /copy cpy,u7tree_h
      /copy cpy,QSNAPI_H
      /copy cpy,dsm7_h
      // --------------------------------------------------------------------
      // set current screen
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
       screens.lCurScreen=tree_getLinkfromList(lScreens:kScreen:screenID);

     p                 e
      // --------------------------------------------------------------------
      // refresh current screen
      // --------------------------------------------------------------------
     pdsm_refresh      b                   export
     d dsm_refresh     pi
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
     pdsm_setScreen    b                   export
     d dsm_setScreen   pi              *
     d  lScreens                       *
     d  screenID                     10a   varying  const
     d  pGetter                        *   procptr  const
     d  pSetter                        *   procptr  const
     d  pChecker                       *   procptr  const
      //
     d pScreens        s               *
     d Screen          ds                  likeDs(tScreen)  based(pScreen)
     d lScreen         s               *   inz(*null)
       if lScreens=*null;
         pScreens=tree_getNewItem(%addr(tScreens):%size(tScreens));
         lScreens=tree_getNewLink(pScreens);
       endIf;
       lScreen=tree_getLinkFromList(lScreens:kScreen:screenID);
       if lScreen=*null;
         pScreen=tree_getNewItem(%addr(tScreen):%size(tScreen));
         screen.ID=screenID;
         qsnCrtInpBuf(2000:200:0:screen.inpBuf:*omit);
         qsnCrtCmdBuf(27*132:200:0:screen.cmdBuf:*omit);
         screen.lFKS       =tree_getNewLink(*null);
         screen.pGetter =pGetter ;
         screen.pSetter =pSetter;
         screen.pChecker=pChecker;
         lScreen=tree_getNewLink(pScreen);
         tree_linkToParent(lScreens:lScreen);
       endIf;
       return lScreen;
     p                 e
      // --------------------------------------------------------------------
      // define area
      // --------------------------------------------------------------------
     pdsm_setArea      b                   export
     d dsm_setArea     pi              *
     d  lScreen                        *   const
     d  ID                           10a   const
     d  y                             3u 0 const
     d  x                             3u 0 const
     d  height                        3u 0 const
     d  width                         3u 0 const
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
       qsnCrtCmdBuf(2000:200:0:area.cmdBuf2:*omit);
       area.rY=0;
       area.rX=1;
       area.pDefiner=pDefiner;
       lArea=tree_getNewLink(pArea);
       tree_linkToParent(lScreen:lArea);
       return lArea;
     p                 e
      // --------------------------------------------------------------------
      // save new function key
      // --------------------------------------------------------------------
       dcl-proc dsm_setFK export;
       dcl-pi dsm_SetFK;
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
       if %parms()>=%parmnum(text0);
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
       dcl-pi dsm_setFKC;
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
      // --------------------------------------------------------------------
      // get function key context
      // --------------------------------------------------------------------
       dcl-proc dsm_getFKC export;
       dcl-pi dsm_getfkc char(1);
         lScreens pointer    const;
         key      varchar(1) const;
       end-pi;
       dcl-ds Screens likeds(tScreens) based(pScreens);
       dcl-ds Screen  likeds(tScreen)  based(pScreen);
       dcl-s  lFK     pointer;
       dcl-s  lFKC    pointer;
       dcl-ds FKC     likeds(tFKC) based(pFKC);
       pScreens=tree_getItem(lScreens);
       pScreen =tree_getItem(Screens.lCurScreen);
       lFK=tree_getLinkfromList(screen.lFKS:kFK:key);
       lFKC=tree_getFirst(lFK);
       pFKC=tree_getItem(lFKC);
       return FKC.ID;
       end-proc;
      // -----------------------------------------------------------------------
      // get function keys entitle
      // -----------------------------------------------------------------------
       dcl-proc dsm_getFKtext export;
       dcl-pi dsm_getFKtext varchar(123);
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
       lFK=tree_getFirst(screen.lFKs);
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
     d  lScreen                        *   const
      *
     d  screen         ds                  likeDs(tScreen) based(pScreen)
        qsnClrScr('4':*omit:*omit:*omit);
        pScreen=tree_getItem(lScreen);
        screen.toRefresh=*on;
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
       qsnClrBuf(area.cmdBuf2:*omit);
       area.ry=0;
       area.rx=1;
       tree_deallocChilds(lArea:*null);
          for ry=0 to area.height-1;
            QsnWrtPad(' '
                     :area.width
                     :0:area.y+ry:area.x
                        :area.cmdBuf:0:0);
          endfor;
     p                 e
      // --------------------------------------------------------------------
      // refresh requested
      // --------------------------------------------------------------------
     pdsm_AreaToRefresh...
     p                 b                   export
     ddsm_AreaToRefresh...
     d                 pi
     d  lArea                          *   const
     d  toRefresh                      n   const options(*nopass)
      *
     d screen          ds                  likeDs(tScreen) based(pScreen)
     d area            ds                  likeDs(tArea  ) based(pArea  )
       pScreen=tree_getItem(tree_getParent(lArea));
       pArea=tree_getItem(lArea);
       if %parms()=%parmnum(toRefresh);
         area.toRefresh=toRefresh;
       else;
         area.toRefresh=*on;
       endIf;
       if area.toRefresh=*on;
         screen.toRefresh=*on;
       endIf;
     p                 e
      // --------------------------------------------------------------------
      // print text in area and go to new line
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
                  :atr1:x'27'
                  :area.cmdBuf
                  :0:*omit);
       endIf;
       // new position
       if area.rx+%len(text)+1>=area.width;
         area.rx=1;
         area.ry+=1;
       else;
         area.rx+=%len(text)+1;
       endIf;
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
     pdsm_DspScr       b
     d dsm_DspScr      pi
     d  lScreen                        *   const
     d lLastProcessed                  *
      *
     d  screen         ds                  likeDs(tScreen) based(pScreen)
     d  i              s              3u 0
     d  fldSeq         s              3u 0


       pScreen=tree_getItem(lScreen);
       for i=1 to screen.lastFldID;
         qsnSetFld(i
                  :0
                  :0:0
                  :QSN_FFW_ALPHA_SHIFT
                  :*omit
                  :0
                  :*omit
                  :QSN_SA_GRN_UL
                  :*omit
                  :*omit
                  :*omit);
       endFor;

       screen.lastFldID=0;

       if screen.toRefresh;
         dsm_DspScr2(lScreen);
       endIf;
       // position
       fldSeq=dsm_getFld2(lScreen:lLastProcessed);
       qsnInsCsr(fldSeq
                :0:0
                :screen.cmdBuf
                :*omit
                :*omit);
       // First message (can be empty)
       qsnWrtDta(msgBox.msgTxt(1)
                :120:0
                :27:2
                :x'00':x'00'
                :qsn_sa_wht:x'20'
                :screen.cmdBuf
                :0:*omit);
      // send buffer to screen
       qsnputbuf(screen.cmdBuf:0:*omit);
       lLastProcessed=*null;
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
     d A255            s            255a
     d onError         s               n
     d strColAtr       s              1a
      *
     d areaDefiner     pr                  extProc(area.pDefiner)
     d  lArea                          *   const
      *
     d cliGetter       pr           255a   extProc(screen.pGetter)
     d  lX                             *   const
     d  origin                        1a   const
     d  onError                        n
      *
     d  dftAtr         s              1a
     d  lFld           s               *
     d  fld            ds                  likeDs(tFld) based(pFld)
      *
       pScreen=tree_getItem(lScreen);
       qsnclrbuf(screen.cmdbuf:*omit);
       qsnClrScr('4':screen.cmdBuf:*omit:*omit);
       qsnclrbuf(screen.inpbuf:*omit);
       screen.toRefresh=*off;
       screen.lastFldId=0;
       // loop on each area
       lArea=tree_getFirst(lScreen);
       dow lArea<>*null;
         pArea=tree_getItem(lArea);
         // refresh requested
         if area.toRefresh
        and area.pDefiner<>*null;
           qsnclrbuf(area.cmdbuf:*omit);
           area.toRefresh=*off;
           dsm_clearArea(lArea);
           areaDefiner(lArea);
         endif;
        // loop on each field
        qsnclrbuf(area.cmdbuf2:*omit);
        lFld=tree_getFirst(lArea);
        dow lFld<>*null;

          pFld=tree_getItem(lFld);
          a255=cliGetter(fld.lItem
                        :fld.origin
                        :onError);
          if onError;
            dftAtr=QSN_SA_GRN_UL_RI;
          else;
            dftAtr=Fld.defAtr;
          endIf;

          qsnWrtDta(a255
                   :fld.length
                   :fld.id
                   :0:0
                   :*omit:*omit
                   :dftAtr:*omit
                   :area.cmdBuf2
                   :0:*omit);

           lFld=tree_getnext(lFld);
         enddo;
         // To clear the remain of area
         if area.y+area.height-1>area.y+area.ry;
           QsnWrtPadAdr(' '
                       :area.y+area.height-1:area.x+area.width-1
                       :area.y+area.ry      :area.x+area.rx
                       :area.cmdBuf:0:0);
         endIf;
         // merge buffers
         qsncpybuf(area.cmdBuf :screen.cmdBuf:*omit);
         qsncpybuf(area.cmdBuf2:screen.cmdBuf:*omit);

         lArea=tree_getNext(lArea);
       endDo;
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
       dsm_readMdt(lScreen:fldMdtCount);
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
         ///dsm_readMdt(screen:fldMdtCount);
       endIf;
       reset msgBox;
       return aid;
     p                 e
      // -----------------------------------------------------------------------
      // 
      // -----------------------------------------------------------------------
     pdsm_go           B                   export
     d dsm_go          pi
     d  pgmID                        10a            const
     d  lScreens                       *
     d  screenID                     10a   varying  const
     d csrY                          10i 0
     d csrX                          10i 0
     d lLastProcessed                  *
      *
     d screens         ds                  likeDs(tScreens) based(pScreens)
     d curScreen       ds                  likeDs(tScreen)  based(pCurScreen)
     d AID             s              1a
        pScreens=tree_getItem(lScreens);
        dsm_setCurScreen(lScreens:screenID);
        dsm_clrScr(screens.lCurScreen);
        dow screens.lCurScreen<>*null;
          // receive the messages
          dsm_RCVPM(pgmID);
          // display the screen
          dsm_dspScr(screens.lCurScreen:lLastProcessed);
          // get AID
          AID=dsm_getAID(screens.lCurScreen:csrX:csrY);
          // process the FK
          dsm_processFK(pgmID:screens.lCurScreen:AID);
        endDo;
     p                 e
      // --------------------------------------------------------------------
      // process function key
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
       dcl-s  lFKC   pointer;
       dcl-s  lFirst pointer;
       dcl-s  lLast  pointer;
     d fkAction        pr                  extproc(FK.pAction)
     d ko              c                   const(*on)
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
       and dsm_control(lScreen)=ko;
         return;
       endIf;
       // Change context/libel on FK
       if tree_getFirst(lFK)<>tree_getLast(lFK);
         lFKC=tree_getFirst(lFK);
         lFKC=tree_getNextInLoop(lFKC);
         tree_setFirst(lFKC);
       endIf;
       // no errors : perform the action bound to function key
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
     d ok              s               n   inz(*off)
       return ok;
     p                 e
      // --------------------------------------------------------------------
      // print field in area
      // --------------------------------------------------------------------
     pdsm_printFld     b                   export
     d dsm_printFld    pi
     d  lArea                          *   const
     d  length                        3u 0 const
     d  lItem                          *   const
     d  origin                        1a   const
     d  fldVal                      255a   const options(*nopass)
     d  fMDT                           n   const options(*nopass)
      *
     d  screen         ds                  likeDS(tScreen) based(pScreen)
     d  Area           ds                  likeDS(tArea) based(pArea)
     d  fld            ds                  likeDs(tFld)  based(pFld)
      *
     d  y              s              3u 0
     d  x              s              3u 0
      *
       pArea=tree_getItem(lArea);
       pScreen=tree_getItem(tree_getParent(lArea));
       y=area.y+area.ry;
       x=area.x+area.rx;
      *
       screen.lastFldID+=1;
      *
       qsnSetFld(screen.lastFldID
                :length
                :y:x
                :QSN_FFW_ALPHA_SHIFT
                :*omit
                :0
                :*omit
                :QSN_SA_GRN_UL
                :area.cmdBuf
                :*omit
                :*omit);

       pFld=tree_getNewItem(%addr(tFld):%size(tFld));

       fld.id=screen.lastFldID;
       fld.y=y;
       fld.x=x;
       fld.lItem =lItem;
       if %parms()>=%parmNum(fMDT);
         fld.fMdt  =fMdt;
       endIf;
       fld.length=length;
       fld.origin=origin;
       tree_linkToParent(lArea:tree_getNewLink(pFld));
       // new position
       if area.rx+length+1>=area.width;
         area.rx=1;
         area.ry+=1;
       else;
         area.rx+=length+1;
       endIf;

     p                 e
      // --------------------------------------------------------------------
      // read modified fields
      // --------------------------------------------------------------------
     pdsm_ReadMdt      b
     d dsm_ReadMdt     pi
     d lScreen                         *   const
     d fldMdtCount                   10i 0 const
      *
     d setter          pr                  extproc(screen.pSetter)
     d  lX                             *   const
     d  origin                        1a   const
     d  a255                        255a   const
      *
     d fldMdtIdx       s             10i 0
     d fldInf          ds                  likeDs(tFldInf)
     d a255            s            255a   inz('')
     d screen          ds                  likeDs(tScreen) based(pScreen)
     d lFld            s               *
     d fld             ds                  likeDs(tFld) based(pFld)
       pScreen=tree_getItem(lScreen);
       for FldMdtIdx=1 to FldMdtCount;
         QsnRtvFldInf(screen.inpBuf
                     :fldMdtIdx
                     :fldInf
                     :%len(fldInf)
                     :*omit:*omit);
         // Get the field in the coresponding map
         lFld=dsm_getFld(lScreen:fldinf.row:fldinf.col);
         pFld=tree_getItem(lFld);
         fld.fMDT=*on;
         a255='';
         memCpy(%addr(a255)
               :fldInf.pDta
               :fldInf.Dtalen);

         setter(fld.lItem
               :fld.origin
               :a255);
       endFor;
     p                 e
      // --------------------------------------------------------------------
      // set position
      // --------------------------------------------------------------------
     pdsm_setPos       b                   export
     d dsm_setPos      pi
     d  lArea                          *   const
     d  rY                            3u 0 const options(*omit)
     d  rX                            3u 0 const
      *
     d  area           ds                  likeDs(tArea) based(pArea)

       pArea=tree_getItem(lArea);

       if %addr(rY)<>*null;
         area.rY=rY;
       endif;

       area.rX=rX;

     p                 e
      // --------------------------------------------------------------------
      // get field in the arborescence (by position)
      // --------------------------------------------------------------------
     pdsm_getFld       b
     d dsm_getFld      pi              *
     d lScreen                         *   const
     d y                              3u 0 const
     d x                              3u 0 const
      *
     d lArea           s               *
     d lFld            s               *
     d fld             ds                  likeDs(tFld) based(pFld)
       lArea=tree_getFirst(lScreen);
       dow lArea<>*null;
         lFld=tree_getFirst(lArea);
         dow lFld<>*null;
           pFld=tree_getItem(lFld);
           if fld.y=y and fld.x=x;
             return lFld;
           endIf;
           lFld=tree_getNext(lFld);
         endDo;
         lArea=tree_getNext(lArea);
       endDo;
       return *null;
     p                 e
      // --------------------------------------------------------------------
      // get field in the arborescence (by referenced)
      // --------------------------------------------------------------------
     pdsm_getFld2      b
     d dsm_getFld2     pi             3u 0
     d lScreen                         *   const
     d lLastProcessed                  *   const
      *
     d lArea           s               *
     d lFld            s               *
     d fld             ds                  likeDs(tFld) based(pFld)
       lArea=tree_getFirst(lScreen);
       dow lArea<>*null;
         lFld=tree_getFirst(lArea);
         dow lFld<>*null;
           pFld=tree_getItem(lFld);
           if fld.lItem=lLastProcessed;
             return fld.id;
           endIf;
           lFld=tree_getNext(lFld);
         endDo;
         lArea=tree_getNext(lArea);
       endDo;
       return 1;
     p                 e
      // --------------------------------------------------------------------
      // get the nearest
      // --------------------------------------------------------------------
     pdsm_getNearest   b                   export
     d dsm_getNearest  pi              *
     d lScreen                         *   const
     d y                              3u 0 const
     d x                              3u 0 const
      *
     d lArea           s               *
     d lFld            s               *
     d fld             ds                  likeDs(tFld) based(pFld)
       lArea=tree_getLast(lScreen);
       dow lArea<>*null;
         lFld=tree_getLast(lArea);
         dow lFld<>*null;
           pFld=tree_getItem(lFld);
           if fld.y=y and fld.x<=x;
             return fld.lItem;
           elseif fld.y<y;
             return *null;
           endIf;
           lFld=tree_getPrev(lFld);
         endDo;
         lArea=tree_getPrev(lArea);
       endDo;
       return *null;
     p                 e
