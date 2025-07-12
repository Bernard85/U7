     h nomain option(*noshowcpy)
      // copy
      /copy cpy,u7ibm_h
      /copy cpy,u7fmt_h
      /copy cpy,u7ifs_h
      /copy cpy,u7int_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h
      // --------------------------------------------------------------------
      // xml_read
      // --------------------------------------------------------------------
       dcl-proc  xml_read export;
       dcl-pi xml_read;
         path         varchar(255)    const;
         pprocessNode pointer(*proc)  const;
         pBox         pointer        const;
       end-pi;
      *
       dcl-ds ND likeDs(xml_NodeDefine);
      *
       dcl-pr processNode ind extproc(pProcessNode);
         ND          likeDs(xml_NodeDefine);
         pBox pointer const;
       end-pr;
       dcl-s p1     uns(5);
       dcl-s p2     uns(5);
       dcl-s p9     uns(5)      INZ(1);
       dcl-s buffer char(65535);
       dcl-s hstmf  int(10);
       dcl-s nRead  int(10);
       // open the text file
       hSTMF=open(path:O_rdonly+o_TextData);
       nRead=Read(hSTMF:%addr(buffer):%size(buffer));
       // read nodes
       p1=%scan('<':buffer);
       dow p1>0;
         clear ND;
         p9=xml_SyncScan('>':buffer:p1:hSTMF);
         // XML declaration
         if %subst(buffer:p1:2)='<?';
         // XML close node
         elseIf %subst(buffer:p1:2)='</';
             ND.isOpen=*off;
             ND.isclose=*on;
             ND.ID=%subst(buffer:p1+2:p9-p1-2);
             if processNode(ND:pBox);
               leave;
             endif;
         else;
         // XML regular node
             ND.isOpen=*on;
             ND.isClose=%subst(buffer:p9-1:2)='/>';
             p2      =getminnot0(%scan(' ' :buffer:p1):
                                 %scan('/>':buffer:p1):
                                 %scan('>' :buffer:p1));
             ND.id  =%subst(buffer:p1+1:p2-p1-1);
             // Case of a node with attributes
             if p9>p2;
               ND.atts=%subst(buffer:p2+1:p9-p2-1);
               ND.atts=xml_SeekSpecialCharacters(ND.atts);
             endif;
             p1=p9;
             p9=xml_SyncScan('<':buffer:p1:hSTMF);
             ND.text=%subst(buffer:p1+1:p9-p1-1);
             ND.text=%scanRpl(x'0d':'':ND.Text);
             ND.text=%scanRpl(x'25':'':ND.Text);
             ND.Text=%trimR(ND.Text);
             ND.text=xml_SeekSpecialCharacters(ND.text);
             if processNode(ND:pBox);
               leave;
             endif;
         endIf;
         p1=xml_SyncScan('<':buffer:p9:hSTMF);
       endDo;
       // Close the file
       hSTMF=Close(hSTMF);
       end-proc;
      // --------------------------------------------------------------------
      // sync and scan
      // --------------------------------------------------------------------
       dcl-proc  xml_SyncScan;
       dcl-pi xml_SyncScan uns(5);
         what   varchar(2)  const;
         buffer char(65535);
         p1     uns(5);
         hStmf  int(10);
       end-pi;
      *
       dcl-s p uns(5);
       p=%scan(what:buffer:p1);
       if p>0;
         return p;
       endif;
       buffer=%subst(buffer:p1:%size(buffer)-p1+1);
       if read(hstmf:%addr(buffer)+%size(buffer)-p1+1:p1-1)=0;
         return 0;
       endif;
       p1=1;
       return %scan(what:buffer);
       end-proc;
      // --------------------------------------------------------------------
      // get attribut as string
      // --------------------------------------------------------------------
       dcl-proc XML_getAttAsString export;
       dcl-pi XML_getAttAsString varchar(128);
         pty  varchar(128)   const;
         ptys varchar(2048)  const;
       end-pi;
      *
       dcl-s p1  uns(5);
       dcl-s p2  uns(5);
       dcl-s val varchar(128);
       p1=%scan(pty+'="':ptys);
       if p1=0;
         return '';
       endif;
       p1+=%len(pty)+2;
       p2=%scan('"':ptys:p1);
       val=%subst(ptys:p1:p2-p1);
       return val;
       end-proc;
      // --------------------------------------------------------------------
      // get attribut as integer
      // --------------------------------------------------------------------
       dcl-proc XML_getAttAsInteger export;
       dcl-pi XML_getAttAsInteger int(10);
         pty  varchar(128)   const;
         ptys varchar(2048)  const;
       end-pi;
      *
       dcl-s val varchar(128);
        val=XML_getAttAsString(pty:ptys);
        if val='';
          return 0;
        else;
          return %int(val);
        endif;
       end-proc;
      // --------------------------------------------------------------------
      // get attribut as boolean
      // --------------------------------------------------------------------
       dcl-proc XML_getAttAsBoolean export;
       dcl-pi XML_getAttAsBoolean ind;
         pty  varchar(128)   const;
         ptys varchar(2048)  const;
       end-pi;
      *
       dcl-s val varchar(128);
        val=XML_getAttAsString(pty:ptys);
        return val='Y';
       end-proc;
      // --------------------------------------------------------------------
      // get min not null
      // --------------------------------------------------------------------
       dcl-proc  getMinNot0;
       dcl-pi *n uns(5);
         u1 uns(5) const;
         u2 uns(5) const;
         u3 uns(5) const;
       end-pi;
       dcl-s min uns(5) inz(*hival);
        if u1<min and u1>0;
          min=u1;
        endif;
        if u2<min and u2>0;
          min=u2;
        endif;
        if u3<min and u3>0;
          min=u3;
        endif;
        if min=*hival;
          return 0;
        endif;
        return min;
       end-proc;
      // --------------------------------------------------------------------
      // hide special characters
      // --------------------------------------------------------------------
       dcl-proc xml_HideSpecialCharacters export;
       dcl-pi xml_HideSpecialCharacters varchar(2048);
         S_ varchar(2048)  const;
       end-pi;
       dcl-s S varchar(2048);
       S=%scanRpl(';':'&amp;' :S_);
       S=%scanRpl('<':'&lt;'  :S );
       S=%scanRpl('>':'&gt;'  :S );
       ///S=%scanRpl('"':'&quot;':S );
       return s;
       end-proc;
      // --------------------------------------------------------------------
      // seek special characters
      // --------------------------------------------------------------------
       dcl-proc xml_SeekSpecialCharacters export;
       dcl-pi xml_SeekSpecialCharacters varchar(2048);
         String_ varchar(2048)  const;
       end-pi;
       dcl-s String varchar(2048);
       String=%scanrpl('&lt;'  :'<':String_);
       String=%scanrpl('&gt;'  :'>':String );
       String=%scanrpl('&quot;':'"':String );
       String=%scanrpl('&amp;' :';':String );
       return string;
       end-proc;
      // -----------------------------------------------------------------------
      // set attribut from string value
      // -----------------------------------------------------------------------
       dcl-proc xml_setAttfromString export;
       dcl-pi xml_setAttfromString;
         atts varchar(2048);
         pty  varchar(128)   const;
         val  varchar(128)   const;
       end-pi;
       atts+=' '+pty+'="'+%trimR(val)+'"';
       end-proc;
      // -----------------------------------------------------------------------
      // set attribut from integer value
      // -----------------------------------------------------------------------
       dcl-proc xml_setAttfromInteger export;
       dcl-pi xml_setAttfromInteger;
         atts varchar(2048);
         pty  varchar(128)   const;
         val  int(20)       const;
       end-pi;
       atts+=' '+pty+'="'+%char(val)+'"';
       end-proc;
      // -----------------------------------------------------------------------
      // set attribut from boolean value
      // -----------------------------------------------------------------------
       dcl-proc xml_setAttfromBoolean export;
       dcl-pi xml_setAttfromBoolean;
         atts varchar(2048);
         pty  varchar(128)   const;
         val  ind           const;
       end-pi;
       if val;
         atts+=' '+pty+'="Y"';
       else;
         atts+=' '+pty+'="N"';
       endif;
       end-proc;
      // -----------------------------------------------------------------------
      // xml write node
      // -----------------------------------------------------------------------
       dcl-proc  xml_writeNode export;
       dcl-pi xml_writeNode;
         hJRN int(10) const;
         ND          likeDs(xml_nodeDefine);
       end-pi;
      *
       dcl-s space char(255)      inz('');
       dcl-s dta   varchar(65535)  inz('');

       nd.text=xml_hideSpecialCharacters(ND.text);
       nd.atts=xml_hideSpecialCharacters(ND.atts);

       if ND.level>0;
         dta=%subst(space:1:ND.level*2);
       endIf;
       if ND.isOpen and ND.isClose and ND.level=0;
         dta+='<'+ND.ID+ND.atts+'>'+ND.text+'</'+ND.ID+'>';
       elseif ND.isOpen;
         dta+='<'+ND.ID+ND.atts;
         if ND.isClose;
           dta+='/';
         endIf;
         dta+='>';
         dta+=ND.text;
       elseif ND.isClose;
         dta+='</'+ND.ID+'>';
       endIf;
       ifs_println(hJRN:dta);
       end-proc;
      // --------------------------------------------------------------------
      // Save tree as XML
      // --------------------------------------------------------------------
       dcl-proc  xml_tree2XML export;
       dcl-pi xml_tree2XML;
         xmlpath       varchar(128)   const;
         lRoot         pointer        const;
         pXX_XMLoutput pointer(*proc) const;
       end-pi;
      *
       dcl-s hXML int(10);
        hXML=ifs_openforWrite(XMLpath);
        ///ifs_println(hXML:'<?xml version="1.0" encoding="ISO-8859-1" ?>');
        xml_tree2XML2(hXML:lRoot:pXX_XMLoutput);
        ifs_close(hXML);
       end-proc;
      // --------------------------------------------------------------------
      // Save tree as XML part2
      // --------------------------------------------------------------------
       dcl-proc  xml_tree2XML2;
       dcl-pi xml_tree2XML2;
         hXml          int(10);
         lNode         pointer        const;
         pXX_XMLoutput pointer(*proc) const;
       end-pi;
      *
       dcl-ds ND likeDs(xml_NodeDefine);
       dcl-s lNode2 pointer;
      *
       dcl-pr xxx_XMLoutPut extProc(pXX_XMLoutput) likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pr;
       ND=xxx_XMLoutput(lNode);
       if nd.id='';
         return;
       endif;
       ND.isOpen=*on;
       ND.isClose=tree_getFirst(lNode)=*null;
       ND.level=tree_getLevel(lNode);
       xml_writeNode(hXml:ND);
       //
       if not ND.isClose;
         // Process childs                                                     -
         lNode2=tree_getFirst(lNode);
         dow lNode2<>*null;
           xml_tree2XML2(hXML:lNode2:pXX_XMLoutput);
           lNode2=tree_getNext(lNode2);
         endDo;
         ND.isOpen=*off;
         ND.isClose=*on;
         xml_writeNode(hXml:ND);
       endIf;
       end-proc;
      // -----------------------------------------------------------------------
      // get XML node define
      // -----------------------------------------------------------------------
       dcl-proc xml_getND                                                export;
        dcl-pi *n likeDs(xml_NodeDefine);
          buffer char(65535);
          curPos uns(5);
        end-pi;
      *
        dcl-s p1 uns(5);
        dcl-s p2 uns(5);
        dcl-s p3 uns(5);
        dcl-s p4 uns(5);

        dcl-ds ND likeDs(xml_NodeDefine);

       clear ND;

       p1=%scan('<':buffer:curPos);
       if p1>0 and %subst(buffer:p1:2)='<?';
         p1=%scan('<':buffer:p1+1);
       endIf;

       If p1=0;
         ND.isOpen=*off;
         return ND;
       endIf;

       p3=%scan('>':buffer:p1);

       if %subst(buffer:p1:2)='</';
         ND.isOpen=*off;
         ND.isClose=*on;
         ND.ID=%subst(buffer:p1+2:p3-p1-2);
         curPos=p3;
         return ND;
       endIf;

       ND.isOpen=*on;
       ND.isClose=%subst(buffer:p3-1:2)='/>';
       p2=getMinNot0(%scan(' ':buffer:p1)
                    :%scan('/>':buffer:p1)
                    :%scan('>':buffer:p1));
       ND.id     =%subst(buffer:p1+1:p2-p1-1);
       if p3>p2;
         ND.atts=%subst(buffer:p2+1:p3-p2-1);
         ND.atts=xml_seekSpecialCharacters(ND.atts);
       endIf;
       p4=%scan('<':buffer:p3);
       ND.text=%subst(buffer:p3+1:p4-p3-1);
       ND.text=%scanRpl(x'0d25':'':ND.Text);
       ND.text=xml_seekSpecialCharacters(ND.text);
       curPos=P4;
       return ND;
       end-proc;
      // -----------------------------------------------------------------------
      // set up tree for xml
      // -----------------------------------------------------------------------
       dcl-proc xml_xml2Tree export;
        dcl-pi *n pointer;
          path         varChar(256)   const;
          pXXX_XmlInput pointer(*proc) const;
        end-pi;
        dcl-s hXML   int(10);
        dcl-s buffer char(65535);
        dcl-s curPos uns(5)  inz(1);
        dcl-s lRoot  pointer inz(*null);
        dcl-s nRead  int(10);
        hXml=open(path:o_rdonly+o_textdata);
        nRead=read(hXml:%addr(buffer):%size(buffer));
        lRoot=xml_xml2Tree2(pXXX_XmlInput:0:buffer:curPos:lRoot);
        hXml=close(hXml);
        return lRoot;
        end-proc;
      // -----------------------------------------------------------------------
      // set up tree for xml (2)
      // -----------------------------------------------------------------------
       dcl-proc xml_xml2Tree2;
        dcl-pi *n pointer;
         pXXX_XmlInput pointer(*proc) const;
         level        int(3)         const;
         buffer       char(65535);
         curPos       uns(5);
         lParent      pointer options(*nopass);
        end-pi;
        dcl-ds ND likeDs(xml_nodeDefine);
        dcl-s  lItem pointer inz(*null);
        dcl-s  pItem pointer;
        dcl-pr XXX_XmlInput pointer extProc(pXXX_XmlInput);
          ND likeDs(xml_NodeDefine) const;
        end-pr;
        ND=xml_getND(buffer:curPos);
        dow ND.isOpen;
          lItem=*null;
          // node with childs
          if not ND.isClose;
            xml_xml2Tree2(pXXX_XmlInput:level+1:buffer:curPos:lItem);
          endIf;
          lItem=tree_checkLink(lItem:level);
          // interpret
          pItem=XXX_XmlInput(ND);
          tree_setItem(lItem:pItem);
          // if root return it
          if level=0;
            return lItem;
          else;
            lParent=tree_checkLink(lParent:level-1);
            tree_linkToParent(lParent:lItem);
          endIf;
          //
          ND=xml_getND(buffer:curPos);
        endDo;
        return *null;
        end-proc;
