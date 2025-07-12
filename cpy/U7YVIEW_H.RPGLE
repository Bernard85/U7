      // View
       dcl-c kYView 'y';
       dcl-ds tYView qualified;
         kind   char(1)     inz(kYView);
         ID     varchar(10);
         lFmt   pointer    ;
         lForm  pointer    ;
         armTop            likeds(tArm);
         armBot            likeds(tArm);
       end-ds;

       dcl-ds tArm qualified;
         lVariant pointer inz(*null);
         segment  uns(5)  inz(0);
         most     ind     inz(*off);
       end-ds;
      // get vertical View
       dcl-pr yview_getYView pointer;
         lYViews pointer    ;
         lForms  pointer    ;
         lFmts   pointer    ;
         ID      varchar(10) const ;
         fAppli  char(1)     const options(*nopass);
       end-pr;
