     h DFTACTGRP(*NO) bnddir('U7') actgrp('CHIKO')
     fformula$d cf   e             WORKSTN

      /copy cpy,u6env_h
      /copy cpy,u6fmt_h
      /copy cpy,u6fILE_h
      /copy cpy,U6int_H
      /copy cpy,u6tree_h
      /copy cpy,u6xml_h


      // open file
     d  hFile          s               *
     D Ropen           Pr              *   ExtProc('_Ropen' )
     D  pRFile                         *   Value Options(*String)
     D  pMode                          *   Value Options(*String)
      // close file
     D Rclose          Pr            10i 0 ExtProc('_Rclose')
     D  pRFile                         *   Value
      // read by rrn
     dRreadd           pr              *   extproc('_Rreadd')
     d hInFile                         *   value
     d pInBuf                          *   value
     d InBufSx                       10i 0 value
     d InOpts                        10i 0 value
     d InRrn                         10i 0 value
      // read first
     dRreadf           pr              *   extproc('_Rreadf')
     d hInFile                         *   value
     d pInBuf                          *   value
     d InBufSx                       10i 0 value
     d InOpts                        10i 0 value
     **-- I/O feedback structure:  -------------------------------------------**
     D RIOFB           Ds                  Based(pRIOFB$)
     D  pKey                           *
     D  pSysParm                       *
     D  IoRcdRrn                     10u 0
     D  IoNbrBytRw                   10i 0
     D  IoBlkCnt                      5i 0
     D  IoBlkFllBy                    1a
     D  IoBitFld                      1a
     D  IoRsv                        20a
     d FORMULA$        ds          2000     dtaara(FORMULA$)
     d  formula
     d  zfile
     d  zWhere
     d g               ds                   qualified
     d  lFmt                           *
     d  lFormula                       *
     d  buffer                     2000a
      *
     d  rcd            ds                  likeds(tRcd)
      // for storing
     d  tRcd           ds                  qualified
     d   FileID                      10a   varying
     d   rrn                         10u 0
      // for storing
     d zFile$          s                   like(zFile)
     d zWhere$         s                   like(zWhere)
     d formula$$       s                   like(formula)
     d  priofb         s             10u 0
      // ------------------------------------------------------------------
      // main
      // ------------------------------------------------------------------
       // begin of program
       in *lock formula$;
       int_loadProcs();
       // loop
       dow 1=1;
         exfmt hdr1;
         // F3=Exit
         if *inkc;
           leave;
         endIf;
         // F12=Cancel
         if *inkl;
           leave;
         endIf;
         // load data
         if zFile<>zFile$;
           close_();
           open_(%trim(zFile));
         endif;
         if zFile<>zFile$ or zWhere<>zWhere$;
           zFile$=zFile;
           zWhere$=zWhere;
           loadData(%trim(zFile):%trim(zWhere));
         endIf;
         // resolve the formula
         if formula<>formula$$;
           formula$$=formula;
           g.lFormula=int_FormulaLoad(formula:g.lFmt);
         endIf;
         // apply the formula
         result1=int_FormulaExec(g.lFormula);
       endDo;
       // end of program
       out formula$;
       close_();
       *inlr=*on;
      // ------------------------------------------------------------------
      // load
      // ------------------------------------------------------------------
     pLoadData         b
     d loadData        pi
     d  wFile                        10a   varying const
     d  wWhere                       50a   varying const
      *
     d p               s               *
     d sqlStm          s           2000a   varying
     d lFile           s               *
     d file            ds                  likeDs(tFile) based(pFile)
     d fmtID           s             10a   varying
     d fmt             ds                  likeDs(tFormat) based(pFmt)
       // get the format of the file
       lFile=xml_xml2tree(env_getclientPath()+'3fg/'+wFile+'.file'
                         :%paddr(file_xmlInput));
       pFile=tree_getItem(lFile);
       fmtID=file.format;
       // get the format of the file
       g.lFmt=xml_xml2tree(env_getclientPath()+'3fg/'+FmtID+'.fmt'
                          :%paddr(fmt_xmlInput));
       pFmt=tree_getItem(g.lFmt);
       // plug the buffer data to the format
       fmt.pBuffer1=%addr(g.buffer);
       // define the SQL statement
       sqlStm='select '''+wFile+''', rrn(x)'
             +' from ' +wFile+' x';
       if wWhere<>'';
         SqlStm+=' where '+wWhere;
       endIf;
       // prepare the SQL statement
       exec sql prepare s1 from :sqlstm;
       exec sql declare C1    cursor for s1;
       exec sql open C1;
       clear rcd;
       exec sql fetch NEXT from C1 into :rcd;
       exec sql close C1;
      *
       pRIOFB$=rreadd(hFile:%addr(g.buffer)
            :fmt.len:x'00000001':rcd.rrn);
     p                 e
      // ------------------------------------------------------------------
      // open the file
      // ------------------------------------------------------------------
     popen_            b
     d open_           pi
     d  fileID                       10a   varying const
       hFile=rOpen(FileID:'rr,nullcap=Y');
     p                 e
      // ------------------------------------------------------------------
      // close the file
      // ------------------------------------------------------------------
     pclose_           b
     d close_          pi
       if hFile<>*null;
         priofb=rClose(hFile);
       endif;
     p                 e
