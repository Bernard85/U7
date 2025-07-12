       ctl-opt option(*noshowcpy) nomain;
      /copy cpy,u7ibm_h
      // -------------------------------------------------------------------
      // Send program message
      // -------------------------------------------------------------------
       dcl-proc  msg_SndPM export;
       dcl-pi *n;
         pn char(10)  const;
         mt char(130) const;
       end-pi;
       QMHSNDPM('':'':mt:%len(mt):'*INFO':pn:0:' ':ApiErr);
       end-proc;
      // -------------------------------------------------------------------
      // Remove all program messages
      // -------------------------------------------------------------------
       dcl-proc  msg_RmvPM export;
       dcl-pi *n;
         pn char(10) const;
       end-pi;
       Qmhrmvpm(pn:0:' ':'*ALL':ApiErr);
       end-proc;
      // -------------------------------------------------------------------
      // Send message text to user
      // -------------------------------------------------------------------
       dcl-proc  msg_SndM export;
       dcl-pi msg_SndM;
         mi char(7)      const;
         md varchar(256) const;
       end-pi;

       dcl-s mk char(4);
       dcl-s mf char(20) inz('QCPFMSG   QSYS');
       qmhsndm(mi:mf:md:%len(md):'*DIAG':pgmsts.user+'*LIBL':1:'':mk:ApiErr);
       end-proc;
