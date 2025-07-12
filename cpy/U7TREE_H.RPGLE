      // Link kind
       dcl-c kLink '#';
      // Ling type
       dcl-ds tLink qualified;
         kType   char(1) inz(kLink);
         pParent pointer inz(*null);
         pFirst  pointer inz(*null);
         pNext   pointer inz(*null);
         pPrev   pointer inz(*null);
         level   int(3)  inz(0);
         pItem   pointer inz(*null);
         option  char(2) inz('');
         flag    char(1) inz(X'00');
       end-ds;
      // flag definition
       dcl-c fOpen  0;
       dcl-c fError 1;
      // for bringing item
       dcl-ds tree_Item qualified;
         ptr  pointer inz(*null);
         kind char(1) inz('?');
       end-ds;
      // get new link
       dcl-pr tree_getNewLink pointer;
         pItem pointer const;
       end-pr;
      // get new item (init)
       dcl-pr tree_getNewItem pointer;
         pTemplate    pointer const;
         sizeTemplate uns(5)  const;
       end-pr;
      // Open a link
       dcl-pr tree_OpenLink;
         pLink pointer const;
       end-pr;
      // close a link
       dcl-pr tree_closeLink;
         pLink pointer const;
       end-pr;
      // get flag of a link
       dcl-pr tree_getFlag ind;
         pLink_ pointer const;
         iFlag  uns(3)  const;
       end-pr;
      // set flag of a link
       dcl-pr tree_setFlag;
         pLink_ pointer const;
         iFlag  uns(3)  const;
         status ind     const;
       end-pr;
      // Link a node to its parent
       dcl-pr tree_linkToParent;
         pParentLink_ pointer const;
         pNewLink_    pointer const;
         pNextLink_   pointer const options(*nopass);
       end-pr;
      // get item from a node
       dcl-pr tree_getItem pointer;
         pLink_ pointer const;
       end-pr;
      // get kind of a link
       dcl-pr tree_getKind char(1);
         pLink_ pointer const;
       end-pr;
      // get first link
       dcl-pr tree_getFirst pointer;
         pLink_ pointer const;
       end-pr;
      // force first child
       dcl-pr tree_setFirst;
         lItem pointer const;
       end-pr;
      // get level of a link
       dcl-pr tree_getLevel int(3);
         pLink_ pointer const;
       end-pr;
      // get option of a link
       dcl-pr tree_getOption char(2);
         pLink_ pointer const;
       end-pr;
      // set option of a link
       dcl-pr tree_setOption;
         pLink_ pointer const;
         option char(2) const;
       end-pr;
      // get true if the link is open
       dcl-pr tree_isOpen ind;
         pLink_ pointer const;
       end-pr;
      // get parent
       dcl-pr tree_getParent pointer;
         pLink_ pointer const;
       end-pr;
      // get current link
       dcl-pr tree_getCurrent pointer;
         pRoot       pointer        const;
         pLink       pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pr;
      // get next link
       dcl-pr tree_getNext pointer;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pr;
      // get next link in Loop
       dcl-pr tree_getNextInLoop pointer;
         pLink pointer const;
       end-pr;
      // get previous link
       dcl-pr tree_getPrev pointer;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pr;
      // get the next row to sisplay
       dcl-pr tree_getNextToDisplay pointer;
         pRoot       pointer        const;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pr;
      // get the first link to display
       dcl-pr tree_getFirstToDisplay pointer;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pr;
      // get parent to display
       dcl-pr tree_getParentToDisplay pointer;
         pRoot  pointer const;
         pLink_ pointer const;
       end-pr;
      // get previous row to display
       dcl-pr tree_getPrevToDisplay pointer;
         pRoot       pointer        const;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pr;
      // get the last of last to display
       dcl-pr tree_getLastOfLastToDisplay pointer;
         pLink_      pointer        const;
         pValidator_ pointer(*proc) const  options(*nopass);
       end-pr;
      // get item from list by ID
       dcl-pr tree_getLinkfromList pointer;
         lItems pointer      const;
         kind   char(1)      const;
         ID     varchar(255) const  options(*nopass);
       end-pr;
      // get last
       dcl-pr tree_getLast pointer;
         pLink_ pointer const;
       end-pr;
      // link is of the kind
       dcl-pr tree_isOfTheKind ind;
         kind   char(1) const;
         pLink_ pointer const;
         pItem  pointer options(*nopass);
       end-pr;
      // Sort childs of a link
       dcl-pr tree_sort;
         lParent     pointer        const;
         pComparator pointer(*proc) const  options(*nopass);
       end-pr;
      // Link 2 brothers
       dcl-pr tree_Link2Brothers;
         pLink1_ pointer const;
         pLink2_ pointer const;
       end-pr;
      // untied a link
       dcl-pr tree_unTied;
         pLink_ pointer;
       end-pr;
      // dealloc a link
       dcl-pr tree_dealloc;
         lLink       pointer       ;
         pDeallocate pointer(*proc) const  options(*nopass);
       end-pr;
      // dealloc childs of a link
       dcl-pr tree_deallocChilds;
         lLink       pointer        const;
         pDeallocate pointer(*proc) const ;
       end-pr;
      // check link well defined
       dcl-pr tree_checkLink pointer;
         lItem pointer;
         level int(3) const;
       end-pr;
      // set Item for a link
       dcl-pr tree_setItem;
         pLink_ pointer const;
         pItem  pointer const;
       end-pr;
      // set Level for a link
       dcl-pr tree_setLevel;
         pLink_ pointer const;
         level  int(3)  const;
       end-pr;
      // set error on a link
       dcl-pr tree_setError;
         pLink       pointer        const;
         bError      ind            const ;
       end-pr;
      // Link is on error
       dcl-pr tree_onError ind;
         pLink       pointer        const;
       end-pr;
