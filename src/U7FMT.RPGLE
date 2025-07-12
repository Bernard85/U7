       ctl-opt nomain option(*noshowcpy);
      /copy cpy,u7int_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,u7env_h

      /copy cpy,u7fmt_h
      // --------------------------------------------------------------------
      // get format from list
      // --------------------------------------------------------------------
       dcl-proc  fmt_getFormat export;
       dcl-pi fmt_getFormat pointer;
         lFmts  pointer;
         fmtID  varchar(10) const;
         fAppli char(1)     const options(*nopass);
       end-pi;
      //
       dcl-s lFmt pointer;
       if lFmts=*null;
         lFmts=tree_getnewlink(
                  tree_getNewItem(%addr(tFormats):%size(tFormats)));
       endif;
       lFmt=tree_getLinkFromList(lFmts:kformat:fmtID);
       if lFmt=*null;
         if %parms()=%parmNum(fAppli) and fAppli='Y';
           lFmt=xml_xml2tree(env_getAppliPath()+'3fg/'+fmtID+'.fmt'
                            :%pAddr(fmt_xmlInput));
         else;
           lFmt=xml_xml2tree(env_getclientPath()+'3fg/'+fmtID+'.fmt'
                            :%pAddr(fmt_xmlInput));
         endIf;
         if lFmt<>*null;
           fmt_SubFormatsFormulaLoad(lFmt);
           tree_linktoparent(lFmts:lFmt);
         endif;
       endIf;
       return lFmt;
       end-proc;
      // -------------------------------------------------------------------
      // get item for FORMAT family
      // -------------------------------------------------------------------
       dcl-proc  fmt_XmlInput export;
       dcl-pi fmt_xmlInput pointer;
         ND const likeDs(xml_nodeDefine);
       end-pi;
      //
       dcl-ds fmt     likeds(tformat)    based(pFmt);
       dcl-ds fields  likeds(tFields)    based(pFields);
       dcl-ds field   likeds(tField)     based(pField);
       dcl-ds subFmts likeds(tSubFormats)based(pSubFmts);
       dcl-ds subFmt  likeds(tSubFormat) based(pSubFmt);
       if ND.ID='FORMAT';
         pFmt=tree_getnewitem(%addr(tFormat):%size(tFormat));
         fmt.ID    =xml_getAttAsString('ID':ND.atts);
         fmt.len   =xml_getAttAsInteger('LEN':ND.atts);
         fmt.fldnbr=xml_getAttAsInteger('FLDNBR':ND.atts);
         fmt.pBuffer1=*null;
         fmt.pBuffer0=*null;
         return pFmt;

       elseIf ND.ID='FIELDS';
         pFields=tree_getnewitem(%addr(tFields):%size(tFields));
         return pFields;

       elseif ND.ID='FIELD';
         pField=tree_getnewitem(%addr(tField):%size(tField));
         field.ID  =xml_getAttAsString('ID':ND.atts);
         field.NO  =xml_getAttAsInteger('NO':ND.atts);
         field.type=xml_getAttAsString('TYPE':ND.atts);
         field.Len =xml_getAttAsInteger('LEN':ND.atts);
         field.dec =xml_getAttAsInteger('DEC':ND.atts);
         field.digits=xml_getAttAsInteger('DIGITS':ND.atts);
         field.posinbuffer=xml_getAttAsInteger('POS':ND.atts)-1;
         return pField;

       elseIf ND.ID='SUBFORMATS';
         pSubFmts=tree_getnewitem(%addr(tSubFormats):%size(tSubFormats));
         return pSubFmts;

       elseIf ND.ID='SUBFORMAT';
         pSubFmt=tree_getnewitem(%addr(tSubFormat):%size(tSubFormat));
         SubFmt.pos=xml_getAttAsInteger('POS':ND.atts)-1;
         SubFmt.formula=xml_getAttAsString('FORMULA':ND.atts);
         return pSubFmt;

       endIf;
       return *null;
       end-proc;
      // ------------------------------------------------------------------*
      // set item for FORMAT family
      // -------------------------------------------------------------------
       dcl-proc  fmt_XMLoutput export;
       dcl-pi fmt_XMLoutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pi;

       dcl-ds ND      likeDs(xml_nodeDefine);
       dcl-ds fmt     likeds(tFormat)    based(pFmt);
       dcl-ds fields  likeds(tFields)    based(pFields);
       dcl-ds field   likeds(tField)     based(pField);
       dcl-ds subFmts likeds(tSubformats)based(pSubFmts);
       dcl-ds subFmt  likeds(tSubformat) based(pSubFmt);
       clear ND;

       if tree_isofthekind(kFormat:lNode:pFmt);
         ND.ID='FORMAT';
         xml_setAttfromString (ND.atts:'ID':fmt.ID);
         xml_setAttfromInteger(ND.atts:'LEN':fmt.len);
         xml_setAttfromInteger(ND.atts:'FLDNBR':fmt.fldnbr);

       elseIf tree_isofthekind(kFields:lNode:pFields);
         ND.ID='FIELDS';

       elseif tree_isofthekind(kField:lNode:pField);
         ND.ID='FIELD';
         xml_setAttfromString (ND.atts:'ID':field.ID);
         xml_setAttfromInteger(ND.atts:'NO':field.NO);
         xml_setAttfromString (ND.atts:'TYPE':field.type);
         xml_setAttfromInteger(ND.atts:'LEN':field.len);
         if %scan(field.type:'PS')>0;
           xml_setAttfromInteger(ND.atts:'DIGITS':field.digits);
           xml_setAttfromInteger(ND.atts:'DEC':field.dec);
         endIf;
         xml_setAttfromInteger(ND.atts:'POS':field.posinbuffer);

       elseIf tree_isofthekind(kSubFormats:lNode:pSubFmts);
         ND.ID='SUBFORMATS';

       elseIf tree_isofthekind(kSubFormat:lNode:pSubFmt);
         ND.ID='SUBFORMAT';
         xml_setAttfromInteger(ND.atts:'POS':SubFmt.pos);
         xml_setAttfromString (ND.atts:'FORMULA':SubFmt.formula);

       endIf;

       return ND;
       end-proc;
      // ------------------------------------------------------------------*
      // for SubFormats load there formula
      // -------------------------------------------------------------------
       dcl-proc fmt_SubFormatsFormulaLoad;
       dcl-pi fmt_SubFormatsFormulaLoad;
         lFmt pointer;
       end-pi;

       dcl-s lSubFmts pointer;
       dcl-s lSubFmt  pointer;
       dcl-ds SubFmt likeDs(tSubFormat)based(pSubFmt);

       lSubFmts=tree_getLinkFromList(lFmt:kSubformats);
       if lSubFmts=*null;
         return;
       endif;
       lSubFmt=tree_getFirst(lSubFmts);
       dow lSubFmt<>*null;
         pSubFmt=tree_getItem(lSubFmt);
         subFmt.lFormula=int_FormulaLoad(subFmt.Formula:lFmt);
         lSubFmt=tree_getNext(lSubFmt);
       endDo;
       end-proc;
