      // Ling type
       dcl-ds tLink qualified;
         kType   char(1) inz(kLink);
         pParent pointer inz(*null);
         pFirst  pointer inz(*null);
         pNext   pointer inz(*null);
         pPrev   pointer inz(*null);
         level   int(3)  inz(0);
         pItem   pointer inz(*null);
         Option  char(2) inz('');
         flag    char(1) inz(X'00');
       end-ds;
      // flag definition
       dcl-c fOpen  0;
       dcl-c fError 1;
      // ToolBox used during tree definition
       dcl-ds tTreeBox qualified;
         lRoot        pointer        inz(*null);
         lCur         pointer        inz(*null);
         pXXX_getItem pointer(*proc);
       end-ds;
