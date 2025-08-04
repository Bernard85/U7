      // Shell family
     d kScreens        c                   const('S')
     d kScreen         c                   const('s')
     d kArea           c                   const('a')
      // Shells type
     d tScreens        ds                  qualified
     d  kind                          1    inz(kScreens)
     d  lCurScreen                     *   inz(*null)
      // Shell type
     d tScreen         ds                  qualified inz
     d  kind                          1    inz(kScreen)
     d  ID                           10    varying
     d  cmdBuf                       10i 0
     d  InpBuf                       10i 0
     d  lFKS                           *
     d  pGetter                        *   procPtr inz(*null)
     d  pSetter                        *   procPtr inz(*null)
     d  pChecker                       *   procPtr inz(*null)
     d  toRefresh                      n   inz(*on)
      // area type
     d tArea           ds                  qualified  inz
     d  kind                          1a   inz(kArea)
     d  ID                           10a   varying
     d  x                             3u 0
     d  y                             3u 0
     d  height                        3u 0
     d  width                         3u 0
     d  rX                            3u 0
     d  rY                            3u 0
     d  cmdBuf                       10i 0
     d  toRefresh                      n   inz(*on)
     d  pDefiner                       *   procPtr inz(*null)
      // function key
       dcl-c   kFK 'k';
       dcl-ds tFK qualified;
         kItem    char(1) inz(kFK);
         key      varChar(1);
         fControl ind       ;
         pAction  pointer(*proc);
       end-ds;
      // function key context
       dcl-c   kContext 'c';
       dcl-ds tFKc qualified;
         kItem    char(1) inz(kContext);
         ID       varChar(1);
         text     varChar(30);
       end-ds;
      // input field
     d tFld            ds                  qualified         inz
     d  yx
     d   y                           10i 0 inz(0) overlay(yx)
     d   x                           10i 0 inz(0) overlay(yx:*next)
     d  length                        3u 0 inz(0)
     d  lItem                          *   inz(*null)
     d  origin                        1a   inz('')
     d  fMDT                           n   inz(*off)
     d  defAtr                        1a   inz(QSN_SA_GRN_UL)
      // box to store messages
     d msgBox          ds                  qualified
     d  msgSeq                        3u 0 inz(1)
     d  msgMax                        3u 0 inz(1)
     d  msgTxt                      130    dim(300) inz('')
      // define screen
     d dsm_setScreen   pr              *
     d  lScreens                       *
     d  screenID                     10a   varying                         const
     d  pCliGetter                     *   procptr                         const
     d  pCliTweaker                    *   procptr                         const
     d  pCliChecker                    *   procptr                         const
      // define area
     d dsm_setArea     pr              *
     d  lScreen                        *   const
     d  ID                           10a   const
     d  y                             3u 0 const
     d  x                             3u 0 const
     d  height                        3u 0 const
     d  width                         3u 0 const
     d  pDefiner                       *   const procPtr
      // set new function key
       dcl-pr dsm_SetFK;
         lScreen   pointer        const;
         key       char(1)        const;
         fControl  ind            const;
         pAction   pointer(*proc) const;
         text0     varChar(30)    const options(*nopass);
         text1     varChar(30)    const options(*nopass);
       end-pr;
      // get function key context
       dcl-pr dsm_getFKC char(1);
         lScreens pointer    const;
         key      varchar(1) const;
       end-pr;
      // get function key text
       dcl-pr dsm_getfktext varchar(123);
         lScreens pointer const;
       end-pr;
      // clear and initialize the screen
     d Dsm_ClrScr      pr
      // clear area
     d dsm_ClearArea   pr
     d  lArea                          *                                   const
      // refresh requested
     ddsm_AreaRefresh  pr
     d  lArea                          *   const
     d  toRefresh                      n   const options(*nopass)
      // print text in area
     d dsm_print       pr
     d  lArea                          *                                   const
     d  atr1                          1a                                   const
     d  text                        100a   varying                         const
      // print text in area
     d dsm_println     pr
     d  lArea                          *                                   const
     d  atr1                          1a                                   const
     d  text                        100a   varying                         const
      // print field in area
     d dsm_printFld    pr
     d  lArea                          *   const
     d  length                        3u 0 const
     d  lItem                          *   const
     d  origin                        1a   const
     d  fldVal                      255a   const options(*nopass)
     d  fMDT                           n   const options(*nopass)
      // receive program message to dedicated box
     ddsm_rcvpm        pr
     d  pn                           10    const
      // Display the screen
     ddsm_DspScr       pr
     d  lScreen                        *   const
      // 
     d dsm_go          pr
     d  pgmID                        10a            const
     d  lScreens                       *
     d  screenID                     10a   varying  const
      // set current screen
     ddsm_setCurScreen...
     d                 pr
     d  lScreens                       *                               const
     d  screenID                     10a   varying                     const
      // refresh current screen
     d dsm_refresh     pr
     d  lScreens                       *   const
