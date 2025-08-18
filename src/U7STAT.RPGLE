       ctl-opt nomain option(*noshowcpy);
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,u7env_h
      /copy cpy,u7stat_h
      // --------------------------------------------------------------------
      // get item for STAT family for Xml parser
      // --------------------------------------------------------------------
       dcl-proc stat_XmlInput export;
       dcl-pi stat_XmlInput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pi;

       dcl-ds stats likeds(tStats) based(pStats);
       dcl-ds stat  likeds(tStat)  based(pStat);
       if ND.ID='STATS';
         pStats=tree_getnewitem(%addr(tStats):%size(tStats));
         return pStats;
       elseif ND.ID='STAT';
         pStat=tree_getnewitem(%addr(tStat):%size(tStat));
         stat.ID      =xml_getAttAsString('ID':ND.atts);
         stat.formula =xml_getAttAsString('FORMULA':ND.atts);
         stat.text    =ND.text;
         return pStat;
       endIf;
       return *null;
       end-proc;
