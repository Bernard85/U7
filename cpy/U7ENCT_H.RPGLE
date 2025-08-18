      // Journal entry family
       dcl-c kJrnEnCt 'E';
       dcl-c kJeCode  'c';
       dcl-c kJeType  't';
      *
       dcl-ds tJrnEnCt qualified;
         kind char(1)     inz(kJrnEnCt);
         text varchar(50);
       end-ds;
       dcl-ds tJeCode qualified;
         kind char(1)     inz(kJeCode);
         ID   varchar(1) ;
         text varchar(50);
       end-ds;
       dcl-ds tJeType qualified;
         kind     char(1)     inz(kJeType);
         ID       varchar(2) ;
         formatID varchar(10);
         text     varchar(50);
       end-ds;
      // get item form JOURNAL ENTRY code/type  family
       dcl-pr enct_XMLinput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pr;
