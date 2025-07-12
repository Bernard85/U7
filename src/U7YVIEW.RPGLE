       ctl-opt option(*noshowcpy) nomain;
      /copy cpy,u7env_h
      /copy cpy,u7fmt_h
      /copy cpy,u7form_h
      /copy cpy,u7int_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      /copy cpy,u7yview_h
      // --------------------------------------------------------------------
      // get vertical view
      // --------------------------------------------------------------------
       dcl-proc  yview_getYView export;

         dcl-pi yview_getYView pointer;
           lYViews pointer;
           lForms  pointer;
           lFmts   pointer;
           fmtID   varchar(10) const;
           fAppli_ char(1)     const options(*nopass);
         end-pi;

       dcl-s lYView pointer inz(*null);
       dcl-s pYView pointer inz(*null);
       dcl-s fAppli char(1) inz('N');
       // appli means it is a object for the appli
       if %parms()=%parmnum(fAppli_);
         fAppli=fAppli_;
       endIf;
       // create the YView anchor if it doesn't exist
       if lYViews=*null;
         lYViews=tree_getnewlink(*null);
       endif;
       //
       lYView=tree_getLinkFromList(lYViews:kYView:fmtID);
       if lYView=*null;
         // load new view
         pYView=yview_loadYView(lForms:lFmts:fmtID:fAppli);
         if pYView=*null;
           return *null;
         endIf;
         // link to the main tree view
         lYView=tree_getNewLink(pYView);
         tree_linktoparent(lYViews:lYView);
       endIf;
       return lYView;
       end-proc;
      // --------------------------------------------------------------------
      // load new vertical view
      // --------------------------------------------------------------------
       dcl-proc  yview_loadYView;

         dcl-pi yview_loadYView pointer;
           lForms pointer;
           lFmts  pointer;
           fmtID  varchar(10) const;
           fAppli char(1)     const;
         end-pi;

       dcl-ds YView likeds(tYView) based(pYView);
       dcl-s lFmt     pointer inz(*null);
       dcl-s lForm    pointer inz(*null);
       dcl-s lVariant pointer inz(*null);
       dcl-ds label likeDS(tLabel) based(pLabel);
       // create the forms anchor if it doesn't exist
       if lForms=*null;
         lForms=tree_getnewlink(*null);
       endif;
       // create the formats anchor if it doesn't exist
       if lFmts=*null;
         lFmts=tree_getnewlink(*null);
       endif;
       // Load corresponding format
       lFmt=fmt_getFormat(lFmts:fmtID:fAppli);
       if lFmt=*null;
         return *null;
       endIf;
       // Load corresponding form
       lForm=form_getForm(lForms:fmtID:fAppli);
       if lForm=*null;
         return *null;
       endIf;
       // Create the new item YView
       pYView=tree_getNewItem(%addr(tYView):%size(tYView));
       YView.ID=fmtID;
       YView.lFmt =lFmt;
       YView.lForm=lForm;
       // Resolve formulas
       lVariant=tree_getFirst(YView.lForm);
       dow lVariant<>*null;
         if tree_isOfTheKind(kLabel:lVariant:pLabel);
           label.lFormula
           =int_FormulaLoad(label.formula:yView.lFmt);
         endIf;
         lVariant=tree_getNextToDisplay(yView.lForm:lVariant);
       endDo;
       // put on first segment/label
       YView.ArmTop.lVariant=tree_getFirst(yView.lForm);
       YView.ArmTop.segment=0;
       return pYView;
       end-proc;
