     h nomain                     BndDir('U7')
      /copy cpy,u7env_h
      /copy cpy,u7fmt_h
      /copy cpy,u7form_h
      /copy cpy,u7ibm_h
      /copy cpy,u7int_h
      /copy cpy,u7msg_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,dsm6_h
      /copy cpy,QSNAPI_H
      // Box to store the messages
     d MsgBox          ds                  qualified
     d   msgSeq                       3u 0
     d   msgMax                       3u 0
     d   msgTxt                     130    dim(10)
      // --------------------------------------------------------------------
      // get shell
      // --------------------------------------------------------------------
     pdsm_getShell     b                   export
     d dsm_getShell    pi              *
     d  lShells                        *
     d  shellID                      10a   const varying
      //
     d  shell          ds                  likeDs(tShell) based(pShell)
     d  lShell         s               *   inz(*null)
       if lShells=*null;
         lShells=tree_getnewlink(*null);
       endif;
       lShell=tree_getLinkFromList(lShells:kShell:shellID);
       if lShell=*null;
         pShell=tree_getNewItem(%addr(tShell):%size(tShell));
         shell.ID=shellID;
         qsnCrtInpBuf(2000:200:0:shell.inpBuf:*omit);
         lShell=tree_getNewLink(pShell);
         tree_linkToParent(lShells:lShell);
       endIf;
       return lShell;
     p                 e
      // --------------------------------------------------------------------
      // get layout
      // --------------------------------------------------------------------
     pdsm_getLayout    b                   export
     d dsm_getLayout   pi              *
     d  lShell                         *   const
     d  layoutID                     10a   const varying
     d  y                             3u 0 const
     d  x                             3u 0 const
     d  height                        3u 0 const
     d  width                         3u 0 const
      *
     d layout          ds                  likeDs(tLayout) based(pLayout)
     d lLayout         s               *
       lLayout=tree_getLinkFromList(lShell:kLayout:layoutID);
       if lLayout=*null;
         pLayout=tree_getNewItem(%addr(tLayout):%size(tLayout));
       else;
         pLayout=tree_getItem(lLayout);
       endIf;
       layout.ID=layoutID;
       layout.y=y;
       layout.x=x;
       layout.height=height;
       layout.width=width;
       qsnCrtCmdBuf(2000:200:0:layout.cmdBuf:*omit);
       layout.rY=0;
       layout.rX=1;
       lLayout=tree_getNewLink(pLayout);
       tree_linkToParent(lShell:lLayout);
       return lLayout;
     p                 e
      // --------------------------------------------------------------------
      // get layout by ID
      // --------------------------------------------------------------------
     pdsm_getLayoutByID...
     p                 b                   export
     d dsm_getLayoutByID...
     d                 pi              *
     d  lShell                         *                                   const
     d  layoutID                     10a   varying                         const
      *
     d lLayout         s               *
       lLayout =tree_getLinkFromList(lShell
                                    :kLayout
                                    :layoutID);
       return lLayout;
     p                 e
      // --------------------------------------------------------------------
      // clear layout
      // --------------------------------------------------------------------
     pdsm_clearLayout...
     p                 b                   export
     ddsm_ClearLayout...
     d                 pi
     d  lLayout                        *                                   const
      *
     d ry              s              3u 0
     d layout          ds                  likeDs(tLayout) based(pLayout)
       pLayout=tree_getItem(lLayout);
       for ry=0 to layout.height-1;
         QsnWrtPadAdr(' '
                     :layout.y+ry:layout.x+layout.width-1
                     :layout.y+rY:layout.x
                     :layout.cmdBuf:0:0);
       endfor;
       layout.rY=0;
       layout.toRefresh=*on;
     p                 e
      // --------------------------------------------------------------------
      // init shell
      // --------------------------------------------------------------------
     pdsm_initShell...
     p                 b                   export
     ddsm_initShell...
     d                 pi
     d  lShell                         *                                   const
     d shell           ds                  likeDs(tShell)  based(pShell)
       pShell=tree_getItem(lShell);
       shell.fldSeq=0;
     p                 e
      // --------------------------------------------------------------------
      // init layout
      // --------------------------------------------------------------------
     pdsm_initLayout...
     p                 b                   export
     ddsm_initLayout...
     d                 pi
     d  lLayout                        *                                   const
      *
     d layout          ds                  likeDs(tLayout) based(pLayout)
       pLayout=tree_getItem(lLayout);
       QsnClrBuf(layout.cmdBuf:*omit);
       layout.rY=0;
       layout.rX=1;
       dsm_ClrFldTbl(lLayout);
     p                 e
      // --------------------------------------------------------------------
      // print text in layout
      // --------------------------------------------------------------------
     pdsm_printLN      b                   export
     d dsm_printLN     pi
     d  lLayout                        *                                   const
     d  atr1                          1a           const
     d  text                       1000a   varying const
     d  y                             3u 0 options(*nopass)
      *
     d phrase          s           1000a   varying
     d layout          ds                  likeDs(tLayout) based(pLayout)
       pLayout=tree_getItem(lLayout);
       phrase=text;
       ///if %len(phrase)>1 and %subst(phrase:1:1)=' ';
       ///  phrase = %subst(phrase:2);
       ///endIf;
       qsnWrtDta(phrase
                :%len(phrase)
                :0
                :layout.y+layout.rY
                :layout.x+layout.rX
                :x'00':x'00'
                :atr1:x'00'
                :layout.cmdbuf
                :0:*omit);
       // if requested give the position of the printed row
       if %parms>=%parmnum(y);
         y=layout.y+layout.rY;
       endIf;
       // Ending position
       layout.ry+=%int((layout.rx+%len(phrase)-1)/layout.width);
       layout.rx =%rem((layout.rx+%len(phrase)-1):layout.width)+2;
       // To clear the remain of the line
       if layout.rx<layout.width;
         QsnWrtPad(' ':layout.width-layout.rx+1
                  :*omit
                  :layout.y+layout.rY
                  :layout.rx
                  :layout.cmdbuf
                  :0:*omit);
       endif;
       // Next line
       layout.ry+=1;
       layout.rx=1;
       layout.toRefresh=*on;
     p                 e
      // --------------------------------------------------------------------
      // print text in layout
      // --------------------------------------------------------------------
     pdsm_print        b                   export
     d dsm_print       pi
     d  lLayout                        *                                   const
     d  atr1                          1a                                   const
     d  text                        100a   varying                         const
      *
     d layout          ds                  likeDs(tLayout) based(pLayout)
       pLayout=tree_getItem(lLayout);
       qsnWrtDta(text
                :%len(text)
                :0
                :layout.y+layout.rY
                :layout.x+layout.rX
                :x'00':x'00'
                :atr1:x'20'
                :layout.cmdbuf
                :0:*omit);
       // New position
       layout.ry+=(layout.rx+%len(text))/132;
       layout.rx=%rem(layout.rx+%len(text):132)+1;
       layout.toRefresh=*on;
     p                 e
      // --------------------------------------------------------------------
      // print field in layout
      // --------------------------------------------------------------------
     pdsm_printFld     b                   export
     d dsm_printFld    pi
     d  lLayout                        *                                   const
     d  atr1                          1a                                   const
     d  fldAtr                        2a                                   const
     d  value                       100a   varying                         const
     d  pItem                          *                                   const
      *
     d lShell          s               *
     d Shell           ds                  likeDs(tShell) based(pShell)
     d layout          ds                  likeDs(tLayout) based(pLayout)
       lShell =tree_getParent(lLayout);
       pShell =tree_getItem(lShell);
       pLayout=tree_getItem(lLayout);
          shell.fldSeq+=1;
          qsnSetFld(shell.fldSeq
                   :%len(value)
                   :layout.y+layout.rY
                   :layout.x+layout.rX
                   :fldAtr
                   :' '
                   :0
                   :atr1
                   :atr1
                   :layout.cmdBuf
                   :*omit
                   :*omit);
       qsnWrtDta(value
                :%len(value)
                :shell.fldSeq
                :0
                :0
                :x'00':x'00'
                :atr1:x'20'
                :layout.cmdbuf
                :0:*omit);
       shell.fldRep(shell.fldSeq).Y=layout.y+layout.rY;
       shell.fldRep(shell.fldSeq).x=layout.x+layout.rx;
       shell.fldRep(shell.fldSeq).pItem=pItem;
       // New position
       layout.ry+=(layout.rx+%len(value))/132;
       layout.rx=%rem(layout.rx+%len(value):132)+1;
       layout.toRefresh=*on;
     p                 e
      // --------------------------------------------------------------------
      // print panel in layout
      // --------------------------------------------------------------------
     pdsm_printPanelLN...
     p                 b                   export
     d dsm_printPanelLN...
     d                 pi
     d lLayout                         *                                   const
     d lPanel                          *                                   const
      //
     d panel           ds                  likeDs(tPanel) based(pPanel)
     d blank           s            100a   inz('')
     d phrase          s           1000a   varying
     d layout          ds                  likeDs(tLayout) based(pLayout)
       pLayout=tree_getItem(lLayout);
       pPanel=tree_getItem(lPanel);
       phrase=panel.text;
       qsnWrtDta(phrase
                :%len(phrase)
                :0
                :layout.y+layout.rY
                :layout.x+layout.rX
                :x'00':x'00'
                :qsn_sa_grn:x'20'
                :layout.cmdbuf
                :0:*omit);
       // To clear the remain of the line
       layout.ry+=%int((%len(phrase)-1)/layout.width);
       layout.rx=%rem((%len(phrase)-1):layout.width)+3;
       if layout.rx<layout.width;
         QsnWrtPad(' ':layout.width-layout.rx
                  :*omit
                  :layout.y+layout.rY
                  :layout.rx+1
                  :layout.cmdbuf
                  :0:*omit);
       endif;
       layout.ry+=1;
       layout.rx=1;
       layout.toRefresh=*on;
     p                 e
      // --------------------------------------------------------------------
      // print label in layout
      // --------------------------------------------------------------------
     pdsm_printLabelLN...
     p                 b                   export
     d dsm_printLabelLN...
     d                 pi
     d lLayout                         *                                   const
     d lLabel                          *                                   const
     d  dspFormula_                    n   options(*nopass)                const
     d  editable_                      n   options(*nopass)                const
      *
     d blank           s            100a   inz('')
      *
     d level           s              3u 0
     d w060a           s             60a
     d dspFormula      s               n   inz(*off)
     d editable        s               n   inz(*off)
     d phrase          s           2000a
     d rem             s              3u 0
     d atr1            s              1a
     d field           ds                  likeDs(tField) based(pField)
     d lShell          s               *
     d shell           ds                  likeDs(tShell)  based(pShell)
     d layout          ds                  likeDs(tLayout) based(pLayout)
     d label           ds                  likeDs(tLabel)  based(pLAbel)
     d w1              s              1a
       lShell=tree_getParent(lLayout);
       pShell=tree_getItem(lShell);
       pLayout=tree_getItem(lLayout);
       pLabel=tree_getItem(lLabel);
       if %parms()>=%parmnum(dspFormula_);
        dspFormula=dspFormula_;
       endIf;
       if %parms()>=%parmnum(editable_);
        editable=editable_;
       endIf;
       level=2;
       w060a=int_AddSpaceDot(%subst(blank:1:(level-1)*2)
                            +Label.text
                            +' '
                            :52);
       if dspFormula=*on;
         %subst(w060a:60-%len(label.formula))
         =x'22'+label.formula+x'20';
       endIf;
       // 1) Write the part for the text
       qsnWrtDta(w060a
                :60
                :0
                :layout.y+layout.rY
                :layout.x+layout.rX
                :x'00':x'00'
                :qsn_sa_grn:x'20'
                :layout.cmdbuf
                :0:*omit);
       // Interpret formula
       phrase=int_FormulaExec(label.lFormula);
       // 2) Write the part of the values
       if not editable;
         atr1=qsn_sa_grn;
       elseif label.mandatory;
         atr1=qsn_sa_wht_ul;
         w1=qsn_ffw_mdt;
       else;
         atr1=qsn_sa_grn_ul;
         w1=QSN_FFW_ALPHA_SHIFT;
       endif;
       qsnWrtDta(phrase
                :label.maxWidth
                :0
                :layout.y+layout.rY
                :63
                :x'00':x'00'
                :atr1:x'20'
                :layout.cmdbuf
                :0:*omit);
       // Only simple alpha formula is editable
       if  tree_isOfTheKind(kField:label.lFormula:pField)
       and editable
       and field.type='A';
          shell.fldSeq+=1;
          qsnSetFld(shell.fldSeq
                   :label.maxWidth
                   :layout.y+layout.rY
                   :63
                   :w1
                   :*omit
                   :*omit
                   :atr1
                   :atr1
                   :layout.cmdBuf
                   :*omit
                   :*omit);
          shell.fldRep(shell.fldSeq).Y=layout.y+layout.rY;
          shell.fldRep(shell.fldSeq).x=63;
          shell.fldRep(shell.fldSeq).pItem=pLabel;
       endIf;
       // To clear the remain of the line
       layout.ry+=%int((63+label.maxWidth-1-1)/132);
       layout.rx =%rem( 63+label.maxWidth-1-1 :132)+1;
       if layout.rx<131;
         rem=132-layout.rx-1;
         QsnWrtPad(' '
                  :rem
                  :*omit
                  :layout.y+layout.rY
                  :layout.rx+2
                  :layout.cmdbuf
                  :0:*omit);
       endif;
       layout.ry+=1;
       layout.rx=1;
       layout.toRefresh=*on;
     p                 e
      // --------------------------------------------------------------------
      // can print
      // --------------------------------------------------------------------
     pdsm_CanPrint     b                   export
     d dsm_CanPrint    pi              n
     d  lLayout                        *                                   const
     d layout          ds                  likeDs(tLayout) based(pLayout)
       pLayout=tree_getItem(lLayout);
       return layout.ry<layout.height;
     p                 e
      // --------------------------------------------------------------------
      // clear the remain from position in a layout
      // --------------------------------------------------------------------
     pdsm_padLayout    b                   export
     ddsm_padLayout    pi
     d lLayout                         *                                   const
      *
     d layout          ds                  likeDs(tLayout) based(pLayout)
       pLayout=tree_getItem(lLayout);
       if layout.ry<layout.height;
         QsnWrtPadAdr(' '
                     :layout.y+layout.height-1
                     :layout.x+layout.width-1
                     :layout.y+layout.rY
                     :layout.x+layout.rx-1
                     :layout.cmdBuf:0:0);
       endif;
     p                 e
      // --------------------------------------------------------------------
      // Display the screen
      // --------------------------------------------------------------------
     pdsm_DspScr       b                   export
     ddsm_DspScr       pi
     d  lShell                         *                                   const
     d  forceRefresh_                  n   options(*nopass)                const
      *
     d  lLayout        s               *
     d  Layout         ds                  likeDs(tLayout) based(pLayout)
     d  forceRefresh   s               n   inz(*off)
       if %parms()=%parmNum(forceRefresh_);
         forceRefresh=forceRefresh_;
       endIf;
       lLayout=tree_getFirst(lShell);
       dow lLayout<>*null;
         pLayout=tree_getItem(lLayout);
         if layout.toRefresh
         or forceRefresh;
           layout.toRefresh=*off;
           qsnputBuf(layout.cmdBuf:0:*omit);
         endIf;
         lLayout=tree_getNext(lLayout);
       endDo;
       // First message (can be empty)
       qsnWrtDta(msgBox.msgTxt(1)
                :130
                :0
                :27
                :2
                :x'00':x'00'
                :qsn_sa_wht:x'20'
                :*omit
                :0:*omit);
     p                 e
      // --------------------------------------------------------------------
      // clear and intialize the screen
      // --------------------------------------------------------------------
     pdsm_ClrScr       b                   export
     ddsm_ClrScr       pi
       qsnClrScr('4':*omit:*omit:*omit);
     p                 e
      // --------------------------------------------------------------------
      // clear fields of a layout
      // --------------------------------------------------------------------
     pdsm_ClrFldTbl    b                   export
     ddsm_ClrFldTbl    pi
     d llayout                         *                                   const
      *
     d layout          ds                  likeDs(tLayout) based(pLayout)
       pLayout=tree_getItem(lLayout);
       qsnclrfldtbl(layout.cmdBuf:*omit:*omit);
     p                 e
      // --------------------------------------------------------------------
      // read modified fields
      // --------------------------------------------------------------------
     pdsm_ReadMdt      b                   export
     d dsm_ReadMdt     pi
     d  lShell                         *                                   const
     d  lLayout                        *                                   const
     d  pClientRead                    *   procPtr                         const
      *
     d shell           ds                  likeDs(tShell)  based(pShell)
     d layout          ds                  likeDs(tLayout) based(pLayout)
     d fldMdtCount     s             10i 0
       pShell=tree_getItem(lShell);
       pLayout=tree_getItem(lLayout);
       QsnReadMDT(x'00':x'00'
                 :FldMdtCount
                 :shell.inpBuf
                 :layout.cmdBuf
                 :*omit:*omit);
       dsm_readMdt2(shell:layout:fldMdtCount:pClientRead);
     p                 e
      // --------------------------------------------------------------------
      // read modified fields (part 2)
      // --------------------------------------------------------------------
     pdsm_ReadMdt2     b
     d dsm_ReadMdt2    pi
     d shell                               likeDs(tShell)
     d layout                              likeDs(tLayout)
     d fldMdtCount                   10i 0
     d  pClientRead                    *   procPtr                         const
      *
     d clientRead      pr                  extproc(pClientRead)
     d  pX                             *                                   const
     d  w1000                      1000a                                   const
      *
     d fldMdtIdx       s             10i 0
     d fldInf          ds                  likeDs(tFldInf)
     d i               s             10i 0
     d w1000           s           1000a
       QsnClrBuf(layout.cmdBuf:*omit);
       for FldMdtIdx=1 to FldMdtCount;
         QsnRtvFldInf(shell.inpBuf
                     :FldMdtIdx
                     :fldInf
                     :%len(fldInf)
                     :*omit:*omit);
         i=%lookup(fldInf.rowcol:shell.FldRep(*).yx);
         shell.fldRep(i).fMDT=*on;
         w1000='';
         memCpy(%addr(w1000)
               :FldInf.pDta
               :fldInf.Dtalen);
         clientRead(shell.fldRep(i).pItem
                   :w1000);
       endFor;
     p                 e
      // --------------------------------------------------------------------
      // get AID
      // --------------------------------------------------------------------
     pdsm_getAID       b                   export
     d dsm_getAID      pi             1a
     d  lShell                         *                                   const
     d  lLayout                        *                                   const
     d  csrx                         10i 0
     d  csry                         10i 0
     d  pClientRead                    *   procPtr                         const
      *
     d shell           ds                  likeDs(tShell)  based(pShell)
     d layout          ds                  likeDS(tLayout) based(pLayout)
     d fldMdtCount     s             10i 0
     d AID             s              1a
     d msgTxt          s            130a
       pShell=tree_getItem(lShell);
       pLayout=tree_getItem(lLayout);
       QsnRtvReadAID(shell.inpBuf:aid:*omit:*omit);
       QsnRtvReadAdr(shell.inpBuf:csrY:csrX:*omit:*omit);
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
                         :shell.inpBuf
                         :layout.cmdBuf
                         :*omit:*omit);
         dsm_readMdt2(shell:layout:fldMdtCount:pClientRead);
       endIf;
       return aid;
     p                 e
      // --------------------------------------------------------------------
      // try to print label in layout
      // --------------------------------------------------------------------
     pdsm_rollup       b                   export
     d dsm_rollup      pi              *
     d  lLayout                        *                                   const
     d  lRoot                          *                                   const
     d  lRow1Old                       *                                   const
      *
     d lRow            s               *
     d lRow1           s               *
     d layout          ds                  likeDs(tLayout) based(pLayout)
     d label           ds                  likeDs(tLabel)  based(pLabel)
     d rowTaken        s              3u 0 inz(0)
     d rowNeeded       s              3u 0
       pLayout=tree_getItem(lLayout);
       lRow=tree_getPrevToDisplay(lRoot:lRow1Old);
       dow lRow<>*null;
         if tree_isOftheKind(kPanel:lRow);
           rowNeeded=1;
         elseIf tree_isOftheKind(kLabel:lRow:pLabel);
           rowNeeded=1+(63+label.maxWidth-1-1)/132;
         endIf;
         if rowTaken+rowNeeded+tree_getLevel(lRow)-1>layout.height;
           leave;
         endIf;
         lRow1=lRow;
         rowTaken+=rowNeeded;
         lRow=tree_getPrevToDisplay(lRoot:lRow);
       endDo;
       return lRow1;
     p                 e
      // --------------------------------------------------------------------
      // get row at position
      // --------------------------------------------------------------------
     pdsm_getRowAt     b                   export
     d dsm_getRowAt    pi              *
     d  lList                          *                                   const
     d  lRoot                          *                                   const
     d  lRow1                          *                                   const
     d  lRow9                          *                                   const
     d  csrY                         10i 0                                 const
      *
     d list            ds                  likeDs(tLayout) based(pList)
     d csrYR$          s             10i 0
     d csrYR           s             10i 0 inz(0)
     d curY            s             10i 0
     d lWinner         s               *
     d lRow            s               *
     d rowNeeded       s              3u 0
     d label           ds                  likeDs(tLabel)  based(pLabel)
       pList=tree_getItem(lList);
       // out of list area
       if csrY<list.y
       or csrY>=list.y+list.height;
         return *null;
       endIf;
       // relative row requested
       csrYR$=csrY-list.y+1;
       // explore parent
       dsm_getRowAt2(csrYR$:lRoot:lRow1:csrYR:lWinner);
       if lWinner<>*null;
         return lWinner;
       endIf;
       // explore sibling
       lRow=lRow1;
       dow lRow<>*null;
         if tree_isOftheKind(kPanel:lRow);
           rowNeeded=1;
         elseIf tree_isOftheKind(kLabel:lRow:pLabel);
           rowNeeded=1+(63+label.maxWidth-1-1)/132;
         endIf;
         if  csrYR$>=csrYR+1
         and csrYR$<=csrYR+rowNeeded;
           return lRow;
         endIf;
         if lRow=lRow9;
           leave;
         endIf;
         csrYR+=rowNeeded;
         lRow=tree_getNextToDisplay(lRoot:lRow);
       endDo;
       return *null;
     p                 E
      // -----------------------------------------------------------------------
      // get row at position (part 2)
      // -----------------------------------------------------------------------
     pdsm_getRowAt2    b
     d dsm_getRowAt2   pi
     d  csrYR$                       10i 0                                 const
     d  lRoot                          *                                   const
     d  lX                             *                                   const
     d  csrYR                        10i 0
     d  lWinner                        *
      *
     d lX2             s               *
     d panel           ds                  likeDs(tPanel)  based(pPanel)
       lX2=tree_getParentToDisplay(lRoot:lX);
       if lX2<>*null;
         dsm_getRowAt2(csrYR$:lRoot:lX2:csrYR:lWinner);
         csrYR+=1;
         if csrYR=csrYR$;
           lWinner=lX2;
         endIf;
       endIf;
     p                 e
      // -----------------------------------------------------------------------
      // control
      // -----------------------------------------------------------------------
     pdsm_control      b                   export
     d dsm_control     pi              n
     d  lShell                         *                                   const
     d  pClientCheck                   *   procPtr                         const
      *
     d label           ds                  likeDs(tLAbel)
     d fldSeq          s              3u 0
     d fldSeqPC        s              3u 0 inz(0)
     d fError          s               n   inz(*off)
     d shell           ds                  likeDs(tShell) based(pShell)
     d ffw             s              2a
     d atr1            s              1a
     d ko              c                   const(*on)
     d clientCheck     pr              n   extproc(pClientCheck)
     d   pItem                         *
     d   value                     1000a   varying
      *
     d   value         s           1000a   varying
       pShell=tree_getItem(lShell);
       for fldSeq=1 to shell.fldSeq;
         if not shell.fldRep(fldSeq).fMDT;
           iter;
         endif;
         shell.fldRep(fldSeq).fMDT=*off;
         if clientCheck(shell.fldRep(fldSeq).pItem:value)=ko;
           fError=*on;
           atr1=QSN_SA_GRN_UL_RI;
           ffw=qsn_ffw_mdt;
           if fldSeqPC=0;
             fldSeqPC=fldSeq;
           endIf;
         else;
           atr1=QSN_SA_GRN_UL;
           ffw=QSN_FFW_ALPHA_SHIFT;
         endif;
         qsnSetFld(fldSeq
                  :0
                  :0
                  :0
                  :ffw
                  :*omit
                  :*omit
                  :atr1
                  :*omit
                  :*omit
                  :*omit
                  :*omit);

       qsnWrtDta(value
                :%len(value)
                :fldSeq
                :0
                :0
                :x'00':x'00'
                :atr1:*omit
                :*omit
                :0:*omit);

       endfor;
       if fldSeqPC<>0;
         QsnInsCsr(fldSeqPC
                  :0
                  :0
                  :*omit
                  :*omit
                  :*omit);
       endIf;
       return fError;
     p                 e
      // -----------------------------------------------------------------------
      // Position on field
      // -----------------------------------------------------------------------
     pdsm_PosOnField   b                   export
     ddsm_PosOnField   pi
     d lShell                          *                                   const
     d lLayout                         *                                   const
     d pItem                           *
      *
     d shell           ds                  likeDs(tShell)  based(pShell)
     d layout          ds                  likeDs(tLayout) based(pLayout)
     d i               s              3u 0
       if pItem=*null;
         return;
       endif;
       pShell=tree_getItem(lShell);
       pLayout=tree_getItem(lLayout);
       i=%lookup(pItem:shell.FldRep(*).pItem);
       if i>0;
         QsnInsCsr(i
                  :0
                  :0
                  :layout.cmdBuf
                  :*omit
                  :*omit);
       endIf;
       pItem=*null;
     p                 e
      // -----------------------------------------------------------------------
      // Receive program message
      // -----------------------------------------------------------------------
     p msg_RcvPM       b                   export
     d                 pi
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
     d level           s              3u 0 inz(0)
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
      // -----------------------------------------------------------------------
      // item is of the kind
      // -----------------------------------------------------------------------
     ptree_ItemIsOfTheKind...
     p                 b                   export
     d tree_ItemIsOfTheKind...
     d                 pi              n
     d  kind                          1a   const
     d  pItem_                         *   const
     d  pItem$                         *   options(*nopass)
      //
     d item            ds                  qualified based(pItem)
     d   kind                         1a
       if pItem_=*null;
         return *off;
       endIf;
       pItem=pItem_;
       if Item.kind<>kind;
         return *off;
       endIf;
       if %parms()=3;
         pItem$=pItem_;
       endif;
       return *on;
     p                 e
