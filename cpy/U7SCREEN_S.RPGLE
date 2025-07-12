      // flag to indicate the screen need to refreshed
       dcl-s FKsToRefresh ind inz(*on);
      // function key
       dcl-c kFK 'k';
       dcl-ds tFK qualified;
         kItem     char(1)        inz(kFK);
         key       varchar(1)    ;
         fControl  ind           ;
         pFunction pointer(*proc);
       end-ds;
      // function key context
       dcl-c kFKC 'c';
       dcl-ds tFKC qualified;
         kItem char(1)     inz(kFKC);
         ID    varchar(1) ;
         libel varchar(30);
       end-ds;
      // Option
       dcl-c kOption 'o';
       dcl-ds tOption qualified;
         kItem char(1)     inz(kOption);
         id    varchar(2) ;
         text  varchar(30)  inz('');
       end-ds;
