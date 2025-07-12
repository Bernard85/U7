       ctl-opt nomain option(*noshowcpy);
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,u7env_h

      /copy cpy,u7grid_h
      // --------------------------------------------------------------------
      // get item for FILE family for Xml parser
      // --------------------------------------------------------------------
       dcl-proc grid_XmlInput export;
       dcl-pi grid_XmlInput pointer;
         ND const likeDs(xml_nodeDefine);
       end-pi;

       dcl-ds grid    likeds(tGrid)    based(pGrid);
       dcl-ds subGrid likeds(tSubGrid) based(pSubGrid);
       dcl-ds column  likeds(tColumn)  based(pColumn);
       if ND.ID='GRID';
         pGrid=tree_getnewitem(%addr(tGrid):%size(tGrid));
         grid.ID=xml_getAttAsString('ID':ND.atts);
         grid.text=ND.text;
         return pGrid;
       elseIf ND.ID='SUBGRID';
         pSubGrid=tree_getnewitem(%addr(tSubGrid):%size(tSubGrid));
         subGrid.ID=xml_getAttAsString('ID':ND.atts);
         return pSubGrid;
       elseIf ND.ID='COLUMN';
         pColumn=tree_getnewitem(%addr(tColumn):%size(tColumn));
         column.ID      =xml_getAttAsString ('ID':ND.atts);
         column.seq     =xml_getAttAsInteger('SEQ':ND.atts);
         column.text    =ND.text;
         column.formula =xml_getAttAsString ('FORMULA':ND.atts);
         column.edtWidth=xml_getAttAsInteger('EDTWIDTH':ND.atts);
         column.hdrWidth=xml_getAttAsInteger('HDRWIDTH':ND.atts);
         column.maxWidth=xml_getAttAsInteger('MAXWIDTH':ND.atts);
         column.hdrFit  =xml_getAttAsInteger('HDRFIT':ND.atts);
         column.hdr1    =xml_getAttAsString ('HDR1':ND.atts);
         return pColumn;
       endIf;
       return *null;
       end-proc;
      // --------------------------------------------------------------------
      // Set line for GRID family
      // --------------------------------------------------------------------
       dcl-proc grid_XmlOutput export;
       dcl-pi grid_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pi;

       dcl-ds ND      likeDs(xml_nodeDefine);
       dcl-ds grid    likeds(tGrid) based(pGrid);
       dcl-ds subGrid likeds(tSubGrid) based(pSubGrid);
       dcl-ds column  likeds(tColumn) based(pColumn);
       clear ND;
       if tree_isofthekind(kGrid:lNode:pGrid);
         ND.ID='GRID';
         xml_setAttfromString(ND.atts:'ID':grid.ID);
         ND.text=grid.text;
       elseIf tree_isofthekind(kSubGrid:lNode:pSubGrid);
         ND.ID='SUBGRID';
         xml_setAttfromString(ND.atts:'ID':subGrid.ID);
       elseIf tree_isofthekind(kColumn:lNode:pColumn);
         ND.ID='COLUMN';
         xml_setAttfromString (ND.atts:'ID':column.ID);
         xml_setAttfromInteger(ND.atts:'SEQ'     :column.seq);
         xml_setAttfromString (ND.atts:'FORMULA'  :column.formula);
         xml_setAttfromInteger(ND.atts:'EDTWIDTH':column.edtwidth);
         xml_setAttfromInteger(ND.atts:'HDRWIDTH':column.hdrwidth);
         xml_setAttfromInteger(ND.atts:'MAXWIDTH':column.maxwidth);
         xml_setAttfromInteger(ND.atts:'HDRFIT'  :column.hdrfit  );
         xml_setAttfromString (ND.atts:'HDR1'    :column.hdr1);
         ND.text=column.text;
       endIf;
       return ND;
       end-proc;
      // --------------------------------------------------------------------
      // get grid
      // --------------------------------------------------------------------
       dcl-proc  grid_getgrid export;
       dcl-pi grid_getgrid pointer;
         lGrids pointer;
         gridID varchar(10) const;
         fAppli char(1)     const options(*nopass);
       end-pi;

       dcl-s lGrid pointer inz(*null);
       if lGrids=*null;
         lGrids=tree_getnewlink(*null);
       endif;
       lGrid=tree_getLinkFromList(lGrids:kGrid:gridID);
       if lGrid=*null;
         if %parms()=%parmNum(fAppli) and fAppli='Y';
           lGrid=xml_xml2tree(env_getAppliPath()+'3fg/'+GridId+'.grid'
                             :%pAddr(grid_XmlInput));
         else;
           lGrid=xml_xml2tree(env_getclientPath()+'3fg/'+GridId+'.grid'
                             :%pAddr(grid_XmlInput));
         endIf;
         if lGrid<>*null;
           tree_linktoparent(lGrids:lGrid);
         endif;
       endIf;
       return lGrid;
       end-proc;
