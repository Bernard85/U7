      // set new function key
       dcl-pr Screen_setFK;
         lFKs      pointer       ;
         key       char(1)        const;
         fControl  ind            const;
         pFunction pointer(*proc) const ;
         libel0    varchar(30)    const  options(*nopass);
         libel1    varchar(30)    const  options(*nopass);
         libel2    varchar(30)    const  options(*nopass);
       end-pr;
      // screen need to be refreshed
       dcl-pr screen_FKsToRefresh ind;
       end-pr;
      // get function key entitle
       dcl-pr screen_getfkentitle varchar(123);
         lFKs pointer const;
       end-pr;
      // control FK and eventualy perform function tied
       dcl-pr screen_processFK;
         pgmID    char(10)       const;
         lFKs     pointer        const;
         key      char(1)        const;
         pControl pointer(*proc) const ;
       end-pr;
      // get function key context
       dcl-pr screen_getFKcontext char(1);
         lFKs pointer const;
         key  char(1) const;
       end-pr;
      // set function key context
       dcl-pr screen_setFKcontext;
         lFKs    pointer const;
         key     char(1) const;
         context char(1) const;
       end-pr;
      // set new option
       dcl-pr screen_setOption;
         lOptions pointer    ;
         ID       char(2)     const;
         text_    varchar(30) const  options(*nopass);
       end-pr;
      // get options entitle
       dcl-pr screen_getChoicesEntitle varchar(100);
         lOptions pointer const;
       end-pr;
      // set sflend
       dcl-pr screen_setSflend;
         sflEnd char(7);
         atEnd  ind     const;
       end-pr;
