      // -----------------------------------------------------------------------
      //  Journal family
      // -----------------------------------------------------------------------
       dcl-c kJournal  'J';
       dcl-c kEntries  'E';
       dcl-c kSection  'S';
       dcl-c kEntry    'e';
       dcl-c kSubEntry 's';
      // journal
       dcl-ds tJournal qualified;
         kind char(1)     inz(kJournal);
         ID   varchar(15);
         text varchar(50) inz('') ;
       end-ds;
      // Entries
       dcl-ds tEntries qualified;
         kind char(1) inz(kEntries);
       end-ds;
      // Section
       dcl-ds tSection qualified;
         kind char(1)     inz(kSection);
         text varchar(50) inz('') ;
       end-ds;
      // entry
       dcl-ds tJrnEntry extname('JRNENTRY') qualified;
       end-ds;
       dcl-ds tEntry    qualified;
         kind    char(1) inz(kEntry);
         pEntry0 pointer inz(*null);
         det            likeDs(tJrnEntry);
         lXView  pointer inz(*null);
         lYView  pointer inz(*null);
       end-ds;
      // sub-entry
       dcl-ds tSubEntry qualified;
         kind   char(1)     inz(kSubEntry);
         fmtID  varchar(10);
         pos    uns(5)      inz(0);
         lXView pointer     inz(*null);
         lYView pointer     inz(*null);
       end-ds;
      // get item from JOURNAL family
       dcl-pr jrn_XMLinput pointer;
         ND likeDs(xml_nodeDefine) const;
       end-pr;
      // Set line for Xml parser from node on journal family
       dcl-pr jrn_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pr;
      // link entries
       dcl-pr jrn_tieEntries;
         lEntries pointer const;
       end-pr;
