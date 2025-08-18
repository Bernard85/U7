      // INDEX family
       dcl-c iIndex   'INDEX';
       dcl-c iElement 'ELEMENT';
       dcl-c kIndex   'I';
       dcl-c kElement 'E';
      // index template
       dcl-ds tIndex qualified;
         kind char(1) inz(kIndex);
       end-ds;
      // element template
       dcl-ds tElement qualified;
         kind char(1)     inz(kElement);
         ID   varchar(35);
         seq  uns(5)      inz(0);
         text varchar(50);
       end-ds;
      // get item for INDEX family
       dcl-pr index_XmlInput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pr;
      // Set item for INDEX family
       dcl-pr index_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pr;
      // Comparator
       dcl-pr index_comparator int(3);
         lElement1 pointer const;
         lElement2 pointer const;
       end-pr;
