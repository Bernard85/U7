       ctl-opt nomain;
      /copy cpy,u7env_h
      /copy cpy,u7file_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      // --------------------------------------------------------------------
      // get item for FILE family for Xml parser
      // --------------------------------------------------------------------
       dcl-proc file_XmlInput export;
       dcl-pi file_XmlInput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pi;
       dcl-ds file likeds(tFile) based(pFile);
       if ND.ID='FILE';
         pFile=tree_getnewitem(%addr(tFile):%size(tFile));
         file.text=nd.text;
         file.ID=xml_getAttAsString('ID':ND.atts);
         file.format=xml_getAttAsString('FORMAT':ND.atts);
         return pFile;
       endIf;
       return *null;
       end-proc;
      // --------------------------------------------------------------------
      // Set line for Xml parser from node on file family
      // --------------------------------------------------------------------
       dcl-proc file_XmlOutput export;
       dcl-pi file_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pi;
       dcl-ds ND   likeDs(xml_nodeDefine);
       dcl-ds file likeds(tFile) based(pFile);
       clear ND;
       if tree_isofthekind(kFile:lNode:pFile);
         ND.ID='FILE';
         nd.text=file.text;
         xml_setAttfromString(ND.atts:'ID':file.ID);
         xml_setAttfromString(ND.atts:'FORMAT':file.format);
       endIf;
       return ND;
       end-proc;
      // --------------------------------------------------------------------
      // get file
      // --------------------------------------------------------------------
       dcl-proc  file_getFile export;
       dcl-pi file_getFile pointer;
         lFiles pointer;
         fileID varchar(10) const;
       end-pi;
       dcl-s lFile pointer inz(*null);
       if lFiles=*null;
         lFiles=tree_getnewlink(*null);
       endif;
       lFile=tree_getLinkFromList(lFiles:kFile:fileID);
       if lFile=*null;
         lFile=xml_xml2tree(env_getclientPath()+'3fg/'+fileId+'.file'
                           :%pAddr(file_XmlInput));
         if lFile<>*null;
           tree_linktoparent(lFiles:lFile);
         endif;
       endIf;
       return lFile;
       end-proc;
