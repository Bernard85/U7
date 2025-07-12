      // View
       dcl-c kXView 'v';
       dcl-ds tXView qualified;
         kind      char(1)      inz(kXView);
         ID        varchar(10) ;
         hdrColor  char(1)      inz(x'22');
         detColor  char(1)      inz(x'20');
         chgColor  char(1)      inz(x'29');
         hdrs      varchar(131)  inz('');
         lfmt      pointer     ;
         lGrid     pointer     ;
         left                  likeds(tLimit);
         right                 likeds(tLimit);
         leftColID varchar(10) ;
       end-ds;
      *
       dcl-ds tLimit qualified;
         lColumn pointer inz(*null);
         pos     uns(5)  inz(0);
         width   uns(3)  inz(0);
         most    ind     inz(*off);
       end-ds;
      // get View
       dcl-pr xview_getXView pointer;
         lXViews pointer;
         lGrids  pointer;
         lFmts   pointer;
         ID varchar(10)  const;
         fAppli_ char(1) const options(*nopass);
       end-pr;
      // set headers
       dcl-pr xview_setHdrs varchar(131);
         xView       likeds(tXView);
         pos   uns(5) value;
       end-pr;
      // position to the most left position
       dcl-pr xview_PosToMostLeft;
         XView       likeDs(tXView);
         width uns(3) const;
       end-pr;
      // position to the left
       dcl-pr xview_PosAtLeft;
         XView          likeDs(tXView);
         width   uns(3)  value;
         lColumn pointer const;
         pos     uns(3)  value;
       end-pr;
      // get limits from right
       dcl-pr xview_TabRight;
         XView       likeDs(tXView);
         width uns(3) const;
       end-pr;
      // get limits from left
       dcl-pr xview_TabLeft;
         XView       likeDs(tXView);
         width uns(3) const;
       end-pr;
      // get column at position
       dcl-pr xview_getColumnAtPos ind;
         lXView      pointer const;
         pos         uns(3)  const;
         lColumn_    pointer;
         posOnColumn uns(5) ;
       end-pr;
      // reload the grid of xView
       dcl-pr xview_reloadGrid;
         XVIEW             likeDs(tXView);
         lGrids pointer    ;
         lGrid  pointer    ;
         gridID varchar(10) const ;
         width  uns(3)      const;
       end-pr;
