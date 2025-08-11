      // Retrieve journal entries
       dcl-pr RtvJrnE ExtProc('QjoRetrieveJournalEntries');
         RjRcvVar    char(32767) Options(*VarSize );
         RjRcvVarLen int(10)     Const;
         RjJrnNamQ   char(20)    Const;
         RjRcvInfFmt char(8)     Const;
         RjSltInf    char(32767) Const  Options(*NoPass: *VarSize );
         RjError     char(32767) Options(*NoPass: *VarSize );
       end-pr;
      // Delete pointer handle:
       dcl-pr DltPtrHdl ExtProc('QjoDeletePointerHandle' );
         DhPtrHdl uns(10)     Const;
         DhError  char(32767) Options(*NoPass: *VarSize );
       end-pr;
      // -------------------------------------------------------------------
      // ds for
      // -------------------------------------------------------------------
      // Object
       dcl-ds tObj qualified template;
         ID  char(10);
         LIB char(10);
       end-ds;
      // Files
       dcl-ds tFiles$ qualified template;
         nbr uns(5);
         ofs uns(5) dim(500);
       end-ds;
      // File
       dcl-ds tFile$ qualified template;
         *n  uns(5)  ;
         ID  char(10);
         LIB char(10);
         mbr char(10);
       end-ds;
      // File
       dcl-ds File$ likeds(tfile$) based(pFile$);
      // job
       dcl-ds tJob qualified template;
         ID   char(10);
         user char(10);
         no   char(6) ;
       end-ds;
      // timestamp
       dcl-ds tZ qualified template;
         x uns(5) ;
         d char(7);
         t char(6);
       end-ds;
       dcl-ds tRcvRng qualified template;
         nbr  uns(5);
         Rcv1       likeDs(tObj);
         Rcv2       likeDs(tObj);
       end-ds;
      // entry type
       dcl-ds tTypes qualified template;
         nbr uns(5) ;
         id  char(2) dim(300);
       end-ds;
      // various
       dcl-s idx uns(5);
      // Retrieve journal header
       dcl-ds JH qualified;
         BytRtn    int(10)    ;
         OfsEH     int(10)    ;
         NbrEntRtv int(10)    ;
         ConInd    char(1)    ;
         ConRcv    char(10)   ;
         ConLib    char(10)   ;
         ConSeqNbr zoned(20:0);
         *n        char(11)   ;
         Data      char(32754);
       end-ds;
      // Entry header:
       dcl-ds EH Based(pEH) qualified;
         OfsHdrJrnE  uns(10) ;
         OfsNulValI  uns(10) ;
         OfsEntDta   uns(10) ;
         OfsTrnId    uns(10) ;
         OfsLglUoW   uns(10) ;
         OfsRcvInf   uns(10) ;
         SeqNbr      uns(20) ;
         TimStpC     char(8) ;
         ThrId       uns(20) ;
         SysSeqNbr   uns(20) ;
         CntRrn      uns(20) ;
         CmtCclId    uns(20) ;
         PtrHdl      uns(10) ;
         RmtPort     uns(5)  ;
         ArmNbr      uns(5)  ;
         PgmLibAsp   uns(5)  ;
         RmtAdr      char(16);
         JrnCde      char(1) ;
         EntTyp      char(2) ;
         JobNam      char(10);
         UsrNam      char(10);
         JobNbr      char(6) ;
         PgmNam      char(10);
         PgmLib      char(10);
         PgmLibAspDv char(10);
         objNam      char(10);
         objLib      char(10);
         FILmbr      char(10);
         UsrPrf      char(10);
         JrnId       char(10);
         AdrFam      char(1) ;
         SysNam      char(8) ;
         IndFlg      char(1) ;
         ObjNamInd   char(1) ;
         BitFld      char(1) ;
         Rsv         char(9) ;
       end-ds;
      // journal entry data
       dcl-ds ED Based(pED) qualified;
         DtaLen zoned(5:0) ;
         *n     char(11)   ;
         val    char(65535);
       end-ds;
      // criter
       dcl-ds JrnEntRtv;
         JeNbrVarRcd int(10);
       end-ds;
      // RCVRNG - *CURRENT, *CURCHAIN
       dcl-ds JV01 qualified;
         len    int(10) Inz(%Size(JV01));
         key    int(10) Inz(1);
         DtaLen int(10) Inz(40);
         Rcv1   char(10);
         lib1   char(10);
         Rcv2   char(10);
         Lib2   char(10);
       end-ds;
      // FROMENT - *FIRST
       dcl-ds JV02 qualified;
         Len    int(10)  Inz(%Size(JV02));
         key    int(10)  Inz(2);
         dtaLen int(10)  Inz(20);
         dta    char(20) Inz('*FIRST');
       end-ds;
      // FROMTIME
       dcl-ds JV03 qualified;
         len    int(10)  Inz(%Size(JV03));
         key    int(10)  Inz(3);
         dtaLen int(10)  Inz(26);
         dta    char(26);
       end-ds;
      // TOENT - *LAST
       dcl-ds JV04 qualified;
         len    int(10)  Inz(%Size(JV04));
         key    int(10)  Inz(4);
         DtaLen int(10)  Inz(20);
         dta    char(20) Inz('*LAST');
       end-ds;
      // TOTIME
       dcl-ds JV05 qualified;
         len    int(10)  Inz(%Size(JV05));
         key    int(10)  Inz(5);
         DtaLen int(10)  Inz(26);
         Dta    char(26);
       end-ds;
      // NBRENT
       dcl-ds JV06 qualified;
         Len    int(10) Inz(%Size(JV06));
         key    int(10) Inz(6);
         DtaLen int(10) Inz(%Size(4));
         Dta    int(10) Inz(1000);
       end-ds;
      // Entry type
       dcl-ds JV08 qualified;
         len    int(10)  Inz(%Size(JV08));
         key    int(10)  Inz(8);
         dtaLen int(10)  Inz(164);
         nbrTyp int(10) ;
         typ    char(10) Dim(16);
       end-ds;
      // JOB - *ALL
       dcl-ds JV09 qualified;
         len    int(10)  Inz(%Size(JV09));
         key    int(10)  Inz(9);
         dtaLen int(10)  Inz(26);
         dta    char(26) Inz('*ALL');
       end-ds;
      // PGM - *ALL
       dcl-ds JV10 qualified;
         len    int(10)  Inz(%Size(JV10));
         key    int(10)  Inz(10);
         dtaLen int(10)  Inz(10);
         dta    char(10) Inz('*ALL');
       end-ds;
      // USRPRF * *ALL
       dcl-ds JV11 qualified;
         len    int(10)  Inz(%Size(JV11));
         key    int(10)  Inz(11);
         dtaLen int(10)  Inz(10);
         dta    char(10) Inz('*ALL');
       end-ds;
      // FILE - *ALLFILE, *ALL
       dcl-ds JV16 qualified;
         len       int(10) Inz(%Size(JV16));
         key       int(10) Inz(16);
         dtaLen    int(10) Inz(484);
         JcNbrFil  int(10);
         JcFilNamQ char(30) Dim(16);
       end-ds;
