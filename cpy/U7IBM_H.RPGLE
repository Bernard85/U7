      /copy cpy,u7ds_h
      // ------------------------------------------------------------------*
      // Command-related
      // -------------------------------------------------------------------
      // Command execute
       dcl-pr qcmdexc extpgm('QCMDEXC');
         cmd    char(1024)   const;
         cmdLen packed(15:5) const;
       end-pr;
      // -------------------------------------------------------------------
      // Memory related
      // -------------------------------------------------------------------
      // Copy bytes
       dcl-pr memcpy ExtProc('__memcpy');
         target pointer Value;
         source pointer Value;
         length uns(10) Value;
       end-pr;
      // Compare bytes
       dcl-pr memcmp int(10) ExtProc('__memcmp');
         adr1   pointer Value;
         adr2   pointer Value;
         length uns(10) Value;
       end-pr;
      // Set bytes
       dcl-pr memset  ExtProc('__memset');
         pData      pointer Value;
         cCharToSet char(1) Value;
         nByteCount int(10) Value;
       end-pr;
      // test a bit
       dcl-pr tstbts int(10) ExtProc('tstbts');
         str    pointer Value;
         offset uns(10) Value;
       end-pr;
      // Clear Bit in String
       dcl-pr clrbts extproc('_CLRBTS');
         str    pointer value;
         offset uns(10) value;
       end-pr;
      // Set Bit in String
       dcl-pr setbts extproc('_SETBTS');
         str    pointer value;
         offset uns(10) value;
       end-pr;
      // -------------------------------------------------------------------
      //  Integrated File System API
      // -------------------------------------------------------------------
      // Open file
       dcl-pr open int(10) extproc('open');
         path     pointer value options(*string);
         oflag    int(10) value;
         mode     uns(10) value options(*nopass);
         codepage uns(10) value options(*nopass);
       end-pr;
      // owner authority
       dcl-c S_IRUSR 256;
       dcl-c S_IWUSR 128;
       dcl-c S_IXUSR 64;
      // group authority
       dcl-c S_IRGRP 32;
       dcl-c S_IWGRP 16;
       dcl-c S_IXGRP 8;
      // other people
       dcl-c S_IROTH 4;
       dcl-c S_IWOTH 2;
       dcl-c S_IXOTH 1;
      // Flags for use in open()
       dcl-c O_RDONLY   1;
       dcl-c O_WRONLY   2;
       dcl-c O_RDWR     4;
       dcl-c O_CREAT    8;
       dcl-c O_EXCL     16;
       dcl-c O_TRUNC    64;
       dcl-c O_APPEND   256;
       dcl-c O_CODEPAGE 8388608;
       dcl-c O_TEXTDATA 16777216;
       dcl-c O_CCSID    32;
      // positon
       dcl-pr lseek int(10) ExtProc('lseek');
         handle int(10) value;
         offset int(10) value;
         whence int(10) value;
       end-pr;
      // Read IFS
       dcl-pr read int(10) extproc('read');
         *n int(10) value;
         *n pointer value;
         *n uns(10) value;
       end-pr;
      // Write file
       dcl-pr write int(10) extproc('write');
         *n int(10) value;
         *n pointer value;
         *n uns(10) value;
       end-pr;
      // close file
       dcl-pr close int(10) extproc('close');
         *n int(10) value;
       end-pr;
      // -------------------------------------------------------------------
      //  process directory
      // -------------------------------------------------------------------
      // directory entry
       dcl-ds tDirEnt qualified template;
         reserv1       char(16)    ;
         fileno_gen_id uns(10)     ;
         fileno        uns(10)     ;
         reclen        uns(10)     ;
         reserv3       int(10)     ;
         reserv4       char(8)     ;
         nlsinfo       char(12)    ;
         nls_ccsid     int(10)      OVERLAY(nlsinfo:1);
         nls_cntry     char(2)      OVERLAY(nlsinfo:5);
         nls_lang      char(3)      OVERLAY(nlsinfo:7);
         w2            char(2)     ;
         name          varchar(640);
       end-ds;
      // open directory
       dcl-pr opendir pointer EXTPROC('opendir');
         dirname pointer VALUE options(*string);
       end-pr;
      // read directory
       dcl-pr readdir pointer EXTPROC('readdir');
         dirp pointer VALUE;
       end-pr;
      // close directory
       dcl-pr closedir int(10) EXTPROC('closedir');
         dirp pointer VALUE;
       end-pr;
      // Stat on a read item
       dcl-pr stat int(10) ExtProc('stat');
         path pointer value options(*string);
         buf         likeds(tStatDS);
       end-pr;
      // bounded to stat proc
       dcl-ds tStatDS qualified template;
         mode       uns(10) ;
         ino        uns(10) ;
         nlink      uns(5)  ;
         reserved2  uns(5)  ;
         uid        uns(10) ;
         gid        uns(10) ;
         size       int(10) ;
         atime      int(10) ;
         mtime      int(10) ;
         ctime      int(10) ;
         dev        uns(10) ;
         blksize    uns(10) ;
         allocsize  uns(10) ;
         objtype    char(10);
         reserved3  char(2) ;
         codepage   uns(5)  ;
         ccsid      uns(5)  ;
         rdev       uns(10) ;
         nlink32    uns(10) ;
         rdev64     uns(20) ;
         dev64      uns(20) ;
         reserved1  char(36);
         ino_gen_id uns(10) ;
       end-ds;
      *
       dcl-s priofb uns(10);
      // -------------------------------------------------------------------
      // Message
      // -------------------------------------------------------------------
      // Remove program message
       dcl-pr qmhrmvpm extpgm('QMHRMVPM');
         *n     char(276)   const;
         *n     bindec(9:0) const;
         *n     char(4)     const;
         *n     char(10)    const;
         apiErr            like(tApiErr);
       end-pr;
      // Send program message
       dcl-pr qmhsndpm extpgm('QMHSNDPM');
         *n     char(7)     const;
         *n     char(20)    const;
         *n     char(32767) Const Options(*Varsize);
         *n     bindec(9:0) const;
         *n     char(10)    const;
         *n     char(10)    const;
         *n     bindec(9:0) const;
         *n     char(4)     const;
         apiErr            like(tApiErr);
       end-pr;
      // Send message
       dcl-pr QMHSNDM ExtPgm('QMHSNDM');
         MsgID     char(7)     const;
         QualMsgF  char(20)    const;
         MsgTxt    char(32767) const options(*varsize);
         MsgTxtLen int(10)     const;
         MsgType   char(10)    const;
         MsgQueues char(20)    const dim(50) options(*varsize);
         NumQueues int(10)     const;
         RpyQueue  char(20)    const;
         MsgKey    char(4)    ;
         apiErr               like(tApiErr);
         CCSID     int(10)     const options(*nopass);
       end-pr;
      // -------------------------------------------------------------------
      // user space
      // -------------------------------------------------------------------
      // Create user space:
       dcl-pr QUSCRTUS ExtPgm('QUSCRTUS');
         *n char(20)    Const;
         *n char(10)    Const;
         *n int(10)     Const;
         *n char(1)     Const;
         *n char(10)    Const;
         *n char(50)    Const;
         *n char(10)    Const Options(*NoPass);
         *n char(32767) Options(*NoPass:*Varsize);
       end-pr;
      // get pointer on user space
       dcl-pr QUSPTRUS ExtPgm('QUSPTRUS');
         UsrSpc  char(20) CONST;
         Pointer pointer ;
       end-pr;
      // delete user space
       dcl-pr QUSDLTUS ExtPgm('QUSDLTUS');
         *n char(20)    Const;
         *n char(32767) Options(*VarSize);
       end-pr;
      // -------------------------------------------------------------------
      // object + file description
      // -------------------------------------------------------------------
      // Retrieve object description
       dcl-pr QUSROBJD_ ExtPgm('QUSROBJD');
         RcvVar    char(32767) Options(*VarSize);
         RcvVarLen int(10)     Const;
         FmtNam    char(8)     Const;
         ObjNamQ   char(20)    Const;
         ObjTyp    char(10)    Const;
         Err       char(32767) Options(*VarSize);
       end-pr;
      // list field description
       dcl-pr quslfld_ ExtPgm('QUSLFLD');
         SpcNamQ    char(20)    Const;
         FmtNam     char(8)     Const;
         FilNamQual char(20)    Const;
         RcdFmtNam  char(10)    Const;
         OvrPrc     char(1)     Const;
         err        char(32767) Options(*NoPass:*Varsize);
       end-pr;
      // -------------------------------------------------------------------
      // Dtaara proces
      // -------------------------------------------------------------------
      // Retrieve dtaara
       dcl-pr qxxrtvda extpgm('QXXRTVDA');
         dtaaraid char(20)   const;
         p        int(10)    const;
         l        int(10)    const;
         w2000    char(2000);
       end-pr;
      // change dtaara
       dcl-pr qxxchgda extpgm('QXXCHGDA');
         dtaaraid char(20)   const;
         p        int(10)    const;
         l        int(10)    const;
         w2000    char(2000);
       end-pr;
      // -------------------------------------------------------------------
      // Date manage
      // -------------------------------------------------------------------
       dcl-pr Qwccvtdt extpgm('QWCCVTDT');
         *n char(10) const;
         *n char(8) ;
         *n char(10) const;
         *n char(16);
         b          like(ApiErr);
       end-pr;
