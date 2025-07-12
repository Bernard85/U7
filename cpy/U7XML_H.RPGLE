      // xml define
       dcl-ds xml_NodeDefine inz template qualified;
         isOpen  ind          ;
         isClose ind          ;
         ID      varchar(128) ;
         atts    varchar(2048);
         text    varchar(2048);
         level   uns(3)       ;
       end-ds;
      // xml_read
       dcl-pr xml_read;
         path   varchar(255)    const;
         pProc1 pointer(*proc)  const;
         pBox   pointer        const;
       end-pr;
      // get attribut as string
       dcl-pr XML_getAttAsString varchar(128);
         pty  varchar(128)   const;
         ptys varchar(2048)  const;
       end-pr;
      // get attribut as integer
       dcl-pr XML_getAttAsInteger int(10);
         pty  varchar(128)   const;
         ptys varchar(2048)  const;
       end-pr;
      // get attribut as boolean
       dcl-pr XML_getAttAsBoolean ind;
         pty  varchar(128)   const;
         ptys varchar(2048)  const;
       end-pr;
      // hide special characters
       dcl-pr xml_HideSpecialCharacters varchar(2048);
         input varchar(2048) const;
       end-pr;
      // seek special characters
       dcl-pr xml_SeekSpecialCharacters varchar(2048);
         input varchar(2048)  const;
       end-pr;
      // set attribut from integer value
       dcl-pr xml_setAttfromInteger;
         atts varchar(2048);
         pty  varchar(128)   const;
         val  int(20)       const;
       end-pr;
      // set attribut from string value
       dcl-pr xml_setAttfromString;
         atts varchar(2048);
         pty  varchar(128)   const;
         val  varchar(128)   const;
       end-pr;
      // set attribut from string value
       dcl-pr xml_setAttfromBoolean;
         atts varchar(2048);
         pty  varchar(128)   const;
         val  ind           const;
       end-pr;
      // Save tree as XML
       dcl-pr xml_tree2XML;
         xmlpath       varchar(128)   const ;
         lRoot         pointer        const;
         pXX_XMLoutput pointer(*proc) const ;
       end-pr;
      // xml write node
       dcl-pr xml_writeNode;
         hJRN int(10) const;
         ND          likeDs(xml_nodeDefine);
       end-pr;
      // get XML node define
       dcl-pr xml_xml2tree pointer;
         path varchar(256)           const;
         pInterpreter pointer(*proc) const;
       end-pr;
