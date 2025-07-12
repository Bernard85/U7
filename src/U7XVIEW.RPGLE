       ctl-opt option(*noshowcpy) nomain;
      /copy cpy,u7env_h
      /copy cpy,u7fmt_h
      /copy cpy,u7grid_h
      /copy cpy,u7int_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,u7xview_h
      // --------------------------------------------------------------------
      // get View
      // --------------------------------------------------------------------
       dcl-proc  xview_getXView export;
       dcl-pi xview_getXView pointer;
         lXViews pointer;
         lGrids  pointer;
         lFmts   pointer;
         fmtID   varchar(10) const;
         fAppli_ char(1)     const options(*nopass);
       end-pi;

       dcl-s lXView pointer inz(*null);
       dcl-s pXView pointer inz(*null);
       dcl-s fAppli char(1) inz('N');
       // appli means it is a object for the appli
       if %parms()=%parmnum(fAppli_);
         fAppli=fAppli_;
       endIf;
       // create the XView anchor if it doesn't exist
       if lXViews=*null;
         lXViews=tree_getnewlink(*null);
       endif;
       lXView=tree_getLinkFromList(lXViews:kXView:fmtID);
       if lXView=*null;
         // load new view
         pXView=xview_loadXView(lGrids:lFmts:fmtID:fAppli);
         // link to the main tree view
         lXView=tree_getNewLink(pXView);
         tree_linktoparent(lXViews:lXView);
       endIf;
       return lXView;
       end-proc;
      // --------------------------------------------------------------------
      // load view
      // --------------------------------------------------------------------
       dcl-proc  xview_loadXView;
       dcl-pi xview_loadXView pointer;
         lGrids pointer;
         lFmts  pointer;
         FmtID  varchar(10) const;
         fAppli char(1)     const;
       end-pi;

       dcl-ds XView likeds(tXView) based(pXView);
       dcl-s lFmt pointer inz(*null);
       dcl-ds Fmt likeDS(tFormat) based(pFmt);
       dcl-s lGrid   pointer inz(*null);
       dcl-s lColumn pointer inz(*null);
       dcl-ds column likeDs(tColumn) based(pColumn);
       // create the grids anchor if it doesn't exist
       if lGrids=*null;
         lGrids=tree_getnewlink(*null);
       endif;
       // create the formats anchor if it doesn't exist
       if lFmts=*null;
         lFmts=tree_getnewlink(*null);
       endif;
       // Load corresponding format
       lFmt=fmt_getFormat(lFmts:fmtID:fAppli);
       if lFmt=*null;
         return *null;
       endIf;
       // Load corresponding grid
       lGrid=grid_getGrid(lGrids:fmtID:fAppli);
       if lGrid=*null;
         return *null;
       endIf;
       // Reserve memory for the format
       pFmt=tree_getItem(lFmt);
       fmt.pBuffer1=%alloc(fmt.len);
       fmt.pBuffer0=%alloc(fmt.len);
       // create the new item xView
       pXView=tree_getNewItem(%addr(tXView):%size(tXView));
       XView.ID=fmtID;
       XView.lFmt =lFmt;
       XView.lGrid=lGrid;
       // Load formulas
       lColumn=tree_getFirst(XView.lGrid);
       dow lColumn<>*null;
         pColumn=tree_getItem(lColumn);
         if column.seq=0;
           leave;
         endIf;
         column.lFormula=int_FormulaLoad(column.formula:xView.lFmt);
         lColumn=tree_getNext(lColumn);
       endDo;
       return pXView;
       end-proc;
      // --------------------------------------------------------------------
      // position to the most left position
      // --------------------------------------------------------------------
       dcl-proc xview_PosToMostLeft export;
       dcl-pi xview_PosToMostLeft;
         XView       likeDs(tXView);
         width uns(3) const;
       end-pi;
       xview_PosAtLeft(XView:width:tree_getFirst(XView.lGrid):1);
       end-proc;
      // --------------------------------------------------------------------
      // position to the left
      // --------------------------------------------------------------------
       dcl-proc  xview_PosAtLeft export;
       dcl-pi xview_PosAtLeft;
         XView          likeDs(tXView);
         width   uns(3)  value;
         lColumn pointer const;
         pos     uns(3)  value;
       end-pi;

       dcl-ds Column likeDs(tColumn) based(pColumn);
       // Reposition --> clear the headers
       xView.hdrs='';
       xView.left.lColumn=lColumn;
       pColumn=tree_getItem(lColumn);
       xView.leftColId=Column.ID;
       if column.maxWidth<=30;
         xView.left.pos=1;
       else;
         xView.left.pos=int_getMin(column.maxWidth-30+1:pos);
       endif;
       xView.left.most=pos=1 and xView.left.lColumn=tree_getFirst(XView.lGrid);
       // xxxxxxxx
       XView.left.width=int_getMin(column.maxWidth-XView.left.pos+1:width-1);
       xview_setRightColumn(XView:width);
       end-proc;
      // --------------------------------------------------------------------
      // tabulation at right
      // --------------------------------------------------------------------
       dcl-proc  xview_TabRight export;
       dcl-pi xview_TabRight;
         XView       likeDs(tXView);
         width uns(3) const;
       end-pi;

       dcl-ds column likeDs(tColumn) based(pColumn);
       // Already at the right
       if XView.right.most;
         return;
       endIf;
       // new position --> clear the headers
       XView.hdrs='';
       // no more on the left position
       XView.left.most=*off;
       // To know the right most column
       pColumn=tree_getItem(XView.right.lColumn);

       if XView.right.pos+XView.right.width-1=column.maxWidth;
         XView.left.lColumn=tree_getNext(XView.right.lColumn);
         XView.left.pos=1;
       else;
         XView.left.lColumn=XView.right.lColumn;
         XView.left.pos=int_getMin(column.maxWidth-30+1
                                  :XView.right.pos+XView.right.width);
       endIf;
       pColumn=tree_getItem(XView.left.lColumn);
       xView.leftColId=Column.ID;
       XView.left.width=int_getMin(column.maxWidth-XView.left.pos+1:width-1);
       // to determine the most right column
       xview_setRightColumn(XView:width);
       end-proc;
      // --------------------------------------------------------------------
      // set right most column
      // --------------------------------------------------------------------
       dcl-proc xview_setRightColumn;
       dcl-pi xview_setRightColumn;
         XView       likeDs(tXView);
         width uns(3) value;
       end-pi;

       dcl-s lColumn pointer;
       dcl-ds column likeDs(tColumn) based(pColumn);
       dcl-s width_ uns(3);
       width_=width;
       // the right leg is initialized with the current leg
       XView.right=XView.left;
       XView.right.most=*off;
       width-=1+XView.left.width;
       // quit if
       pColumn=tree_getItem(XView.left.lColumn);
       if XView.left.pos+XView.left.width-1<column.maxwidth;
         return;
       endif;
       // new position then clear headers
       xview.hdrs='';
       // loop on middle columns to get the right most column
       lColumn=tree_getNext(XView.left.lColumn);
       dow lColumn<>*null;
         pColumn=tree_getItem(lColumn);
         if column.seq=0;
           return;
         elseif 1+column.maxwidth<=width;
           width-=1+column.maxwidth;
           XView.right.lColumn=lColumn;
           XView.right.pos=1;
           XView.right.width=column.maxWidth;
         elseif column.maxWidth>30 and width>30;
           XView.right.lColumn=lColumn;
           XView.right.pos=1;
           XView.right.width=width-1;
           return;
         else;
           return;
         endIf;
         lColumn=tree_getNext(lColumn);
       endDo;
       XView.right.most=*on;
       // Resync on the right
       ///if not XView.left.most;
       ///  xview_setLeftColumn(XView:width_);
       ///endif;
       end-proc;
      // --------------------------------------------------------------------
      // tabulation at left
      // --------------------------------------------------------------------
       dcl-proc  xview_TabLeft export;
       dcl-pi xview_TabLeft;
         XView       likeDs(tXView);
         width uns(3) const;
       end-pi;

       dcl-ds column likeDs(tColumn) based(pColumn);
       // Already at the left : nothing to do
       if XView.left.most;
         return;
       endIf;
       // Reposition --> clear the headers
       XView.hdrs='';
       // no more on the left most position
       XView.right.most=*off;
       // To recognize the rightmost column
       if XView.left.pos=1;
         XView.right.lColumn=tree_getPrev(XView.left.lColumn);
         pColumn=tree_getItem(XView.right.lColumn);
         XView.right.width=int_getMin(column.maxWidth:width-1);
         XView.right.pos=column.maxWidth-XView.right.width+1;
       elseIf XView.left.pos<30;
         XView.right=XView.left;
         XView.right.pos=1;
         XView.right.width=30;
       else;
         XView.right=XView.left;
         pColumn=tree_getItem(XView.right.lColumn);
         XView.right.width=int_getMin(XView.right.pos-1
                                     :width-1);
         XView.right.pos-=XView.right.width;
       endif;
       xview_setLeftColumn(XView:width);
       end-proc;
      // --------------------------------------------------------------------
      // set left most column
      // --------------------------------------------------------------------
       dcl-proc xview_setLeftColumn;
       dcl-pi xview_setLeftColumn;
         XView       likeDs(tXView);
         width uns(3) value;
       end-pi;

       dcl-s lColumn pointer;
       dcl-ds column likeDs(tColumn) based(pColumn);
       dcl-s width_ uns(3);
       width_=width;
       // the right leg is inialized with the left leg
       xView.left=xView.right;
       xView.left.most=*off;
       // quit if
       if XView.right.pos>1;
         return;
       endif;
       // loop on middle columns to get mostleft column
       width-=xView.right.width+1;
       lColumn=tree_getprev(XView.right.lColumn);
       dow lColumn<>*null;
         pColumn=tree_getItem(lColumn);
         xView.leftColId=Column.ID;
         if column.maxwidth+1<=width;
           xView.left.lColumn=lColumn;
           xView.left.width=column.maxWidth;
           xView.left.pos=1;
           width-=1+xView.left.width;
         elseif column.maxWidth>30 and width>30;
           xView.left.lColumn=lColumn;
           xView.left.width=width-1;
           xView.left.pos=column.maxWidth-xView.left.width+1;
           return;
         else;
           xView.leftColId=Column.ID;
           return;
         endIf;
         lColumn=tree_getPrev(lColumn);
       endDo;
       xView.left.most=*on;
       if not XView.right.most;
         xview_setRightColumn(XView:width_);
       endif;
       end-proc;
      // --------------------------------------------------------------------
      // set headers
      // --------------------------------------------------------------------
       dcl-proc  xview_setHdrs export;
       dcl-pi xview_setHdrs varchar(131);
         xView       likeds(tXView);
         pos   uns(5) value;
       end-pi;

       dcl-s lColumn pointer;
       dcl-ds Column likeDs(tColumn) based(pColumn);
       // headers filled means no tabulation has happened
       if XView.hdrs<>'';
         return XView.hdrs;
       endif;
       // leftmost column
       lColumn=XView.left.lcolumn;
       pColumn=tree_getItem(lColumn);
       XView.hdrs+=XView.hdrColor+xview_getHdr(column:XView.left.Width);
       pos+=2;
       column.pos=pos;
       if XView.right.lColumn=XView.left.lColumn;
         return XView.hdrs;
       endif;
       pos+=XView.left.Width+1;
       // middle columns
       lColumn=tree_getNext(lColumn);
       dow lColumn<>XView.right.lColumn;
         pColumn=tree_getItem(lColumn);
         column.pos=pos;
         XView.hdrs+=XView.hdrColor+xview_getHdr(column:column.maxWidth);
         pos+=1+column.maxWidth;
         lColumn=tree_getNext(lColumn);
       endDo;
       // Rightmost column
       lColumn=XView.right.lcolumn;
       pColumn=tree_getItem(lColumn);
       column.pos=pos;
       XView.hdrs+=XView.hdrColor+xview_getHdr(column:XView.right.Width);
       return XView.hdrs;
       end-proc;
      // --------------------------------------------------------------------
      // Load header
      // --------------------------------------------------------------------
       dcl-proc  xview_getHdr;
       dcl-pi xview_getHdr varchar(130);
         column       likeds(tColumn);
         width  uns(3) const;
       end-pi;

       dcl-s hdr    varchar(130);
       dcl-s hdr1   char(30);
       dcl-s d      uns(3);
       dcl-s d1     uns(3);
       dcl-s d2     uns(3);
       dcl-s dashes char(130)    inz(*all'-');
       // Prepare the header
       hdr1=column.hdr1;
       hdr=%trim(%subst(hdr1:1:column.hdrWidth));
       d=Width-%len(hdr);
       if d>=6;
         hdr='-- '+hdr+' '+%subst(dashes:1:d-4);
       elseif d>0;
         d1=d/2;
         d2=d-d1;
         hdr=%subst(dashes:1:d1)+hdr;
         if d2>0;
           hdr=hdr+%subst(dashes:1:d2);
         endif;
       endIf;
       return hdr;
       end-proc;
      // --------------------------------------------------------------------
      // get column at position
      // --------------------------------------------------------------------
       dcl-proc xview_getColumnAtPos export;
       dcl-pi xview_getColumnAtPos ind;
         lXView      pointer const;
         pos         uns(3)  const;
         lColumn_    pointer;
         posOnColumn uns(5);
       end-pi;

       dcl-ds XView likeds(tXView) based(pXView);
       dcl-s lColumn pointer;
       dcl-ds column likeds(tColumn) based(pColumn);
       pXView=tree_getItem(lXView);
       // loop on each displayed column
       lColumn=XView.left.lColumn;
       dow lColumn<>*null;
         lColumn_=lColumn;
         pColumn=tree_getItem(lColumn);
         if lColumn=XView.left.lColumn
         and pos>=column.pos-1
         and pos<=column.pos+XView.left.width-1;
           posOnColumn=XView.left.pos+pos-column.pos;
           return *on;
         elseif lColumn=XView.right.lColumn
         and pos>=column.pos-1
         and pos<=column.pos+XView.right.width-1;
           posOnColumn=XView.right.pos+pos-column.pos;
           return *on;
         elseif lColumn=XView.right.lColumn;
           return *off;
         elseif lColumn<>XView.left.lColumn
            and pos>=column.pos-1
            and pos<=column.pos+column.MAXwidth-1;
           posOnColumn=1+pos-column.pos;
           return *on;
         endIf;
         lColumn=tree_getNext(lColumn);
       endDo;
       return *off;
       end-proc;
      // --------------------------------------------------------------------
      // reload the grid of xView
      // --------------------------------------------------------------------
       dcl-proc xview_reloadGrid export;
       dcl-pi xview_reloadGrid;
         XVIEW             likeDs(tXView);
         lGrids pointer;
         lGrid  pointer;
         gridID varchar(10) const;
         width  uns(3)      const;
       end-pi;

       dcl-s lColumn pointer;
       dcl-ds column likeDs(tColumn) based(pColumn);
       // untied old grid
       tree_unTied(lGrid);
       // setup new grid
       xView.lGrid=grid_getGrid(lGrids:gridID);
       // Resolve formulas
       lColumn=tree_getFirst(XView.lGrid);
       dow lColumn<>*null;
         column.lFormula=int_FormulaLoad(column.formula:XView.lFmt);
         lColumn=tree_getNext(lColumn);
       endDo;
       // left position in the new grid
       xView.left.lColumn=tree_getLinkFromList(XView.lGrid
                                              :kColumn
                                              :xview.leftColID);
       xview_setRightColumn(XView:width);
       // clear headers
       xView.hdrs='';
       end-proc;
