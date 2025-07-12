     hoption(*noshowcpy) nomain

      /copy cpy,u7ifs_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,u7fmt_h
      /copy cpy,u7int_h
      // -----------------------------------------------------------------------
      // specific variables
      // -----------------------------------------------------------------------
       dcl-s lProcs pointer;
      // -----------------------------------------------------------------------
      // Check if string is displayable
      // -----------------------------------------------------------------------
       dcl-proc  int_chkDisplay export;
       dcl-pi int_chkDisplay varchar(65535);
         c  varchar(256)    const;
         s_ varchar(65535)  const;
       end-pi;
      *
       dcl-s s varchar(65535);
       dcl-s p uns(5);
       s=s_;
       p=%check(c:s);
       dow p>0;
         %subst(s:p:1)='?';
         p=%check(c:s:p);
       endDo;
       return s;
       end-proc;
      // -----------------------------------------------------------------------
      // Populate string with variables
      // -----------------------------------------------------------------------
       dcl-proc int_replaceAll export;
       dcl-pi int_replaceAll varchar(255);
         source varchar(255) const;
         v1     varchar(255) const  options(*nopass);
         v2     varchar(255) const  options(*nopass);
         v3     varchar(255) const  options(*nopass);
         v4     varchar(255) const  options(*nopass);
         v5     varchar(255) const  options(*nopass);
         v6     varchar(255) const  options(*nopass);
         v7     varchar(255) const  options(*nopass);
         v8     varchar(255) const  options(*nopass);
       end-pi;
      *
       dcl-s i      uns(3);
       dcl-s v      varchar(255) dim(8);
       dcl-s result varchar(255);
       if %parms()>=2;
        v(1)=v1;
       endif;
       if %parms()>=3;
        v(2)=v2;
       endif;
       if %parms()>=4;
        v(3)=v3;
       endif;
       if %parms()>=5;
        v(4)=v4;
       endif;
       if %parms()>=6;
        v(5)=v5;
       endif;
       if %parms()>=7;
        v(6)=v6;
       endif;
       if %parms()>=8;
        v(7)=v7;
       endif;
       if %parms()>=9;
        v(8)=v8;
       endif;
       result=source;
       for i=1 to %parms()-1;
         result=%scanRpl('%'+%char(i):v(i):result);
       endFor;
       return result;
       end-proc;
      // -----------------------------------------------------------------------
      // get string from field
      // -----------------------------------------------------------------------
       dcl-proc int_getpStrFromField export;
       dcl-pi int_getpStrFromField pointer;
         lField  pointer const;
         pBuffer pointer const;
         owned   ind;
         length  uns(5);
       end-pi;
      *
       dcl-ds field likeDs(tField) based(pField);
       dcl-s pStr pointer;
       pField=tree_getItem(lField);
       if pBuffer=*null;
         pStr=int_allocString(
              int_replaceAll('For the field "%1" buffer is empty'
                                :field.ID):owned:length);
         return pStr;
       endIf;
       If %scan(field.type:'AOZLT')>0;
         owned=*off;
         length=field.len;
         return pBuffer+field.posinbuffer;
       elseIf %scan(field.type:'PS')>0;
         pStr=int_allocString(int_editNumeric(pBuffer:field):owned:length);
       elseIf field.type='B';
         pStr=int_allocString(int_editInteger(pBuffer:field):owned:length);
       else;
         pStr=int_allocString(
          int_replaceAll('Type "%1" of the field "%2" is not supported'
                         :field.type:field.ID):owned:length);
       endIf;
       return pStr;
       end-proc;
      // -----------------------------------------------------------------------
      //  Alloc string
      // -----------------------------------------------------------------------
       dcl-proc  Int_allocString export;
       dcl-pi int_allocString pointer;
         String varchar(2048) const;
         owned  ind;
         len    uns(5);
       end-pi;
      *
       dcl-s p pointer;
        len=%len(String)+1;
        p=%alloc(len);
        %str(p:len)=string;
        owned=*on;
        return p;
       end-proc;
      // -----------------------------------------------------------------------
      // edit numeric
      // -----------------------------------------------------------------------
       dcl-proc int_editNumeric export;
       dcl-pi int_editNumeric varchar(32);
         pBuffer pointer const;
         field          const likeDs(tField);
       end-pi;
      *
       dcl-s w30s9 zoned(30:9)  inz(0);
       dcl-s w30p9 packed(30:9) inz(0);
       if field.type='S';
       ifs_memcpy(%addr(w30s9)+30-field.len:pBuffer+field.posinbuffer
                                           :field.len);
       else;
       ifs_memcpy(%addr(w30p9)+16-field.len:pBuffer+field.posinbuffer
                                           :field.len);
         w30s9=w30p9;
       endIf;
       return int_editNumeric2(w30s9:field);
       end-proc;
      // -----------------------------------------------------------------------
      // edit numeric 2
      // -----------------------------------------------------------------------
       dcl-proc int_editNumeric2;
       dcl-pi int_editNumeric2 varchar(32);
         w30s9 zoned(30:9) value;
         field            const likeds(tField);
       end-pi;
      *
       dcl-s val varchar(32);
       dcl-s p   uns(3);
       dcl-s p1  uns(3);
       dcl-s l   uns(3);
       for p=1 to 9-field.dec;
         w30s9*=10;
       endFor;
       val=%editc(w30s9:'P');
       p=%scan('.':val);
       p1=p-field.digits+field.dec-1;
       l=1+field.digits+%int(field.dec>0);
       val=%subst(val:p1:l);
       return val;
       end-proc;
      // -----------------------------------------------------------------------
      // edit integer
      // -----------------------------------------------------------------------
       dcl-proc int_editInteger export;
       dcl-pi int_editInteger varchar(32);
         pBuffer pointer const;
         field          const likeDs(tField);
       end-pi;
      *
       dcl-s int2 int(5)  inz(0);
       dcl-s int4 int(10) inz(0);
       dcl-s int8 int(20) inz(0);
       if field.len=2;
         ifs_memcpy(%addr(Int2):pBuffer+field.posinbuffer:2);
         return %char(int2);
       elseif field.len=4;
         ifs_memcpy(%addr(Int4):pBuffer+field.posinbuffer:4);
         return %editc(%dec(int4:9:0):'Q');
       elseif field.len=8;
         ifs_memcpy(%addr(Int8):pBuffer+field.posinbuffer:8);
         return %char(int8);
       endif;
       end-proc;
      // -----------------------------------------------------------------------
      // get minus of 2 values
      // -----------------------------------------------------------------------
       dcl-proc  int_getMin export;
       dcl-pi int_getMin uns(5);
         v1 uns(5) const;
         v2 uns(5) const;
       end-pi;
       if v1<v2;
         return v1;
       else;
         return v2;
       endif;
       end-proc;
      // -----------------------------------------------------------------------
      // Complete with space/dot at left
      // -----------------------------------------------------------------------
       dcl-proc int_AddSpaceDot export;
       dcl-pi int_AddSpaceDot varchar(255);
         source  varchar(255) const;
         lastPos uns(3)       const;
       end-pi;
      *
       dcl-s dest  varchar(255);
       dcl-s xText char(255)    inz(*all' .');
       if source='';
         return '';
       endif;
       dest=source;
       if %len(source)>lastPos;
         return %subst(source:1:lastPos);
       endIf;
       %subst(xText:1:%len(dest))=dest;
       return %subst(xText:1:lastPos);
       end-proc;
      // -----------------------------------------------------------------------
      // Scan from Right
      // -----------------------------------------------------------------------
       dcl-proc  int_ScanR export;
       dcl-pi int_ScanR uns(3);
         charFound varchar(10)  const;
         String    varchar(255) const;
         fromPos_  uns(3)       const options(*nopass);
       end-pi;
      *
       dcl-s fromPos uns(3);
       dcl-s p       uns(3);
       if %parms()=3;
         fromPos=fromPos_;
       else;
         fromPos=%len(String);
       endIf;
       for p=fromPos-%len(charFound)+1 downto 1;
         if %subst(String:p:%len(charFound))=CharFound;
           return p;
         endIf;
       endFor;
       return 0;
       end-proc;
      // -----------------------------------------------------------------------
      // load procedures
      // -----------------------------------------------------------------------
       dcl-proc  int_LoadProcs export;
       dcl-pi int_loadProcs;
       end-pi;
       lProcs=tree_getnewlink(*null);
       int_loadProc(lProcs:'TODAY' :%pAddr(today));
       int_loadProc(lProcs:'CONCAT':%pAddr(concat));
       int_loadProc(lProcs:'%TRIM' :%pAddr(trim));
       int_loadProc(lProcs:'FORMAT' :%pAddr(format));
       end-proc;
      // -----------------------------------------------------------------------
      // load procedure
      // -----------------------------------------------------------------------
       dcl-proc  int_LoadProc;
       dcl-pi int_loadProc;
         lProcs pointer;
         ID     varchar(35)     const;
         pAddr  pointer(*proc)  const;
       end-pi;
      *
       dcl-ds proc likeDs(tProc) based(pProc);
       pProc=tree_getNewItem(%addr(tProc):%size(tProc));
       Proc.ID=ID;
       proc.pAddr=pAddr;
       tree_linktoParent(lProcs:tree_getNewLink(pProc));
       end-proc;
      // -----------------------------------------------------------------------
      // pre-load the formula
      // -----------------------------------------------------------------------
       dcl-proc  int_FormulaLoad export;
       dcl-pi int_FormulaLoad pointer;
         formula_ varchar(1000)  const;
         lRep     pointer       const;
       end-pi;
      *
       dcl-s lArg    pointer;
       dcl-s p       uns(5);
       dcl-s formula char(1000);
       // the formula is empty ?
       if formula_='';
         return *null;
       endif;
       formula=formula_+' ';
       p=%check(' ':formula:1);
       if %scan(%subst(formula:p:1):min+maj+num+spec+'''')=0;
           return int_getNewlErr(
           'the first character is unexpected.');
       endif;
       lArg=int_getArg(formula:p:lRep);
       if tree_isofthekind(kErr:lArg) or p=0;
         return lArg;
       endif;
       p=%check(' ':formula:p);
       if p>0;
           return int_getNewlErr(
           'Unexpected character is found.');
       endif;
       return lArg;
       end-proc;
      // -----------------------------------------------------------------------
      // get argument
      // -----------------------------------------------------------------------
       dcl-proc  int_getArg;
       dcl-pi int_getArg pointer;
         formula varchar(1000)  const;
         p       uns(5);
         lRep    pointer       const;
       end-pi;
      *
       dcl-s lArg pointer;
       lArg=int_getArg2(formula:p:lRep);
       if tree_isofthekind(kErr:lArg) or p=0;
         return lArg;
       endif;
       //
       p=%check(' ':formula:p);
       if p>0 and %subst(formula:p:1)='+';
         return int_plus(lArg:formula:p:lRep);
       endIf;
       return larg;
       end-proc;
      // -----------------------------------------------------------------------
      // get argument (part 2)
      // -----------------------------------------------------------------------
       dcl-proc  int_getArg2;
       dcl-pi int_getArg2 pointer;
         formula varchar(1000)  const;
         p       uns(5);
         lRep    pointer       const;
       end-pi;
      *
       dcl-s p1      uns(5);
       dcl-s p2      uns(5);
       dcl-s p3      uns(5);
       dcl-s keyWord varchar(50);
       // search for the next filled position
       p1=%check(' ':formula:p);
       if %subst(formula:p1:1)='''';
         p=p1;
         return int_getConst(formula:p);
       endif;
       // search for the next no meaning position
       p2=%check(min+maj+num+spec:formula:p1);
       // get the key word
       keyWord=%subst(formula:p1:p2-p1);
       // put the keyword on uppercase
       keyWord=%xlate(min:maj:keyWord);
       // get the next charactere
       p3=%check(' ':formula:p2);
       if p3>0 and %subst(formula:p3:1)='(';
         p=p3+1;
         return int_getProc(keyWord:formula:p:lRep);
       else;
         p=p3;
         return int_getField(keyWord:p:lRep);
       endIf;
       end-proc;
      // -----------------------------------------------------------------------
      // get the field
      // -----------------------------------------------------------------------
       dcl-proc  int_getField;
       dcl-pi int_getField pointer;
         keyword varchar(50) const;
         p       uns(5);
         lRep    pointer     const;
       end-pi;
      *
       dcl-s lFmt    pointer;
       dcl-s lFields pointer;
       dcl-s lField  pointer;
       if tree_isOftheKind(kFormats:lRep);
         lFmt=tree_getFirst(lRep);
         dow lFmt<>*null;
           lFields=tree_getLinkFromList(lFmt:kFields);
           lField=tree_getLinkFromList(lFields:kField:keyWord);
           if lField<>*null;
             return lField;
           endif;
           lFmt=tree_getNext(lFmt);
         endDo;
       elseif tree_isOftheKind(kFormat:lRep);
         lFields=tree_getLinkFromList(lRep:kFields);
         lField=tree_getLinkFromList(lFields:kField:keyWord);
         if lField<>*null;
           return lField;
         endif;
       endif;
       return int_getNewlErr('The field '+keyWord+' is not defined');
       end-proc;
      // -----------------------------------------------------------------------
      // get the procedure
      // -----------------------------------------------------------------------
       dcl-proc  int_getProc;
       dcl-pi int_getProc pointer;
         keyword varchar(50)   const;
         formula varchar(1000)  const;
         p       uns(5);
         lRep    pointer       const;
       end-pi;
      *
       dcl-s lProc pointer;
       lProc=tree_getLinkFromList(lProcs:kProc:keyWord);
       if lProc=*null;
         return int_getNewlErr('The procedure '+keyWord+' is not defined');
       endIf;
       p=%check(' ':formula:p);
       // procedure without arguments
       if p>0 and %subst(formula:p:1)=')';
         p+=1;
         return lProc;
       endIf;
       // create a link to tie arguments
       return int_getArgs(lProc:formula:p:lRep);
       end-proc;
      // -----------------------------------------------------------------------
      // get the arguments of the procedure
      // -----------------------------------------------------------------------
       dcl-proc  int_getArgs;
       dcl-pi int_getArgs pointer;
         lProc$  pointer       const;
         formula varchar(1000)  const;
         p       uns(5);
         lRep    pointer       const;
       end-pi;
      *
       dcl-s lProc pointer;
       dcl-s lArg  pointer;
       lProc=tree_getNewLink(lProc$);
       dou p=0 or %subst(formula:p:1)<>':';
         p=%check(':':formula:p);
         lArg=int_getArg(formula:p:lRep);
         if tree_isOfTheKind(kErr:lArg);
           return lArg;
         elseif tree_isOfTheKind(klink:lArg);
           tree_linktoparent(lProc:lArg);
         else;
           tree_linktoparent(lProc:tree_getNewLink(lArg));
         endIf;
         p=%check(' ':formula:p);
       endDo;
       if p=0 or %subst(formula:p:1)<>')';
           return int_getNewlErr(
           'A right parenthesis is expected but is not found.');
       endif;
       p+=1;
       return lProc;
       end-proc;
      // -----------------------------------------------------------------------
      // concat arguments (triggered by plus)
      // -----------------------------------------------------------------------
       dcl-proc  int_plus;
       dcl-pi int_plus pointer;
         lArg1   pointer       const;
         formula varchar(1000)  const;
         p       uns(5);
         lRep    pointer       const;
       end-pi;
      *
       dcl-s lPlus pointer;
       dcl-s lArg  pointer;
       lPlus=tree_getNewLink(tree_getLinkFromList(lProcs:kProc:'CONCAT'));
         if tree_isOfTheKind(klink:lArg1);
           tree_linktoparent(lPlus:lArg1);
         else;
           tree_linktoparent(lPlus:tree_getNewLink(lArg1));
         endIf;
       dou p=0 or %subst(formula:p:1)<>'+';
         p=%check('+ ':formula:p);
         if p=0;
           return int_getNewlErr(
           'An argument is expected but not found.');
         endif;
         lArg=int_getArgPlus(formula:p:lRep);
         if tree_isOfTheKind(kErr:lArg);
           return lArg;
         elseif tree_isOfTheKind(klink:lArg);
           tree_linktoparent(lPlus:lArg);
         else;
           tree_linktoparent(lPlus:tree_getNewLink(lArg));
         endIf;
       endDo;
       return lPlus;
       end-proc;
      // -----------------------------------------------------------------------
      // get argument in plus context
      // -----------------------------------------------------------------------
       dcl-proc  int_getArgPlus;
       dcl-pi int_getArgPlus pointer;
         formula varchar(1000)  const;
         p       uns(5);
         lRep    pointer       const;
       end-pi;
      *
       dcl-s lArg pointer;
       lArg=int_getArg2(formula:p:lRep);
       if tree_isofthekind(kErr:lArg) or p=0;
         return lArg;
       endif;
       //
       p=%check(' ':formula:p);
       return larg;
       end-proc;
      // -----------------------------------------------------------------------
      // get const
      // -----------------------------------------------------------------------
       dcl-proc  int_getConst;
       dcl-pi int_getConst pointer;
         formula varchar(1000)  const;
         p       uns(5);
       end-pi;
      *
       dcl-s Str varchar(2048);
       dcl-s p1  uns(5);
       dcl-s p2  uns(5);
       p1=p+1;
       dow 1=1;
         p2=%scan('''':formula:p1);
         if p2=0;
           return int_getNewlErr('missing trailing apostrophe (pos='+
                                  %char(p)+')');
         endif;
         str+=%subst(formula:p1:p2-p1);
         if %subst(formula:p2:2)='''''';
           str+='''';
           p1=p2+2;
           iter;
         endif;
         leave;
       enddo;
       p=p2+1;
       return int_getNewlCst(str);
       end-proc;
      // -----------------------------------------------------------------------
      //  create a new error
      // -----------------------------------------------------------------------
       dcl-proc int_getNewlErr;
       dcl-pi int_getNewlErr pointer;
         Str varchar(2048) const;
       end-pi;
      *
       dcl-ds err likeDs(tErr) based(pErr);
       pErr=tree_getNewItem(%addr(tErr):%size(tErr));
       err.pStr=int_allocStr(str);
       return tree_getNewLink(pErr);
       end-proc;
      // -----------------------------------------------------------------------
      //  create a new constant
      // -----------------------------------------------------------------------
       dcl-proc int_getNewlCst;
       dcl-pi int_getNewlCst pointer;
         Str varchar(2048) const;
       end-pi;
      *
       dcl-ds cst likeDs(tCst) based(pCst);
       pCst=tree_getNewItem(%addr(tCst):%size(tCst));
       cst.pStr=int_allocStr(str);
       return tree_getNewLink(pCst);
       end-proc;
      // -----------------------------------------------------------------------
      //  Alloc string
      // -----------------------------------------------------------------------
       dcl-proc  int_allocStr;
       dcl-pi int_allocStr pointer;
         Str varchar(2048) const;
       end-pi;
      *
       dcl-s pStr pointer;
       dcl-s len  uns(5);
       len=%len(Str)+1;
       pStr=%alloc(len);
       %str(pStr:len)=str;
       return pStr;
       end-proc;
      // -----------------------------------------------------------------------
      // get string from argument
      // -----------------------------------------------------------------------
       dcl-proc  int_FormulaExec export;
       dcl-pi int_FormulaExec varchar(32000);
         lArg      pointer const;
         curBuffer uns(3)  const options(*nopass);
       end-pi;
      *
       dcl-s lArg$ pointer;
       dcl-ds field likeDS(tField) based(pField);
       dcl-ds fmt   likeDS(tFormat) based(pFmt);
       dcl-ds err   likeDS(tErr) based(pErr);
       dcl-ds cst   likeDS(tCst) based(pCst);
       dcl-ds proc  likeDS(tProc) based(pProc);
       dcl-s String  varchar(32000)  inz('?');
       dcl-s buffer  char(32000)    based(pBuffer);
       dcl-s pBuffer pointer;
      // procedure                                                          -
       dcl-pr procexe varchar(32000)  extproc(proc.pAddr);
         *n pointer options(*nopass) const;
       end-pr;
       // the item/link is a link?take it as argument
       if not tree_isOfTheKind(kLink:lArg:lArg$);
         lArg$=lArg;
       endIf;
       // get the value from the kind of item
       if tree_isOfTheKind(kField:lArg$:pField);
         // field
         pFmt=tree_getItem(tree_getParent(tree_getParent(lArg$)));
         //
         if %parms()=1;
           pBuffer=fmt.pBuffer1;
         elseif curBuffer=1;
           pBuffer=fmt.pBuffer1;
         else;
           pBuffer=fmt.pBuffer0;
         endIf;
         //
         if %scan(field.type:'AOZLT')>0;
           String=%subst(buffer:field.posInBuffer+1:field.len);
         elseif %scan(field.type:'PS')>0;
           String=int_editNumeric(pBuffer:field);
         elseIf field.type='B';
           String=int_editInteger(pBuffer:field);
         elseIf field.type='V';
           ifs_memcpy(%addr(string):pBuffer+field.posInBuffer:field.len);
         endIf;
         return String;
       elseif tree_isOfTheKind(kErr:lArg$:pErr);
         // error
         String=%str(err.pStr);
         return String;
       elseif tree_isOfTheKind(kCst:lArg$:pCst);
         // constante
         String=%str(cst.pStr);
         return String;
       elseif tree_isOfTheKind(kProc:lArg$:pProc);
         // procedure
         String=procexe(lArg);
         return String;
       else;
         return '';
       endIf;
       end-proc;
      // -----------------------------------------------------------------------
      // get today date
      // -----------------------------------------------------------------------
       dcl-proc  today;
       dcl-pi today varchar(32000);
         lArgs pointer options(*nopass) const;
       end-pi;
      *
       dcl-s str varchar(32000);
       str=%char(%date());
       return str;
       end-proc;
      // -----------------------------------------------------------------------
      // concatenation
      // -----------------------------------------------------------------------
       dcl-proc  Concat;
       dcl-pi concat varchar(32000);
         lArgs pointer options(*nopass) const;
       end-pi;
      *
       dcl-s string varchar(32000);
       dcl-s lArg   pointer;
       lArg=tree_getFirst(lArgs);
       dow lArg<>*null;
         ///String+=%trim(int_FormulaExec(lArg));
         String+=int_FormulaExec(lArg);
         lArg=tree_getNext(lArg);
       endDo;
       return string;
       end-proc;
      // -----------------------------------------------------------------------
      // trim
      // -----------------------------------------------------------------------
       dcl-proc  Trim;
       dcl-pi trim varchar(32000);
         lArgs pointer options(*nopass) const;
       end-pi;
      *
       dcl-s string varchar(32000);
       dcl-s lArg   pointer;
      *
       lArg=tree_getFirst(lArgs);
       String=int_FormulaExec(lArg);
       string=%trim(string);
       return string;
       end-proc;
      // -----------------------------------------------------------------------
      // format
      // -----------------------------------------------------------------------
       dcl-proc  Format;
       dcl-pi format varchar(32000);
         lArgs pointer options(*nopass) const;
       end-pi;
      *
       dcl-s expression varchar(32000);
       dcl-s variable   varchar(32000);
       dcl-s lArg       pointer;
       dcl-s n          uns(3)         inz(0);
      *
       lArg=tree_getFirst(lArgs);
       Expression=int_FormulaExec(lArg);
       //
       lArg=tree_getNext(lArg);
       dow lArg<>*null;
         n+=1;
         variable=int_FormulaExec(lArg);
         expression=%scanrpl('&'+%char(n):%trim(variable):expression);
         lArg=tree_getNext(lArg);
       endDo;
       return expression;
       end-proc;
