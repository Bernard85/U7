       ctl-opt nomain option(*noshowcpy);
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,u7env_h
      /copy cpy,u7filter_h
      // --------------------------------------------------------------------
      // get item for filter family for Xml parser
      // --------------------------------------------------------------------
       dcl-proc filter_XmlInput export;
       dcl-pi filter_XmlInput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pi;
      //
       dcl-ds filters likeDs(tFilters) based(pFilters);
       dcl-ds filter  likeDs(tFilter) based(pFilter);
       dcl-ds omit    likeDs(tOmit) based(pOmit);
       if ND.ID='FILTERS';
         pFilters=tree_getnewitem(%addr(tFilters):%size(tFilters));
         filters.activated=xml_getAttAsBoolean('ACTIVATED':ND.atts);
         return pFilters;
       elseIf ND.ID='FILTER';
         pFilter=tree_getnewitem(%addr(tFilter):%size(tFilter));
         Filter.ID=xml_getAttAsString('ID':ND.atts);
         return pFilter;
       elseIf ND.ID='OMIT';
         pOmit=tree_getnewitem(%addr(tOmit):%size(tOmit));
         omit.ID=xml_getAttAsString('ID':ND.atts);
         return pOmit;
       endIf;
       return *null;
       end-proc;
      // --------------------------------------------------------------------
      // Set line for Xml parser from node on filter family
      // --------------------------------------------------------------------
       dcl-proc filter_XmlOutput export;
       dcl-pi filter_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pi;
      //
       dcl-ds ND      likeDs(xml_nodeDefine);
       dcl-ds filters likeds(tFilters) based(pFilters);
       dcl-ds filter  likeds(tFilter) based(pFilter);
       dcl-ds omit    likeds(tOmit) based(pOmit);
       clear ND;
       if tree_isofthekind(kFilters:lNode:pFilters);
         ND.ID='FILTERS';
         xml_setAttfromBoolean(ND.atts:'ACTIVATED':filters.activated);
       elseif tree_isofthekind(kFilter:lNode:pFilter);
         ND.ID='FILTER';
         xml_setAttfromString(ND.atts:'ID':filter.ID);
       elseif tree_isofthekind(kOmit:lNode:pOmit);
         ND.ID='OMIT';
         xml_setAttfromString(ND.atts:'ID':omit.ID);
       endIf;
       return ND;
       end-proc;
