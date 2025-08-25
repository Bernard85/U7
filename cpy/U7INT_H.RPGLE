      // Error
       dcl-c kErr 'e';
       dcl-ds tErr qualified;
         kind char(1) inz(kErr);
         pStr pointer inz(*null);
       end-ds;
      // constante
       dcl-c kCst 'c';
       dcl-ds tCst qualified;
         kind char(1) inz(kCst);
         pStr pointer inz(*null);
       end-ds;
      // procedure
       dcl-c kProc 'p';
       dcl-ds tProc qualified;
         kind  char(1)        inz(kProc);
         ID    varchar(25)   ;
         pAddr pointer(*proc);
       end-ds;
      // set of characters
       dcl-c min   'abcdefghijklmnopqrstuvwxyz';
       dcl-c maj   'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
       dcl-c num   '0123456789';
       dcl-c spec  '$%_#@£';
       dcl-c spec2 '.<(+!&!$*;¬-/ ,%_>?{ }\}\÷`:#@''="[]¯¨´°«»µ~éèêà';
       dcl-c colors x'202122232425262728292A2B2C2D2E3-
                      03132333435363738393A3B3C3D3E3F';
      // Check if string is displayable
       dcl-pr int_chkDisplay varchar(65535);
         c  varchar(256)    const;
         s_ varchar(65535)  const;
       end-pr;
      // Populate string with variables
       dcl-pr int_replaceAll varchar(255);
         source varchar(255) const ;
         v1     varchar(255) const  options(*nopass);
         v2     varchar(255) const  options(*nopass);
         v3     varchar(255) const  options(*nopass);
         v4     varchar(255) const  options(*nopass);
         v5     varchar(255) const  options(*nopass);
         v6     varchar(255) const  options(*nopass);
         v7     varchar(255) const  options(*nopass);
         v8     varchar(255) const  options(*nopass);
       end-pr;
      // get string from field
       dcl-pr int_getpStrFromField pointer;
         lField  pointer const;
         pBuffer pointer const;
         owned   ind    ;
         length  uns(5) ;
       end-pr;
      //  Alloc string
       dcl-pr int_allocString pointer;
         String varchar(2048) const ;
         owned  ind          ;
         len    uns(5)       ;
       end-pr;
      // edit numeric
       dcl-pr int_editNumeric varchar(32);
         pBuffer pointer const;
         field          const likeDs(tField);
       end-pr;
      // edit integer
       dcl-pr int_editInteger varchar(32);
         pBuffer pointer const;
         field          const likeDs(tField);
       end-pr;
      // get minus of 2 values
       dcl-pr int_getMin uns(5);
         v1 uns(5) const;
         v2 uns(5) const;
       end-pr;
      // Complete with space/dot at left
       dcl-pr int_AddSpaceDot varchar(255);
         source  varchar(255) const ;
         lastPos uns(3)       const;
       end-pr;
      // Scan from Right
       dcl-pr int_ScanR uns(3);
         charFound varchar(10)  const ;
         String    varchar(255) const ;
         fromPos_  uns(3)       const options(*nopass);
       end-pr;
      // get string from formula
       dcl-pr int_getStringFromFormula varchar(32000);
         pBuffer_ pointer const;
         pField_  pointer const;
       end-pr;
      // get string from formula
       dcl-pr int_getStringFromFormula2 varchar(32000);
         lFormula  pointer const;
         curBuffer uns(3)  const options(*nopass);
       end-pr;
      // load procedures
       dcl-pr int_LoadProcs;
       end-pr;
      // pre-load the formula
       dcl-pr int_FormulaLoad pointer;
         formula varchar(1000)  const;
         lRep    pointer       const;
       end-pr;
      // get string from argument
       dcl-pr int_FormulaExec varchar(32000);
         lArg      pointer const;
         curBuffer uns(3)  const options(*nopass);
       end-pr;
