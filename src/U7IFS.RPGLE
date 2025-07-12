       ctl-opt nomain;

      /copy cpy,u7int_h
      /copy cpy,u7ibm_h
      /copy cpy,u7xml_h
      /copy cpy,u7fmt_h

      // ------------------------------------------------------------------*
      // open ifs for reading
      // --------------------------------------------------------------------
       dcl-proc ifs_openForRead export;
       dcl-pi ifs_openForRead int(10);
         path varchar(255)   const;
       end-pi;

       dcl-s hSTMF int(10) inz(0);
       hSTMF=open(path:O_rdonly+o_TextData);
       return hSTMF;
       end-proc;
      // --------------------------------------------------------------------
      // position in ifs
      // --------------------------------------------------------------------
       dcl-proc  ifs_lSeek export;
       dcl-pi ifs_lSeek int(10);
         hDta    int(10) value;
         offset  int(10) value;
         whence_ int(10) value options(*nopass);
       end-pi;

       dcl-s whence int(10) inz(0);
       if %parms()=3;
         whence=whence_;
       endIf;
       return lseek(hDta:offset:whence);
       end-proc;
      // --------------------------------------------------------------------
      // read ifs
      // --------------------------------------------------------------------
       dcl-proc  ifs_Read export;
       dcl-pi ifs_Read int(10);
         hstmf   int(10) const;
         pBuffer pointer const;
         sBuffer int(10) const;
       end-pi;
       return Read(HSTMF:pbuffer:sBuffer);
       end-proc;
      // --------------------------------------------------------------------
      // open ifs for writing
      // --------------------------------------------------------------------
       dcl-proc ifs_openForWrite export;
       dcl-pi ifs_openForWrite int(10);
         path varchar(255)   const;
       end-pi;

       dcl-s hSTMF int(10) inz(0);
       hSTMF=open(path:O_CREAT+O_WRONLY+O_CODEPAGE:
                  S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH:819);
       priofb=Close(hSTMF);
       hSTMF=open(path:O_WRONLY+O_TEXTDATA+O_Trunc);
       return hSTMF;
       end-proc;
      // --------------------------------------------------------------------
      // open ifs for store
      // --------------------------------------------------------------------
       dcl-proc ifs_openForStore export;
       dcl-pi ifs_openForStore int(10);
         path varchar(255)   const;
       end-pi;

       dcl-s hSTMF int(10) inz(0);
       hSTMF=open(path:O_CREAT+O_WRONLY:
                  S_IWUSR+S_IRUSR+S_IRGRP+S_IROTH);
       priofb=Close(hSTMF);
       hSTMF=open(path:O_WRONLY+           O_Trunc);
       return hSTMF;
       end-proc;
      // --------------------------------------------------------------------
      // close                                                              ----
      // --------------------------------------------------------------------
       dcl-proc  ifs_close export;
       dcl-pi *n;
         hSTMF int(10) const;
       end-pi;
       priofb=close(hSTMF);
       end-proc;
      // --------------------------------------------------------------------
      // write 1 row + crlf
      // --------------------------------------------------------------------
       dcl-proc  ifs_println export;
       dcl-pi ifs_println;
         hSTMF   int(10)        const;
         buffer_ varchar(65535)   const;
       end-pi;

       dcl-s buffer varchar(65535);
       buffer=buffer_+x'0d25';
       priofb=write(hSTMF:%addr(buffer)+2:%len(buffer));
       end-proc;
      // --------------------------------------------------------------------
      // write
      // --------------------------------------------------------------------
       dcl-proc  ifs_print export;
       dcl-pi ifs_print;
         hSTMF   int(10)        const;
         buffer_ varchar(65535)   const;
       end-pi;

       dcl-s buffer varchar(65535);
       buffer=buffer_;
       priofb=write(hSTMF:%addr(buffer)+2:%len(buffer));
       end-proc;
      // --------------------------------------------------------------------
      // Copy bytes
      // --------------------------------------------------------------------
       dcl-proc  ifs_memCpy export;
       dcl-pi ifs_memCpy;
         target pointer Value;
         source pointer Value;
         length uns(10) Value;
       end-pi;
       memCpy(target:source:length);
       end-proc;
      // --------------------------------------------------------------------
      // memory changed ?
      // --------------------------------------------------------------------
       dcl-proc  ifs_memchg export;
       dcl-pi ifs_memchg ind;
         adr1   pointer Value;
         adr2   pointer Value;
         length uns(10) Value;
       end-pi;
       return memCmp(adr1:adr2:length)<>0;
       end-proc;
      // --------------------------------------------------------------------
      // Test a bit
      // --------------------------------------------------------------------
       dcl-proc  ifs_testBit export;
       dcl-pi ifs_testBit ind;
         str    pointer Value;
         offset uns(10) Value;
       end-pi;
       return tstbts(str:offset)<>0;
       end-proc;
      // --------------------------------------------------------------------
      // Set a bit
      // --------------------------------------------------------------------
       dcl-proc  ifs_setbit export;
       dcl-pi ifs_setbit;
         str    pointer Value;
         offset uns(10) Value;
         status ind     const;
       end-pi;
       if status;
         setbts(str:offset);
       else;
         clrbts(str:offset);
       endIf;
       end-proc;
      // --------------------------------------------------------------------
      // Browse files in a folder
      // --------------------------------------------------------------------
       dcl-proc ifs_browseFiles export;
       dcl-pi ifs_browseFiles;
         path      pointer        const options(*string);
         pProcFile pointer(*proc) const;
       end-pi;

       dcl-s pDir pointer;
       dcl-ds dirEnt likeDs(tDirEnt) based(pDirEnt);
       dcl-ds statDs likeDs(tStatDS);
       dcl-s wPath varchar(255);

       dcl-pr procFile extproc(pProcFile);
         wPAth varchar(255) const;
       end-pr;
       // Open and read folder
       pDir=OpenDir(path);
       dow pDir<>*null;
         pDirEnt=readDir(pDir);
         if pDirEnt=*null;
           leave;
         endIf;
         //
         if DirEnt.Name='.' or DirEnt.Name='..' or DirEnt.Name='';
           iter;
         endif;
         //
         wPath=%str(path)+DirEnt.Name;
         stat(wPath:statds);
         if statds.objtype='*STMF';
           procFile(DirEnt.Name);
         endIf;
       endDo;
       CloseDir(pDir);
       end-proc;
      // --------------------------------------------------------------------
      // get file extension
      // --------------------------------------------------------------------
       dcl-proc ifs_getFileExtension export;
       dcl-pi ifs_getFileExtension varchar(10);
         path varchar(255) const;
       end-pi;

       dcl-s p uns(3);
       p=int_scanR('.':path);
       if p=0 or p=%len(path);
         return '';
       endIf;
       return %subst(path:p+1);
       end-proc;
