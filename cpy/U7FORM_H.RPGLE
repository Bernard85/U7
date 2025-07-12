      // FORM family
       dcl-c kForm  'f';
       dcl-c kPanel 'p';
       dcl-c kLabel 'l';
      // form
       dcl-ds tForm qualified;
         kind char(1)      inz(kForm);
         ID   varchar(10) ;
         text varchar(128);
       end-ds;
      // panel
       dcl-ds tPanel qualified;
         kind char(1)      inz(kPanel);
         text varchar(128);
       end-ds;
      // label
       dcl-ds tLabel qualified;
         kind      char(1)     inz(kLabel);
         text      varchar(50)            ;
         formula   varchar(50)            ;
         lFormula  pointer                ;
         maxWidth  uns(5)                 ;
         input     ind         inz(*off)  ;
         mandatory ind         inz(*off)  ;
       end-ds;
      // get item form JOURNAL family
       dcl-pr form_XMLinput pointer;
         ND const likeDs(xml_nodeDefine);
       end-pr;
      // set item for FORM family
       dcl-pr form_XMLoutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pr;
      // get form from list
       dcl-pr form_getForm pointer;
         lForms pointer    ;
         formID varchar(10) const ;
         fAppli char(1)     const options(*nopass);
       end-pr;
