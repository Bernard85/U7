      // MENU family Identifiers
       dcl-c kMnu  'm';
       dcl-c kCmd  'c';
      // MENU data structures
       dcl-ds tMnu qualified;
         kind char(1)     inz(kMnu);
         text varchar(50);
       end-ds;
       dcl-ds tCmd qualified;
         kind  char(1)     inz(kCmd);
         text  varchar(50);
         order varchar(80);
       end-ds;
      // get item from xml for MENU family
       dcl-pr mnu_XmlInput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pr;
      // Set line for Xml parser from node on MENU family
       dcl-pr mnu_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pr;
