      // Send program message
       dcl-pr msg_SndPM;
         pn char(10)  const;
         mt char(130) const;
       end-pr;
      // Remove all program message
       dcl-pr msg_RmvPM;
         pn char(10) const;
       end-pr;
      // Send message text to user
       dcl-pr msg_SndM;
         mi char(7)      const;
         md varchar(256) const ;
       end-pr;
      // Remove all program message
       dcl-pr msg_RcvPM;
         pn char(10) const;
       end-pr;
