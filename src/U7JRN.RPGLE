       ctl-opt nomain option(*noshowcpy);
      /copy cpy,u7filter_h
      /copy cpy,u7tree_h
      /copy cpy,u7xml_h

      /copy cpy,u7jrn_h
      // --------------------------------------------------------------------
      // get item form JOURNAL family
      // --------------------------------------------------------------------
       dcl-proc jrn_XMLinput export;
       dcl-pi jrn_XMLinput pointer;
         ND const likeDs(xml_nodeDefine);
       end-pi;

       dcl-ds journal likeds(tjournal) based(pjournal);
       dcl-ds entries likeds(tEntries) based(pEntries);
       dcl-ds section likeds(tSection) based(pSection);
       dcl-ds entry   likeds(tEntry)   based(pEntry);
       if ND.ID='JOURNAL';
         pJournal=tree_getnewitem(%addr(tJournal):%size(tJournal));
         Journal.ID=xml_getAttAsString('ID':ND.atts);
         Journal.text=ND.text;
         return pJournal;

       elseif ND.ID='ENTRIES';
         pEntries=tree_getnewitem(%addr(tEntries):%size(tEntries));
         return pEntries;

       elseif ND.ID='SECTION';
         pSection=tree_getnewitem(%addr(tSection):%size(tSection));
         section.text=ND.text;
         return pSection;

       elseif ND.ID='ENTRY';
         pEntry=tree_getnewitem(%addr(tEntry):%size(tEntry));
         entry.det.ASeq=xml_getAttAsInteger('ASEQ':ND.atts);
         entry.det.APos=xml_getAttAsInteger('APOS':ND.atts);
         entry.det.Dtal=xml_getAttAsInteger('DTAL':ND.atts);
         entry.det.Seqn=xml_getAttAsInteger('SEQN':ND.atts);
         entry.det.code=xml_getAttAsString ('CODE':ND.atts);
         entry.det.entt=xml_getAttAsString ('ENTT':ND.atts);
         entry.det.tstp=xml_getAttAsString ('TSTP':ND.atts);
         entry.det.jobNO =xml_getAttAsString ('JOBNO' :ND.atts);
         entry.det.jobUSR=xml_getAttAsString ('JOBUSR' :ND.atts);
         entry.det.jobID =xml_getAttAsString ('JOBID' :ND.atts);
         entry.det.pgm =xml_getAttAsString ('PGM' :ND.atts);
         entry.det.obj =xml_getAttAsString ('OBJ' :ND.atts);
         entry.det.Lib =xml_getAttAsString ('LIB' :ND.atts);
         entry.det.Mbr =xml_getAttAsString ('MBR' :ND.atts);
         entry.det.Ctrr=xml_getAttAsInteger('CTRR':ND.atts);
         entry.det.uspf=xml_getAttAsString ('USPF':ND.atts);
         entry.det.syNM=xml_getAttAsString ('SYNM':ND.atts);
         return pEntry;
       else;
         return filter_XMLinput(ND);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Set line for Xml parser from node on journal family
      // --------------------------------------------------------------------
       dcl-proc jrn_XmlOutput export;
       dcl-pi jrn_XmlOutput likeDs(xml_nodeDefine);
         lNode pointer const;
       end-pi;

       dcl-ds ND      likeDs(xml_nodeDefine);
       dcl-ds journal likeds(tjournal) based(pjournal);
       dcl-ds entries likeds(tEntries) based(pEntries);
       dcl-ds section likeds(tSection) based(pSection);
       dcl-ds entry   likeds(tEntry)   based(pEntry);
       clear ND;
       if tree_isofthekind(kJournal:lNode:pJournal);
         ND.ID='JOURNAL';
         ND.text=journal.text;
         xml_setAttfromString(ND.atts:'ID':journal.ID);
       elseif tree_isofthekind(kEntries:lNode:pEntries);
         ND.ID='ENTRIES';
       elseif tree_isofthekind(kSection:lNode:pSection);
         ND.ID='SECTION';
         ND.text=section.text;
       elseif tree_isofthekind(kEntry:lNode:pEntry);
         ND.ID='ENTRY';
         xml_setAttfromInteger(ND.atts:'ASEQ':entry.det.ASeq);
         xml_setAttfromInteger(ND.atts:'APOS':entry.det.APos);
         xml_setAttfromInteger(ND.atts:'DTAL':entry.det.Dtal);
         xml_setAttfromInteger(ND.atts:'SEQN':entry.det.Seqn);
         xml_setAttfromString (ND.atts:'CODE':entry.det.code);
         xml_setAttfromString (ND.atts:'ENTT':entry.det.entt);
         xml_setAttfromString (ND.atts:'TSTP':entry.det.tstp);
         xml_setAttfromString (ND.atts:'JOBNO':entry.det.jobNO);
         xml_setAttfromString (ND.atts:'JOBUSR':entry.det.jobUsr);
         xml_setAttfromString (ND.atts:'JOBID':entry.det.jobID);
         xml_setAttfromString (ND.atts:'PGM' :entry.det.pgm );
         xml_setAttfromString (ND.atts:'OBJ' :entry.det.obj );
         xml_setAttfromString (ND.atts:'LIB' :entry.det.Lib );
         xml_setAttfromString (ND.atts:'MBR' :entry.det.Mbr );
         xml_setAttfromInteger(ND.atts:'CTRR':entry.det.Ctrr);
         xml_setAttfromString (ND.atts:'USPF':entry.det.uspf);
         xml_setAttfromString (ND.atts:'SYNM':entry.det.syNM);
       else;
         ND=filter_XmlOutput(lNode);
       endIf;
       return ND;
       end-proc;
      // --------------------------------------------------------------------
      // link entries
      // --------------------------------------------------------------------
       dcl-proc  jrn_tieEntries export;
       dcl-pi jrn_tieEntries;
         lEntries pointer const;
       end-pi;

       dcl-s lVariant pointer;
       dcl-ds Entry likeDs(tEntry) based(pEntry );
       lVariant=tree_getFirst(lEntries);
       dow lVariant<>*null;
         if tree_isofthekind(kEntry:lVariant:pEntry)
         and(entry.det.entt='UP' or entry.det.entt='UR');
           Entry.pEntry0=jrn_tieEntries2(lVariant);
         endIf;
         lVariant=tree_getNexttoDisplay(lEntries:lVariant);
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // link entries (part 2)
      // --------------------------------------------------------------------
       dcl-proc  jrn_tieEntries2;
       dcl-pi jrn_tieEntries2 pointer;
         lEntry pointer const;
       end-pi;

       dcl-ds Entry likeDs(tEntry) based(pEntry);
       dcl-s lEntry0 pointer;
       dcl-ds Entry0 likeDs(tEntry) based(pEntry0);
       pEntry=tree_getItem(lEntry);
       lEntry0=tree_getprev(lEntry);
       dow lEntry0<>*null;
         pEntry0=tree_getItem(lEntry0);
         if entry0.det.OBJ   = Entry.det.OBJ
         and Entry0.det.ctrr = Entry.det.ctrr;
           return pEntry0;
         endif;
         lEntry0=tree_getprev(lEntry0);
       endDo;
       return *null;
       end-proc;
