      // Record type
     d tRec            ds                         qualified template
     d  fileName                     10a
     d  seq                          10i 0
     d  rrn                          10i 0
      // define and open the cursor
     d dta_prepare     pr
     d  fileID                       10a   varying const
     d  where                        80a   varying const
     d  orderBy                      80a   varying const
