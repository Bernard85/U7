      // GRID family
       dcl-c kGrid    'G';
       dcl-c kSubGrid 'S';
       dcl-c kColumn  'c';
      // grid
       dcl-ds tGrid qualified;
         kind    char(1)     inz(kGrid);
         ID      varchar(10);
         text    char(50)   ;
         change  ind        ;
         lFormat pointer     inz(*null);
       end-ds;
      // sub-grid
       dcl-ds tSubGrid qualified;
         kind char(1)     inz(kSubGrid);
         ID   varchar(10);
       end-ds;
      // column
       dcl-ds tColumn qualified;
         kind     char(1)     inz(kColumn);
         id       varchar(10);
         seq      uns(5)     ;
         edtWidth uns(5)     ;
         hdrfit   uns(3)     ;
         hdrWidth uns(5)     ;
         maxWidth uns(5)     ;
         hdr1     varchar(30);
         formula  varchar(50);
         text     varchar(50);
         lFormula pointer    ;
         pos      uns(3)     ;
       end-ds;
      // get item from GRID family
       dcl-pr grid_XMLinput pointer;
         ND const likeDs(xml_nodeDefine);
       end-pr;
      // set line for Xml parser from node
       dcl-pr grid_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pr;
      // get grid from list
       dcl-pr grid_getGrid pointer;
         lgrids pointer    ;
         gridID varchar(10) const ;
         fAppli char(1)     const options(*nopass);
       end-pr;
