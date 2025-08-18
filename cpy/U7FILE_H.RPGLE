      // FILE family
       dcl-c kFiles 'F';
       dcl-c kFile  'f';
      *
       dcl-ds tFiles qualified;
         kind char(1) inz(kFiles);
       end-ds;
       dcl-ds tFile qualified;
         kind   char(1)     inz(kFile);
         ID     varchar(10);
         format varchar(10);
         text   varchar(50);
       end-ds;
      // get item for FILE family from xml
       dcl-pr file_XmlInput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pr;
      // Set line for Xml parser from node on FILE family
       dcl-pr file_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pr;
      // get file
       dcl-pr file_getFile pointer;
         lFiles pointer    ;
         fileID varchar(10) const ;
       end-pr;
