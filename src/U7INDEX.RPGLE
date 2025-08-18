       ctl-opt nomain option(*noshowcpy);
      /copy cpy,u7env_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,u7index_h
      // --------------------------------------------------------------------
      // get item for index family for Xml parser
      // --------------------------------------------------------------------
       dcl-proc index_XmlInput export;
       dcl-pi index_XmlInput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pi;

       dcl-ds index   likeds(tIndex) based(pIndex);
       dcl-ds element likeds(tElement) based(pElement);
       if ND.ID=iINDEX;
         pIndex=tree_getnewitem(%addr(tIndex):%size(tIndex));
         return pIndex;
       elseif ND.ID=iELEMENT;
         pElement=tree_getnewitem(%addr(tElement):%size(tElement));
         element.ID    =xml_getAttAsString ('ID' :ND.atts);
         element.Seq   =xml_getAttAsInteger('SEQ':ND.atts);
         return pElement;
       endIf;
       return *null;
       end-proc;
      // --------------------------------------------------------------------
      // Set line for Xml parser from node on index family
      // --------------------------------------------------------------------
       dcl-proc index_XmlOutput export;
       dcl-pi index_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pi;

       dcl-ds ND      likeDs(xml_nodeDefine);
       dcl-ds index   likeds(tIndex) based(pIndex);
       dcl-ds element likeds(tElement) based(pElement);
       clear ND;
       if tree_getKind(lNode)=kIndex;
         ND.ID=iINDEX;
         pIndex=tree_getItem(lNode);
       elseif tree_getKind(lNode)=kElement;
         pElement=tree_getItem(lNode);
         ///if Element.seq>0;
         ND.ID=iELEMENT;
         xml_setAttfromInteger(ND.atts:'SEQ':element.seq);
         xml_setAttfromString(ND.atts:'ID':element.ID);
         ///endIf;
       endIf;
       return ND;
       end-proc;
      // -----------------------------------------------------------------------
      // Comparator
      // -----------------------------------------------------------------------
       dcl-proc index_comparator export;
       dcl-pi index_comparator int(3);
         lElement1 pointer const;
         lElement2 pointer const;
       end-pi;

       dcl-ds element1 likeDs(tElement) based(pElement1);
       dcl-ds element2 likeDs(tElement) based(pElement2);

        pElement1=tree_GetItem(lElement1);
        pElement2=tree_GetItem(lElement2);
        // -1 1st is lower than 2nd element                                   --
        // +1 1st is greater than 2nd element                                 --
        // 0  they are equal                                                  --
        if     Element1.Seq>0 and Element2.Seq=0;
          return -1;
        elseif Element1.Seq=0 and Element2.Seq>0;
          return +1;
        elseif Element1.Seq<Element2.Seq;
          return -1;
        elseif Element1.Seq>Element2.Seq;
          return +1;
        elseif Element1.ID<Element2.ID;
          return -1;
        elseif Element1.ID>Element2.ID;
          return +1;
        endif;
        return 0;
       end-proc;
