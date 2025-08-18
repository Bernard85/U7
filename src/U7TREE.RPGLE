     h nomain
      // copy
      /copy cpy,u7ifs_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      // --------------------------------------------------------------------
      // get new link
      // --------------------------------------------------------------------
       dcl-proc  tree_getNewLink export;
       dcl-pi tree_getNewLink pointer;
         pItem pointer const;
       end-pi;
       dcl-ds newLink likeDs(tLink) based(pNewLink);
       dcl-s test packed(13:2);
       pNewLink=tree_getNewItem(%addr(tLink):%size(tLink));
       NewLink.pItem=pItem;
       tree_OpenLink(pNewLink);
       return pNewLink;
       end-proc;
      // --------------------------------------------------------------------
      // get new item (init)
      // --------------------------------------------------------------------
       dcl-proc  tree_getNewItem export;
       dcl-pi tree_getNewItem pointer;
         pTemplate    pointer const;
         sizeTemplate uns(5)  const;
       end-pi;
      *
       dcl-s pNewItem pointer;
       pNewItem=%alloc(sizeTemplate);
       ifs_memcpy(pNewItem:pTemplate:sizeTemplate);
       return pnewItem;
       end-proc;
      // --------------------------------------------------------------------
      // Open a link
      // --------------------------------------------------------------------
       dcl-proc  tree_OpenLink export;
       dcl-pi tree_OpenLink;
         pLink_ pointer const;
       end-pi;
      *
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       ifs_setbit(%addr(Link.flag):fopen:*on);
       end-proc;
      // --------------------------------------------------------------------
      // close a link
      // --------------------------------------------------------------------
       dcl-proc  tree_CloseLink export;
       dcl-pi tree_closeLink;
         pLink_ pointer const;
       end-pi;
      *
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       ifs_setbit(%addr(link.flag):fopen:*off);
       end-proc;
      // --------------------------------------------------------------------
      // link is closed
      // --------------------------------------------------------------------
       dcl-proc tree_linkisClosed export;
       dcl-pi tree_linkisClosed ind;
         pLink pointer const;
       end-pi;
       return not tree_getFlag(pLink:fOpen);
       end-proc;
      // --------------------------------------------------------------------
      // set error on a link
      // --------------------------------------------------------------------
       dcl-proc tree_setError export;
       dcl-pi tree_setError;
         pLink_ pointer const;
         bError ind     const;
       end-pi;
      *
       dcl-ds link likeDs(tLink) based(pLink);
       pLink=pLink_;
       ifs_setBit(%addr(link.flag):fError:bError);
       end-proc;
      // --------------------------------------------------------------------
      // get flag of a link
      // --------------------------------------------------------------------
       dcl-proc  tree_getFlag export;
       dcl-pi tree_getFlag ind;
         pLink_ pointer const;
         iFlag  uns(3)  const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       return ifs_testbit(%addr(link.flag):iFlag);
       end-proc;
      // --------------------------------------------------------------------
      // set flag of a link
      // --------------------------------------------------------------------
       dcl-proc  tree_setFlag export;
       dcl-pi tree_setFlag;
         pLink_ pointer const;
         iFlag  uns(3)  const;
         status ind     const;
       end-pi;
      *
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       ifs_setbit(%addr(link.flag):iFlag:status);
       end-proc;
      // --------------------------------------------------------------------
      // Link item to its parent
      // --------------------------------------------------------------------
       dcl-proc tree_linkToParent export;
       dcl-pi tree_linkToParent;
         pParentLink_ pointer const;
         pNewLink_    pointer const;
         pNextLink_   pointer const options(*nopass);
       end-pi;
      *
       dcl-ds parentLink likeDs(tLink) based(pParentLink);
       dcl-ds nextLink   likeDs(tLink) based(pnextLink);
       dcl-ds newLink    likeDs(tLink) based(pnewLink);
       dcl-ds Link1      likeDs(tLink) based(pLink1);
       dcl-ds Link9      likeDs(tLink) based(pLink9);
      *
       dcl-s pPrevLink pointer;
       pParentLink=pParentLink_;
       pNewLink   =pNewLink_;
       if %parms()=3;
         pNextLink =pNextLink_;
       endIf;
      //
       NewLink.pParent=pParentLink;
       if newlink.pFirst=*null;
         NewLink.level=ParentLink.level+1;
       endif;
       // Parent without child
       if ParentLink.pFirst =*null;
         ParentLink.pFirst =pNewLink;
         tree_link2Brothers(pNewLink:pNewLink);
       elseif pNextLink<>*null;
         pPrevLink=NextLink.pPrev;
         tree_link2Brothers(pPrevLink:pNewLink);
         tree_link2Brothers(pNewLink :pNextLink);
         if ParentLink.pFirst =pNextLink;
           ParentLink.pFirst =pNewLink;
         endIf;
       else;
         pLink1=ParentLink.pFirst;
         pLink9=Link1.pPrev;
         tree_link2Brothers(pLink9:pNewLink);
         tree_link2Brothers(pNewLink:pLink1);
       endif;
       return;
       end-proc;
      // --------------------------------------------------------------------
      // Link 2 brothers
      // --------------------------------------------------------------------
       dcl-proc tree_Link2Brothers export;
       dcl-pi tree_Link2Brothers;
         pLink1_ pointer const;
         pLink2_ pointer const;
       end-pi;
       dcl-ds Link1 likeDs(tLink) based(pLink1);
       dcl-ds Link2 likeDs(tLink) based(pLink2);
       pLink1=pLink1_;
       pLink2=pLink2_;
       if plink1=*null or plink2=*null;
       return;
       endIf;
       link1.pNext=plink2;
       Link2.pPrev=plink1;
       end-proc;
      // --------------------------------------------------------------------
      // get item from a node
      // --------------------------------------------------------------------
       dcl-proc  tree_getItem export;
       dcl-pi tree_getItem pointer;
         pLink_ pointer const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       if pLink=*null;
         return *null;
       endIf;
       return Link.pItem;
       end-proc;
      // --------------------------------------------------------------------
      // get parent of a node
      // --------------------------------------------------------------------
       dcl-proc  tree_getParent export;
       dcl-pi tree_getParent pointer;
         pLink_ pointer const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       return Link.pParent;
       end-proc;
      // --------------------------------------------------------------------
      // get kind of a link/item
      // --------------------------------------------------------------------
       dcl-proc  tree_getKind export;
       dcl-pi tree_getKind char(1);
         pLink_ pointer const;
       end-pi;
       dcl-ds item qualified based(pItem);
         kind char(1);
       end-ds;
       dcl-ds Link likeDs(tLink) based(pLink);
       if pLink_=*null;
         return '';
       endIf;
       pLink=pLink_;
       pItem=tree_getItem(pLink);
       if pItem=*null;
         return '';
       endIf;
       return Item.kind;
       end-proc;
      // -----------------------------------------------------------------------
      // get first child
      // -----------------------------------------------------------------------
       dcl-proc  tree_getFirst export;
       dcl-pi tree_getFirst pointer;
         pLink_ pointer const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       if pLink_=*null;
         return *null;
       endif;
       pLink=pLink_;
       return Link.pFirst;
       end-proc;
      // -----------------------------------------------------------------------
      // force first child
      // -----------------------------------------------------------------------
       dcl-proc  tree_setFirst export;
       dcl-pi tree_setFirst;
         lItem pointer const;
       end-pi;
      *
       dcl-ds parent likeDs(tLink) based(lParent);
       lParent=tree_getParent(lItem);
       Parent.pFirst=lItem;
       end-proc;
      // -----------------------------------------------------------------------
      // get last child
      // -----------------------------------------------------------------------
       dcl-proc  tree_getLast export;
       dcl-pi tree_getLast pointer;
         pLink_ pointer const;
       end-pi;
       dcl-ds Link  likeDs(tLink) based(pLink);
       dcl-ds Link2 likeDs(tLink) based(pLink2);
       if pLink_=*null;
         return *null;
       endif;
       pLink=pLink_;
       pLink2=Link.pFirst;
       if pLink2=*null;
         return *null;
       endif;
       return Link2.pPrev;
       end-proc;
      // --------------------------------------------------------------------
      // get level of a link
      // --------------------------------------------------------------------
       dcl-proc  tree_getLevel export;
       dcl-pi tree_getLevel int(3);
         pLink_ pointer const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       return link.level;
       end-proc;
      // --------------------------------------------------------------------
      // get option of a link
      // --------------------------------------------------------------------
       dcl-proc  tree_getOption export;
       dcl-pi tree_getOption char(2);
         pLink_ pointer const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       return link.option;
       end-proc;
      // --------------------------------------------------------------------
      // set option of a link
      // --------------------------------------------------------------------
       dcl-proc  tree_setOption export;
       dcl-pi tree_setOption;
         pLink_ pointer const;
         option char(2) const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       link.option=option;
       end-proc;
      // --------------------------------------------------------------------
      // is the link is open
      // --------------------------------------------------------------------
       dcl-proc  tree_isOpen export;
       dcl-pi tree_isOpen ind;
         pLink_ pointer const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       return tree_getFlag(pLink:fOpen);
       end-proc;
      // --------------------------------------------------------------------
      // is the link is on error
      // --------------------------------------------------------------------
       dcl-proc  tree_onError export;
       dcl-pi tree_onError ind;
         pLink_ pointer const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       return tree_getFlag(pLink:fError);
       end-proc;
      // ------------------------------------------------------------------- ---
      // get current link
      // ------------------------------------------------------------------- ---
       dcl-proc  tree_getCurrent export;
       dcl-pi tree_getCurrent pointer;
         pRoot       pointer        const;
         pLink       pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pi;
      *
       dcl-s pValidator pointer(*proc)  inz(*null);
       dcl-s isValid int(3);
       dcl-s pNext   pointer;
        if %parms()=%parmnum(pValidator_);
          pValidator=pValidator_;
        endIf;
        if tree_Validator(pLink:pValidator:isValid)=1;
          return pLink;
        endIf;
        pNext=tree_getNextToDisplay(pRoot:pLink:pValidator);
        if pNext<>*null;
          return pNext;
        endIf;
        return tree_getPrevToDisplay(pRoot:pLink:pValidator);
       end-proc;
      // ------------------------------------------------------------------- ---
      // get next link
      // ------------------------------------------------------------------- ---
       dcl-proc  tree_getNext export;
       dcl-pi tree_getNext pointer;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pi;
       dcl-ds link   likeDs(tLink) based(pLink);
       dcl-ds Parent likeDs(tLink) based(pParent);
       dcl-s pValidator pointer(*proc)  inz(*null);
       dcl-s isValid    int(3);
       if pLink_=*null;
         return *null;
       endIf;
       if %parms()=%parmnum(pValidator_);
         pValidator=pValidator_;
       endIf;
       pLink=pLink_;
       // no parent has no brother
       if Link.pParent=*null;
         return *null;
       endIf;
       pParent=Link.pParent;
       pLink=Link.pNext;
       dow pLink<>parent.pFirst;
         if tree_Validator(pLink:pValidator:isValid)=1;
           return pLink;
         elseif isValid=-1;
           return *null;
         endif;
         pLink=Link.pNext;
       endDo;
       return *null;
       end-proc;
      // -----------------------------------------------------------------------
      // get previous link
      // -----------------------------------------------------------------------
       dcl-proc  tree_getPrev export;
       dcl-pi tree_getPrev pointer;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pi;
       dcl-ds Link   likeDs(tLink) based(pLink);
       dcl-ds Parent likeDs(tLink) based(pParent);
       dcl-s pValidator pointer(*proc)  inz(*null);
       dcl-s isValid    int(3);
       if pLink_=*null;
         return *null;
       endIf;
       if %parms()=%parmnum(pValidator_);
         pValidator=pValidator_;
       endIf;
       pLink=pLink_;
       // no parent has no brother
       if Link.pParent=*null;
         return *null;
       endIf;
       //
       pParent=Link.pParent;
       dow 1=1;
         if pLink=parent.pFirst;
           return *null;
         endif;
         pLink=Link.pPrev;
         if tree_Validator(pLink:pValidator:isValid)=1;
           return pLink;
         elseif isValid=-1;
           return *null;
         endif;
       endDo;
       end-proc;
      // -----------------------------------------------------------------------
      // Validator Stop:-1, Skip:0, Take it:1
      // -----------------------------------------------------------------------
       dcl-proc  tree_Validator;
       dcl-pi tree_Validator int(3);
         pLink      pointer        const;
         pValidator pointer(*proc) const;
         isValid    int(3);
       end-pi;
      *
       dcl-pr Validator int(3) extproc(pValidator);
         pLink pointer const;
       end-pr;
       if pValidator=*null;
         isValid=1;
       else;
         isValid=Validator(pLink);
       endIf;
       return isValid;
       end-proc;
      // -----------------------------------------------------------------------
      // get next link in Loop
      // -----------------------------------------------------------------------
       dcl-proc tree_getNextInLoop export;
       dcl-pi tree_getNextInLoop pointer;
         pLink pointer const;
       end-pi;
      *
       dcl-s pX pointer;
       pX=tree_getNext(pLink);
       if pX=*null;
         pX=tree_getLast(tree_getParent(pLink));
       endIf;
       return pX;
       end-proc;
      // -----------------------------------------------------------------------
      // get the next row to display
      // -----------------------------------------------------------------------
       dcl-proc tree_getNextToDisplay export;
       dcl-pi tree_getNextToDisplay pointer;
         pRoot       pointer        const;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pi;
       dcl-s pValidator pointer(*proc)  inz(*null);
       dcl-s pX         pointer;
       if %parms()=%parmnum(pValidator_);
         pValidator=pValidator_;
       endIf;
       pX=tree_getFirstToDisplay(pLink_:pValidator);
       if pX<>*null;
         return pX;
       endIf;
       return tree_getNextOrAncestorNext(pRoot:pLink_:pValidator);
       end-proc;
      // -----------------------------------------------------------------------
      // get the first link to display
      // -----------------------------------------------------------------------
       dcl-proc tree_getFirstToDisplay export;
       dcl-pi tree_getFirstToDisplay pointer;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       dcl-s pValidator pointer(*proc)  inz(*null);
       dcl-s isValid    int(3);
       if %parms()=%parmnum(pValidator_);
         pValidator=pValidator_;
       endIf;
       if pLink_=*null;
         return *null;
       endif;
       pLink=pLink_;
       if Link.pFirst=*null or not tree_isOpen(pLink);
         return *null;
       endIf;
       //
       pLink=Link.pFirst;
       if tree_Validator(pLink:pValidator:isValid)=1;
         return pLink;
       elseif isValid=-1;
         return *null;
       else;
         return tree_getNext(pLink:pValidator);
       endIf;
       end-proc;
      // ------------------------------------------------------------------- ---
      // get my next or my ancestor next
      // ------------------------------------------------------------------- ---
       dcl-proc tree_getNextOrAncestorNext;
       dcl-pi tree_getNextOrAncestorNext pointer;
         pRoot      pointer        const;
         pLink_     pointer        const;
         pValidator pointer(*proc) const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       dcl-s pX pointer;
       if pLink_=*null;
         return *null;
       endIf;
       pLink=pLink_;
       pX=tree_getNext(pLink:pValidator);
       if pX<>*null;
         return pX;
       endIf;
       pX=tree_getParentToDisplay(pRoot:pLink);
       if pX=*null;
         return *null;
       endIf;
       return tree_getNextOrAncestorNext(pRoot:pX:pValidator);
       end-proc;
      // -----------------------------------------------------------------------
      // get parent to display
      // -----------------------------------------------------------------------
       dcl-proc tree_getParentToDisplay export;
       dcl-pi tree_getParentToDisplay pointer;
         pRoot  pointer const;
         pLink_ pointer const;
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       if Link.pParent=pRoot;
         return *null;
       endIf;
       return Link.pParent;
       end-proc;
      // -----------------------------------------------------------------------
      // get previous row to display
      // -----------------------------------------------------------------------
       dcl-proc tree_getPrevToDisplay export;
       dcl-pi tree_getPrevToDisplay pointer;
         pRoot       pointer        const;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pi;
       dcl-ds Link   likeDs(tLink) based(pLink);
       dcl-ds Parent likeDs(tLink) based(pParent);
       dcl-s pX         pointer;
       dcl-s pValidator pointer(*proc)  inz(*null);
       if %parms()=%parmnum(pValidator_);
         pValidator=pValidator_;
       endIf;
       pLink=pLink_;
       pX=tree_getPrev(pLink:pValidator);
       if pX<>*null;
         return tree_getLastOfLastToDisplay(pX:pValidator);
       endIf;
       return tree_getParentToDisplay(pRoot:pLink);
       end-proc;
      // -------------------------------------------------------------------*
      // get the last of last to display
      // --------------------------------------------------------------------
       dcl-proc tree_getLastOfLastToDisplay export;
       dcl-pi tree_getLastOfLastToDisplay pointer;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       dcl-s pX         pointer;
       dcl-s pValidator pointer(*proc)  inz(*null);
       if %parms()=%parmnum(pValidator_);
         pValidator=pValidator_;
       endIf;
       pLink=pLink_;
       pX=tree_GetLastToDisplay(pLink:pValidator);
       if pX<>*Null;
         return tree_getLastOfLastToDisplay(pX:pValidator);
       endIf;
       return pLink;
       end-proc;
      // -----------------------------------------------------------------------
      // get last child to display
      // -----------------------------------------------------------------------
       dcl-proc tree_getLastToDisplay;
       dcl-pi tree_getLastToDisplay pointer;
         pLink_     pointer        const;
         pValidator pointer(*proc) const;
       end-pi;
       dcl-ds Link  likeDs(tLink) based(pLink);
       dcl-ds Link2 likeDs(tLink) based(pLink2);
       dcl-s isValid int(3);
       dcl-s pX      pointer;
       if pLink_=*null;
         return *null;
       endif;
       pLink=pLink_;
       if Link.pFirst=*null or not tree_isOpen(pLink);
         return *null;
       endIf;
       pLink2=Link.pFirst;
       dou pLink2=link.pFirst;
         pLink2=Link2.pPrev;
         if tree_validator(pLink2:pValidator:isValid)=1;
           return pLink2;
         endIf;
       endDo;
       return *null;
       end-proc;
      // --------------------------------------------------------------------
      // get item from list by ID
      // --------------------------------------------------------------------
       dcl-proc tree_getLinkFromList export;
       dcl-pi tree_getLinkFromList pointer;
         lAnonyms pointer      const;
         kind     char(1)      const;
         ID       varchar(255) const  options(*nopass);
       end-pi;
      *
       dcl-ds tAnonym qualified template;
         kind char(1);
         ID   varchar(255);
       end-ds;
       dcl-s lAnonym pointer;
       dcl-ds Anonym likeds(tAnonym) based(pAnonym);
       lAnonym=tree_getFirst(lAnonyms);
       dow lAnonym<>*null;
         pAnonym=tree_getItem(lAnonym);
         if Anonym.kind=kind;
           if %parms()<%parmnum(ID);
             return lAnonym;
           elseif Anonym.id=id;
             return lAnonym;
           endif;
         endif;
         lAnonym=tree_getNext(lAnonym);
       endDo;
       return *null;
       end-proc;
      // -----------------------------------------------------------------------
      // link is of the kind
      // -----------------------------------------------------------------------
       dcl-proc tree_isOfTheKind export;
       dcl-pi tree_isOfTheKind ind;
         kind   char(1) const;
         pLink_ pointer const;
         pItem_ pointer options(*nopass);
       end-pi;
      //
       dcl-ds Link likeDs(tLink) based(pLink);
       dcl-ds item qualified based(pItem);
         kind char(1);
       end-ds;
       if pLink_=*null;
         return *off;
       endIf;
       pLink=pLink_;
       pItem=link.pItem;
       if pItem=*null;
         return *off;
       endIf;
       if Item.kind<>kind;
         return *off;
       endIf;
       if %parms()=3;
         pItem_=link.pItem;
       endif;
       return *on;
       end-proc;
      // -----------------------------------------------------------------------
      // Sort childs of a link
      // -----------------------------------------------------------------------
       dcl-proc  tree_Sort export;
       dcl-pi tree_sort;
         lParent      pointer        const;
         pComparator_ pointer(*proc) const  options(*nopass);
       end-pi;
      *
       dcl-s pComparator pointer(*proc)  inz(%pAddr(tree_compbyID));
       dcl-s lCurrent pointer;
       dcl-s lNext    pointer;
       // comparator
       if %parms()=%parmnum(pComparator_);
         pComparator=pComparator_;
       endIf;
       // Start on the 2nd link
       lCurrent=tree_getNext(tree_getFirst(lParent));
       dow lCurrent<>*null;
         lNext=tree_getNext(lCurrent);
         tree_sort2(lParent:lCurrent:pComparator);
         lCurrent=lNext;
       endDo;
       end-proc;
      // -----------------------------------------------------------------------
      // generic comparator
      // -----------------------------------------------------------------------
       dcl-proc  tree_CompByID;
       dcl-pi tree_CompById int(3);
         lGeneric1 pointer const;
         lGeneric2 pointer const;
       end-pi;
      *
       dcl-ds tGeneric;
         kAny char(1);
         ID varchar(255);
       end-ds;
      *
       dcl-ds generic1 likeDs(tGeneric) based(pGeneric1);
       dcl-ds generic2 likeDs(tGeneric) based(pGeneric2);
       pGeneric1=tree_getItem(lGeneric1);
       pGeneric2=tree_getItem(lGeneric2);
      // -1 1st is lower than 2nd
      // +1 1st is graeter than 2nd
      // 0  they are equal
       if generic1.ID<generic2.ID;
         return -1;
       elseif generic1.ID>generic2.ID;
         return +1;
       endIf;
       return 0;
       end-proc;
      // -----------------------------------------------------------------------
      // Sort childs of a link part2
      // -----------------------------------------------------------------------
       dcl-proc  tree_sort2;
       dcl-pi tree_sort2;
         lParent     pointer        const;
         lCurrent    pointer        const;
         pComparator pointer(*proc) const;
       end-pi;
      *
       dcl-s lPrev      pointer;
       dcl-s lFirst     pointer;
       dcl-s lPreceding pointer;
       dcl-s lFollow    pointer;
       dcl-s lGreater   pointer;
      *
       dcl-pr Comparator int(3) extproc(pComparator);
         lElement1 pointer const;
         lElement2 pointer const;
       end-pr;
       // Do noting if the previous is smaller
       lPrev=tree_getPrev(lCurrent);
       if comparator(lPrev:lCurrent)=-1;
         return;
       endIf;
       // Browse the list until find a smaller item
       lFirst =tree_getFirst(lParent);
       Dow comparator(lPrev:lCurrent)<>-1;
         lGreater=lPrev;
         if lPrev=lFirst;
           leave;
         endIf;
         lPrev=tree_getPrev(lPrev);
       endDo;
       // Linking 2 brothers
       lFollow   =tree_getNextReal(lCurrent);
       lPreceding=tree_getPrevReal(lCurrent);
       tree_Link2Brothers(lPreceding:lFollow);
       // Linking to parent (before the greater)
       tree_LinkToParent(lParent:lCurrent:lGreater);
       end-proc;
      // ------------------------------------------------------------------- ---
      // get link following
      // ------------------------------------------------------------------- ---
       dcl-proc tree_getNextReal;
       dcl-pi tree_getNextReal pointer;
         pLink_ pointer const;
       end-pi;
      *
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       return link.pNext;
       end-proc;
      // ------------------------------------------------------------------- ---
      // get link preceding
      // ------------------------------------------------------------------- ---
       dcl-proc tree_getPrevReal;
       dcl-pi tree_getPrevReal pointer;
         pLink_ pointer const;
       end-pi;
      *
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       return link.pPrev;
       end-proc;
      // --------------------------------------------------------------------
      // untied a link
      // --------------------------------------------------------------------
       dcl-proc  tree_untied export;
       dcl-pi tree_unTied;
         pLink_ pointer;
       end-pi;
      *
       dcl-ds link   likeDs(tLink) based(pLink);
       dcl-ds parent likeDs(tLink) based(pParent);
       if pLink_=*null;
         return;
       endIf;
       pLink=pLink_;
       pParent=Link.pParent;
       if Link.pNext=pLink;
         parent.pFirst=*null;
         return;
       elseif parent.pFirst=pLink;
         parent.pFirst=link.pNext;
       endif;
       tree_link2Brothers(link.pPrev:link.pNext);
       end-proc;
      // --------------------------------------------------------------------
      // dealloc a link
      // --------------------------------------------------------------------
       dcl-proc  tree_dealloc export;
       dcl-pi tree_dealloc;
         lLink        pointer;
         pDeallocate_ pointer(*proc) const  options(*nopass);
       end-pi;
      *
       dcl-s pDeallocate pointer(*proc)  inz(*null);
       dcl-pr Deallocate extproc(pDeallocate);
         pItem pointer;
       end-pr;
       dcl-s pItem pointer;
       if lLink=*null;
         return;
       endIf;
       if %parms()=%parmnum(pDeallocate_);
         pDeallocate=pDeallocate_;
       endIf;
       tree_deallocChilds(lLink:pDeallocate);
       if pDeallocate<>*null;
         deallocate(lLink);
       endIf;
       pItem=tree_getItem(lLink);
       if pItem<>*null;
         dealloc(en) pItem;
       endIf;
       dealloc(en) lLink;
       end-proc;
      // --------------------------------------------------------------------
      // dealloc childs of a link
      // --------------------------------------------------------------------
       dcl-proc tree_deallocChilds export;
       dcl-pi tree_deallocChilds;
         pLink_      pointer        const;
         pDeallocate pointer(*proc) const;
       end-pi;
      *
       dcl-s lCurrent pointer;
       dcl-s lNext    pointer;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       if pLink=*null;
         return;
       endIf;
       lCurrent=tree_getFirst(pLink);
       dow lCurrent<>*null;
         lNext=tree_getNext(lCurrent);
         tree_dealloc(lCurrent:pDeallocate);
         lCurrent=lNext;
       endDo;
       link.pFirst=*null;
       end-proc;
      // -----------------------------------------------------------------------
      // set Item for a link
      // -----------------------------------------------------------------------
       dcl-proc tree_setItem                                             export;
        dcl-pi *n;
          pLink_ pointer                                                  const;
          pItem  pointer                                                  const;
        end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       link.pItem=pItem;
       end-proc;
      // -----------------------------------------------------------------------
      // set level for a link
      // -----------------------------------------------------------------------
       dcl-proc tree_setLevel                                            export;
        dcl-pi *n;
          pLink_ pointer const;
          level int(3)  const;
        end-pi;
       dcl-ds Link likeDs(tLink) based(pLink);
       pLink=pLink_;
       link.level=level;
       end-proc;
      // -----------------------------------------------------------------------
      // check link well defined
      // -----------------------------------------------------------------------
       dcl-proc tree_checkLink export;
        dcl-pi *n pointer;
          lItem pointer;
          level int(3) const;
        end-pi;
        if lItem=*null;
          lItem=tree_getNewLink(*null);
        endif;
        tree_setlevel(lItem:level);
        return lItem;
        end-proc;
