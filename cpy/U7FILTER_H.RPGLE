      // FILTER family
       dcl-c kFilters 'F';
       dcl-c kFilter  'f';
       dcl-c kOmit    'o';
      *
       dcl-ds tFilters qualified;
         kind      char(1) inz(kFilters);
         activated ind     inz(*off);
       end-ds;
       dcl-ds tFilter qualified;
         kind char(1)     inz(kFilter);
         ID   varchar(10) inz('') ;
         lFormula pointer inz(*null);
       end-ds;
       dcl-ds tOmit qualified;
         kind char(1)     inz(kOmit);
         ID   varchar(30) inz('') ;
       end-ds;
      // get item for FILTER family from xml
       dcl-pr filter_XmlInput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pr;
      // Set line for Xml parser from node on FILE family
       dcl-pr filter_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pr;
