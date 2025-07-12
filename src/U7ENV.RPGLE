        ctl-opt nomain option(*noshowcpy);
       /copy cpy,u7tree_h
       /copy cpy,u7xml_h
       /copy cpy,u7fmt_h
       dcl-ds u7env dtaara;
         *n char(2000);
       end-ds;

       dcl-ds u7envr extname('U7ENVR') based(pU7envR) end-ds;

       dcl-ds g      qualified;
         lenvR pointer inz(*null);
       end-ds;
      // --------------------------------------------------------------------
      // get Welcome Message
      // --------------------------------------------------------------------
       dcl-proc env_getWelcomeMessage export;
       dcl-pi env_getWelcomeMessage varchar(100);
       end-pi;
       return env_getValue('U7MSG1');
       end-proc;
      // --------------------------------------------------------------------
      // get appli path
      // --------------------------------------------------------------------
       dcl-proc env_getAppliPath export;
       dcl-pi env_getAppliPath varchar(50);
       end-pi;
       return env_getValue('U7APPPATH');
       end-proc;
      // --------------------------------------------------------------------
      // get client path
      // --------------------------------------------------------------------
       dcl-proc env_getClientPath export;
       dcl-pi env_getClientPath varchar(50);
       end-pi;
       return env_getValue('U7CLIPATH');
       end-proc;
      // --------------------------------------------------------------------
      // get environment value
      // --------------------------------------------------------------------
       dcl-proc  env_getValue;
         dcl-pi env_getValue varchar(255);
           tag varchar(10) const;
         end-pi;
       dcl-s lFields pointer;
       dcl-s lField  pointer;
       dcl-ds field likeDs(tField) based(pField);
       dcl-s tagValue varchar(255);
       tagValue='';
       in u7env;
       pU7envR=%addr(u7Env);
       if g.lEnvr=*null;
         g.lEnvR=xml_xml2tree(%trim(u7AppPath)+'3fg/'+'u7envr.fmt'
                             :%paddr(fmt_XmlInput));
         if g.lenvR=*null;
           return '';
         endIf;
       endIf;
      //
       lFields=tree_getLinkFromList(g.lEnvr:kFields);
       lField=tree_getLinkFromList(lFields:kField:tag);
       if lField=*null;
         return '';
       endIf;
       pField=tree_getItem(lField);
       //
       tagValue=%subst(u7envR:field.posinbuffer+1:field.len);
       tagValue=%trim(tagValue);
       return tagValue;
       end-proc;
