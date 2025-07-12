      // open ifs for reading
       dcl-pr ifs_openForRead int(10);
         path varchar(255)   const;
       end-pr;
      // position in stmf
       dcl-pr ifs_lSeek int(10);
         hDta    int(10) value;
         offset  int(10) value;
         whence_ int(10) value options(*nopass);
       end-pr;
      // read ifs
       dcl-pr ifs_Read int(10);
         hstmf   int(10) const;
         pBuffer pointer const;
         sBuffer int(10) const;
       end-pr;
      // open ifs for writing
       dcl-pr ifs_openForwrite int(10);
         path varchar(255) const ;
       end-pr;
      //  open ifs for storing
       dcl-pr ifs_openForStore int(10);
         path varchar(255)  const;
       end-pr;
      // Close IFS
       dcl-pr ifs_close;
         hSTMF int(10) const;
       end-pr;
      // Write one line
       dcl-pr ifs_println;
         hSTMF  int(10)        const;
         buffer varchar(65535) const ;
       end-pr;
      // Write String
       dcl-pr ifs_print;
         hSTMF  int(10)        const;
         buffer varchar(65535) const ;
       end-pr;
      // Copy bytes
       dcl-pr ifs_memCpy;
         target pointer Value;
         source pointer Value;
         length uns(10) Value;
       end-pr;
      // memory changed
       dcl-pr ifs_memchg ind;
         adr1   pointer Value;
         adr2   pointer Value;
         length uns(10) Value;
       end-pr;
      // Test a bit
       dcl-pr ifs_testBit ind;
         str    pointer Value;
         offset uns(10) Value;
       end-pr;
      // Set a bit
       dcl-pr ifs_setbit;
         str    pointer Value;
         offset uns(10) Value;
         status ind     const;
       end-pr;
      // Browse files in a folder
       dcl-pr ifs_browseFiles;
         path      pointer        const options(*string);
         pProcFile pointer(*proc) const ;
       end-pr;
      // get file extension
       dcl-pr ifs_getFileExtension varchar(10);
         path varchar(255) const ;
       end-pr;
