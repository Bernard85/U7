     h nomain
      /copy cpy,dta7_h
      // --------------------------------------------------------------------
      // variables
      // --------------------------------------------------------------------
     dSeq9             s             10i 0 inz(0)
      // --------------------------------------------------------------------
      // define and open the cursor
      // --------------------------------------------------------------------
     pdta_prepare      b                   export
     d dta_prepare     pi
     d  fileID                       10a   varying const
     d  where                        80a   varying const
     d  orderBy                      80a   varying const
      *
     d sqlStm          s            256a   varying
     d rec             ds                         likeDs(tRec)
      *
       sqlStm='select ''&f'''
             +      ',row_number() over()'
             +      ',rrn(m) '
             + 'from &f m '
             + '&w'
             + '&o';
      *
       sqlStm=%scanRpl('&f':fileID :sqlStm);
       sqlStm=%scanRpl('&w':where  :sqlStm);
       sqlStm=%scanRpl('&o':orderBy:sqlStm);
      *
       exec sql prepare s1 from :sqlStm;
       exec sql declare i1 scroll cursor for s1;
       exec sql open i1;
       // Last row is memorized
       exec sql fetch last from i1 into :rec;
       seq9=rec.seq;
     p                 e
