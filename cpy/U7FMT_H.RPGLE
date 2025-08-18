      // --------------------------------------------------------------------
      // FORMAT family
      // --------------------------------------------------------------------
       dcl-c kFormats    'F';
       dcl-c kFormat     'f';
       dcl-c kFields     'I';
       dcl-c kField      'i';
       dcl-c kSubFormats 'S';
       dcl-c kSubFormat  's';
      // Formats
       dcl-ds tFormats qualified;
         kind char(1) inz(kFormats);
       end-ds;
      // Format
       dcl-ds tFormat qualified;
         kind     char(1)     inz(kFormat);
         ID       varchar(10)  inz('');
         len      uns(5)      inz(0);
         fldnbr   uns(5)      inz(0);
         pBuffer1 pointer     inz(*null);
         pBuffer0 pointer     inz(*null);
       end-ds;
      // Fields
       dcl-ds tFields qualified;
         kind char(1) inz(kFields);
       end-ds;
      // Field
       dcl-ds tField qualified;
         kind        char(1)     inz(kField);
         ID          varchar(10)  inz('');
         NO          uns(3)      inz(0);
         type        char(1)     inz('');
         len         uns(5)      inz(0);
         dec         uns(3)      inz(0);
         digits      uns(3)      inz(0);
         posInBuffer uns(5)      inz(0);
       end-ds;
      // Subformats
       dcl-ds tSubFormats qualified;
         kind char(1) inz(kSubFormats);
       end-ds;
      // subFormat
       dcl-ds tSubFormat qualified;
         kind     char(1)     inz(kSubFormat);
         pos      uns(5)      inz(0);
         formula  varchar(50)  inz('');
         lFormula pointer     inz(*null);
       end-ds;
      // get format from list
       dcl-pr fmt_getFormat pointer;
         lFormats pointer    ;
         formatID varchar(10) const ;
         fAppli   char(1)     const options(*nopass);
       end-pr;
      // get item for FORMAT family
       dcl-pr fmt_xmlInput pointer;
         ND   likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pr;
      // set item for FORMAT family
       dcl-pr fmt_XMLoutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pr;
