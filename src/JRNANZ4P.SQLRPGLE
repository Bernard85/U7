     H dftactgrp(*no) bnddir('U7')
      /copy cpy,u7ds_h
      /copy cpy,u7env_h
      /copy cpy,u7ifs_h
      /copy cpy,u7xml_h
      // --------------------------------------------------------------------
      // main
      // --------------------------------------------------------------------
      // Parameters
     djrnanz4p         pi
     d inFile                        20a
     d savID                         50a   varying
     d text                          50a   varying
      // Format sql result
     d jrnanz4r      e ds                  extname('QADSPJR4')
      // sql statement
     d sqlStm          s           2000a
      // declaration for global fields
     d g               ds                  qualified
     d  hJrn                         10i 0
     d  hdta                         10i 0
     d  idx                           5u 0
     d  aSeq                         10i 0 inz(0)
     d  aPos                         10i 0 inz(0)
       // allow writing
       exec sql set option commit=*none, datfmt=*iso;
       // open files
       g.hJrn=ifs_openforWrite(env_getClientPath()+'jrn/'+savID+'.jrn');
       g.hDta=ifs_openforStore(env_getClientPath()+'jrn/'+savID+'.dta');
       // ifs declaration
       ifs_PrintLn(g.hJrn:'<?xml version="1.0" envoding="ISO-8859-1" ?>');
       ifs_PrintLn(g.hJrn:'<JOURNAL ID="'+savID+'">'+text);
       ifs_PrintLn(g.hJrn:'  <ENTRIES>');
       // loading data
       sqlStm='select * from '
             +%trim(%subst(inFile:11:10))
             +'/'
             +%trim(%subst(inFile:1:10 ))
             +' ORDER BY JOTSTP, JOENTT';
       exec sql prepare s1 from :sqlStm;
       exec sql declare input cursor for s1;
       exec sql open input;

       exec sql fetch next from input into :jrnanz4r;
       dow sqlCod=0;
         out_entry(2);
         exec sql fetch next from input into :jrnanz4r;
       endDo;

       exec sql close input;
       // finalize the XML
       ifs_println(g.hJrn:'  </ENTRIES>');
       ifs_println(g.hJrn:'</JOURNAL>');
       // close report files
       ifs_close(g.hJrn);
       ifs_close(g.hDta);
       *inlr=*on;
      // --------------------------------------------------------------------
      // save journal entries
      // --------------------------------------------------------------------
     pOut_entry        b
     d out_entry       pi
     d  level                         3u 0 const
      *
     d nodeDefine      ds                  likeDs(xml_nodeDefine) inz
       nodeDefine.ID='ENTRY';
       nodeDefine.isOpen=*on;
       nodeDefine.isClose=*on;
       nodeDefine.level=level;

       g.aSeq+=1;
       xml_setAttFromInteger(nodeDefine.atts:'APOS':g.aPos);
       if joentl>221;
         xml_setAttFromInteger(nodeDefine.atts:'APOS':g.aPos);
       endIf;

       xml_setAttFromInteger(nodeDefine.atts:'DTAL':joEntL-221);
       xml_setAttFromInteger(nodeDefine.atts:'SEQN':joSeqN);

       xml_setAttFromString (nodeDefine.atts:'CODE':joCode);
       xml_setAttFromString (nodeDefine.atts:'ENTT':joEnTt);

       xml_setAttFromString (nodeDefine.atts:'TSTP':%char(joTstp));
       xml_setAttFromString (nodeDefine.atts:'PGM' :joPgm);

       xml_setAttFromString (nodeDefine.atts:'JOBNO' :%editc(joNbr:'X'));
       xml_setAttFromString (nodeDefine.atts:'JOBUSR':joUser);
       xml_setAttFromString (nodeDefine.atts:'JOBID' :joJob);

       xml_setAttFromString (nodeDefine.atts:'OBJ'   :joObj);
       xml_setAttFromString (nodeDefine.atts:'LIB'   :joLib);
       xml_setAttFromString (nodeDefine.atts:'MBR'   :joMbr);

       xml_setAttFromInteger(nodeDefine.atts:'CTRR'  :joCtrr);
       xml_setAttFromString (nodeDefine.atts:'USPF'  :joUsPf);
       xml_setAttFromString (nodeDefine.atts:'SYNM'  :josynm);
       // write node in xlm
       xml_writeNode(g.hJrn:nodeDefine);
       // write data
       if joEntL>221;
         ifs_print(g.hDta:%subst(joEsd:1:joentl-221));
         g.aPos+=joEntL-221;
       endIf;
     p                 e
