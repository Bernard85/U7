       ctl-opt nomain option(*noshowcpy) bnddir('U7');
      /copy cpy,u7env_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h

      /copy cpy,mnu7_h
       // --------------------------------------------------------------------
       // get item from Xml parser for MENU family
       // --------------------------------------------------------------------
       dcl-proc mnu_XmlInput export;
         dcl-pi mnu_XmlInput pointer;
           ND const likeDs(xml_nodeDefine);
         end-pi;

       dcl-ds mnu likeds(tMnu)  based(pMnu);
       dcl-ds cmd  likeds(tCmd) based(pCmd);

       if ND.ID='MENU';
         pMnu=tree_getnewitem(%addr(tMnu):%size(tMnu));
         mnu.text=nd.text;
         return pMnu;
       elseif ND.ID='COMMAND';
         pCmd=tree_getnewitem(%addr(tCmd):%size(tCmd));
         cmd.text=nd.text;
         cmd.order=xml_getAttAsString('ORDER':ND.atts);
         return pCmd;
       endIf;
       return *null;
       end-proc;
       // --------------------------------------------------------------------
       // Set line for Xml parser from node on file family
       // --------------------------------------------------------------------
       dcl-proc mnu_XmlOutput export;
         dcl-pi mnu_XmlOutput likeDs(xml_nodeDefine);
           lNode pointer const;
         end-pi;

       dcl-ds ND  likeDs(xml_nodeDefine);
       dcl-ds mnu likeds(tMnu) based(pMnu);
       dcl-ds cmd likeds(tCmd) based(pCmd);

       clear ND;
       if tree_isofthekind(kMnu:lNode:pMnu);
         ND.ID='FILE';
         nd.text=mnu.text;
       elseif tree_isofthekind(kCmd:lNode:pCmd);
         ND.ID='COMMAND';
         nd.text=cmd.text;
         xml_setAttfromString(ND.atts:'ORDER':cmd.order);
       endIf;
       return ND;
       end-proc;
