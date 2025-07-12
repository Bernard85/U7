       ctl-opt nomain option(*noshowcpy);
      /copy cpy,u7env_h
      /copy cpy,u7form_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      // --------------------------------------------------------------------
      // get item form JOURNAL family
      // --------------------------------------------------------------------
       dcl-proc form_XMLinput export;
       dcl-pi form_XMLinput pointer;
         ND const likeDs(xml_nodeDefine);
       end-pi;

       dcl-ds form  likeds(tForm) based(pForm);
       dcl-ds panel likeds(tpanel) based(pPanel);
       dcl-ds label likeds(tlabel) based(plabel);
       if ND.ID='FORM';
         pForm=tree_getnewitem(%addr(tForm):%size(tForm));
         form.ID  =xml_getAttAsString('ID':ND.atts);
         Form.text=ND.text;
         return pForm;
       elseif ND.ID='PANEL';
         pPanel=tree_getnewitem(%addr(tPanel):%size(tPanel));
         Panel.text=ND.text;
         return pPanel;
       elseif ND.ID='LABEL';
         pLabel=tree_getnewitem(%addr(tLabel):%size(tLabel));
         label.text     =xml_getAttAsString ('TEXT'     :ND.atts);
         label.formula  =xml_getAttAsString ('FORMULA'  :ND.atts);
         label.input    =xml_getAttAsBoolean('INPUT'    :ND.atts);
         label.mandatory=xml_getAttAsBoolean('MANDATORY':ND.atts);
         label.maxWidth =xml_getAttAsInteger('MAXWIDTH' :ND.atts);
         return pLabel;
       endIf;
       return *null;
       end-proc;
      // ------------------------------------------------------------------*
      // set item for FORM family
      // -------------------------------------------------------------------
       dcl-proc  Form_XMLoutput export;
       dcl-pi form_XMLoutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pi;
      //
       dcl-ds ND likeDs(xml_nodeDefine);
      //
       dcl-ds form  likeds(tForm)  based(pForm);
       dcl-ds panel likeds(tPanel) based(pPanel);
       dcl-ds label likeds(tLabel) based(pLabel);
       clear ND;

       if tree_isofthekind(kForm:lNode:pForm);
         ND.ID='FORM';
         xml_setAttfromString (ND.atts:'ID':form.ID);
         ND.text=form.text;
       elseif tree_isofthekind(kPanel:lNode:pPanel);
         ND.ID='PANEL';
         ND.text=panel.text;
       elseif tree_isofthekind(kLabel:lNode:pLabel);
         ND.ID='LABEL';
         xml_setAttfromString (ND.atts:'FORMULA'  :label.formula);
         xml_setAttfromInteger(ND.atts:'MAXWIDTH' :label.maxwidth);
         xml_setAttfromBoolean(ND.atts:'INPUT'    :label.input);
         xml_setAttfromBoolean(ND.atts:'MANDATORY':label.mandatory);
         xml_setAttfromString (ND.atts:'TEXT'     :label.text);
       endIf;

       return ND;
       end-proc;
      // --------------------------------------------------------------------
      // get form
      // --------------------------------------------------------------------
       dcl-proc  form_getForm export;
       dcl-pi form_getForm pointer;
         lForms pointer;
         formID varchar(10) const;
         fAppli char(1)     const options(*nopass);
       end-pi;

       dcl-s lForm pointer;
       if lForms=*null;
         lforms=tree_getnewlink(*null);
       endif;
       lForm=tree_getLinkFromList(lForms:kForm:formID);
       if lForm=*null;
         if %parms()=%parmNum(fAppli) and fAppli='Y';
           lForm=xml_xml2tree(env_getAppliPath()+'3fg/'+formId+'.form'
                             :%pAddr(FORM_XmlInput));
         else;
           lForm=xml_xml2tree(env_getclientPath()+'3fg/'+formId+'.form'
                             :%pAddr(FORM_XmlInput));
         endIf;
         if lForm<>*null;
           tree_linktoparent(lForms:lForm);
         endif;
       endIf;
       return lForm;
       end-proc;
