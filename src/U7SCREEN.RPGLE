     h option(*noshowcpy) nomain
      /copy cpy,u7msg_h
      /copy cpy,u7screen_h
      /copy cpy,u7screen_s
      /copy cpy,u7tree_h
      // --------------------------------------------------------------------
      // set new function key
      // --------------------------------------------------------------------
       dcl-proc  screen_setFK export;
       dcl-pi screen_setFK;
         lFKS      pointer;
         key       char(1)        const;
         fControl  ind            const;
         pfunction pointer(*proc) const;
         libel0    varchar(30)    const  options(*nopass);
         libel1    varchar(30)    const  options(*nopass);
         libel2    varchar(30)    const  options(*nopass);
       end-pi;
      *
       dcl-ds FK likeds(tFK) based(pFK);
       dcl-s lFK pointer;
       if lFKs=*null;
         lFKs=tree_getNewLink(*null);
       endIf;
       pFK=tree_getNewItem(%addr(tFK):%size(tFK));
       FK.key=key;
       FK.fControl=fControl;
       FK.pFunction=pFunction;
       lFK=tree_getNewLink(pFK);
       tree_LinkToParent(lFKs:lFK);
       screen_setFKC(lFK:%parms():%parmnum(Libel0):'0':libel0);
       screen_setFKC(lFK:%parms():%parmnum(Libel1):'1':libel1);
       screen_setFKC(lFK:%parms():%parmnum(Libel2):'2':libel2);
       FKsToRefresh=*on;
       end-proc;
      // --------------------------------------------------------------------
      // set new function key
      // --------------------------------------------------------------------
       dcl-proc  screen_setFKC;
       dcl-pi screen_setFKC;
         lFK     pointer     const;
         parms   uns(3)      const;
         parmnum uns(3)      const;
         ID      char(1)     const;
         libel   varchar(30) const  options(*nopass);
       end-pi;
      *
       dcl-ds FKC likeds(tFKC) based(pFKC);
       if parms<parmnum;
         return;
       endif;
       pFKC=tree_getnewitem(%addr(tFKC):%size(tFKC));
       FKC.ID=ID;
       FKC.libel=libel;
       tree_LinkToParent(lFK:tree_getNewLink(pFKC));
       end-proc;
      // -----------------------------------------------------------------------
      // get function key context
      // -----------------------------------------------------------------------
       dcl-proc screen_getFKcontext export;
       dcl-pi screen_getFKcontext char(1);
         lFKs pointer const;
         key  char(1) const;
       end-pi;
      *
       dcl-s lFK pointer;
       dcl-ds FK likeDs(tFK) based(pFK);
       dcl-s lFKC pointer;
       dcl-ds FKC likeDs(tFKC) based(pFKC);
       lFK=tree_getLinkFromList(lFKs:kFK:key);
       if lFK=*null;
         return '';
       endIf;
       lFKC=tree_getFirst(lFK);
       if lFKC=*null;
         return '';
       endIf;
       pFKC=tree_getItem(lFKC);
       return FKC.ID;
       end-proc;
      // -----------------------------------------------------------------------
      // set function key context
      // -----------------------------------------------------------------------
       dcl-proc screen_setFKcontext export;
       dcl-pi screen_setFKcontext;
         lFKs    pointer const;
         key     char(1) const;
         context char(1) const;
       end-pi;
      *
       dcl-s lFK pointer;
       dcl-ds FK likeDs(tFK) based(pFK);
       dcl-s lFKC pointer;
       dcl-ds FKC likeDs(tFKC) based(pFKC);
       lFK=tree_getLinkFromList(lFKs:kFK:key);
       if lFK=*null;
         return;
       endif;
       lFKC=tree_getLinkFromList(lFK:kFKC:context);
       if lFKC=*null;
         return;
       endif;
       tree_setFirst(lFKC);
       end-proc;
      // -----------------------------------------------------------------------
      // screen need to be refreshed
      // -----------------------------------------------------------------------
       dcl-proc screen_FKsToRefresh export;
       dcl-pi screen_FKsToRefresh ind;
       end-pi;
       return FKsToRefresh;
       end-proc;
      // -----------------------------------------------------------------------
      // get function key entitle
      // -----------------------------------------------------------------------
       dcl-proc screen_getfkentitle export;
       dcl-pi screen_getfkentitle varchar(123);
         lFKs pointer const;
       end-pi;
      *
       dcl-s lFK pointer;
       dcl-ds FK likeds(tFK) based(pFK);
       dcl-s wFK varchar(123)  inz('');
       dcl-ds FKC likeds(tFKC) based(pFKC);
       dcl-s lFKC pointer;
       lFK=tree_getFirst(lFKs);
       dow lFK<>*null;
         lFKC=tree_getFirst(lFK);
         if lFKC<>*null;
           pFKC=tree_getItem(lFKC);
           wFK+=FKC.libel+'  ';
         endIf;
         lFK=tree_getNext(lFK);
       endDo;
       FKsToRefresh=*off;
       return wfk;
       end-proc;
      // --------------------------------------------------------------------
      // control FK and eventualy perform action tied
      // --------------------------------------------------------------------
       dcl-proc screen_processFK export;
       dcl-pi screen_processFK;
         pgmID    char(10)       const;
         lFKs     pointer        const;
         key      char(1)        const;
         pControl pointer(*proc) const;
       end-pi;
      *
       dcl-s lFK pointer;
       dcl-ds FK likeDS(tFK) based(pFK);
       dcl-s lFKC pointer;
       dcl-pr control ind extproc(pControl);
       end-pr;
       dcl-pr function extproc(FK.pFunction);
       end-pr;
       // Check if the function key is allowed                               -
       lFK=tree_getLinkFromList(lFKs:kFK:key);
       if lFK=*null;
         msg_SndPM(pgmID:'Function key invalid.');
         return;
       endIf;
       // get the action from function key
       pFK=tree_getItem(lFK);
       // if control needed process it
       if FK.fControl and control();
         return;
       endif;
       // Change context/libel on FK
       if tree_getFirst(lFK)<>tree_getLast(lFK);
         lFKC=tree_getFirst(lFK);
         lFKC=tree_getNextInLoop(lFKC);
         tree_setFirst(lFKC);
         FKsToRefresh=*on;
       endIf;
       // no erros : perform the action tied to function key
       if FK.pFunction<>*null;
         function();
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // set new option
      // --------------------------------------------------------------------
       dcl-proc screen_setOption export;
       dcl-pi screen_setOption;
         lOptions pointer;
         ID       char(2)     const;
         text     varchar(30) const  options(*nopass);
       end-pi;
      *
       dcl-ds option likeds(tOption) based(pOption);
       if lOptions=*null;
         lOptions=tree_getNewLink(*null);
       endIf;
       pOption=tree_getNewItem(%addr(tOption):%size(tOption));
       Option.ID=ID;
       if %parms()=%parmnum(text);
         Option.text=text;
       endIf;
       tree_LinkToParent(lOptions:tree_getNewLink(pOption));
       end-proc;
      // -----------------------------------------------------------------------
      // get options entitle
      // -----------------------------------------------------------------------
       dcl-proc screen_getChoicesEntitle export;
       dcl-pi screen_getChoicesEntitle varchar(100);
         lOptions pointer const;
       end-pi;
      *
       dcl-s lOption pointer;
       dcl-ds option likeds(tOption) based(pOption);
       dcl-s wEntitle varchar(100)  inz('');
       lOption=tree_getFirst(lOptions);
       dow lOption<>*null;
         pOption=tree_getItem(lOption);
         if Option.text<>'';
           wEntitle+=Option.text+'  ';
         endIf;
         lOption=tree_getNext(lOption);
       endDo;
       return wEntitle;
       end-proc;
       // ----------------------------------------------------------------------
       // set sflend
       // ----------------------------------------------------------------------
       dcl-proc screen_setSflend export;
       dcl-pi screen_setSflend;
         sflEnd char(7);
         atEnd  ind     const;
       end-pi;
       if atEnd;
         SflEnd='Bottom';
       else;
         SflEnd='More...';
       endIf;
       end-proc;
