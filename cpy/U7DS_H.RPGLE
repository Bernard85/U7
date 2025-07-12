      // DS for program
       dcl-ds PgmSts qualified psds;
         pgmID   char(10)  ;
         sts     zoned(5:0);
         prvsts  zoned(5:0);
         srcstmt char(8)   ;
         routine char(8)   ;
         parms   zoned(3:0);
         msgid   char(7)   ;
         mi      char(4)   ;
         work    char(30)  ;
         lib     char(10)  ;
         errdta  char(80)  ;
         rpgmsg  char(4)   ;
         Filler  char(69)  ;
         job     char(10)  ;
         user    char(10)  ;
         jobnum  zoned(5:0);
         runtime zoned(6:0);
       end-ds;
      *
       dcl-s pPgmID pointer  inz(%addr(pgmSts.pgmID));
       dcl-s pgmID  char(10) based(pPgmID);
      // DS for workstation
       dcl-ds wsDS qualified;
         kp         char(1)  pos(369);
         CsrFromRow uns(3)   pos(370);
         CsrFromCol uns(3)   pos(371);
       end-ds;
      // Api error
       dcl-ds tApiErr qualified template;
         BytPrv int(10)   inz(%size(tApiErr));
         BytAvl int(10)   inz(0);
         MsgID  char(7)  ;
         MsgDta char(112);
       end-ds;
       dcl-ds ApiErr likeDs(tApiErr);
      // sfl key words
       dcl-s sflDsp ind     based(pIN88);
       dcl-s pIN88  pointer inz(%addr(*IN88));
       dcl-s sflClr ind     based(pIN89);
       dcl-s pIN89  pointer inz(%addr(*IN89));
      // used on break
       dcl-c fStop     -1;
       dcl-c fContinue 1;
       dcl-c fBreak    0;
