      // Shell family
     d kShells         c                   const('H')
     d kShell          c                   const('h')
     d kLayouts        c                   const('Y')
     d kLayout         c                   const('y')
      // Shells type
     d tShells         ds                  qualified
     d  kind                          1    inz(kShells)
      // Shell type
     d tShell          ds                  qualified
     d  kind                          1    inz(kShell)
     d  ID                           10    varying
     d  InpBuf                       10i 0
     d  fldSeq                        3u 0 inz(0)
     d  fldRep                             dim(25) likeDs(tFldRep)
      // Layout type
     d tLayout         ds                  qualified
     d  kind                          1    inz(kLayout)
     d  ID                           10    varying
     d  toRefresh                      n   inz(*off)
     D  x                             3u 0
     d  y                             3u 0
     D  height                        3u 0
     d  width                         3u 0
     D  rX                            3u 0
     d  rY                            3u 0
     d  cmdBuf                       10i 0
     d* InpBuf                       10i 0
      // base type to memorise
     d tFldRep         ds                  qualified
     d   yx
     d     y                         10i 0 overlay(yx)
     d     x                         10i 0 overlay(yx:*next)
     d   pItem                         *
     d   fMDT                          n   inz(*off)
      // get shell
     d dsm_getShell    pr              *
     d  lShells                        *
     d  shellID                      10a   const varying
      // get layout
     d dsm_getLayout   pr              *
     d  lShell                         *   const
     d  layoutID                     10a   const varying
     d  y                             3u 0 const
     d  x                             3u 0 const
     d  height                        3u 0 const
     d  width                         3u 0 const
      // get layout by ID
     d dsm_getLayoutByID...
     d                 pr              *
     d  lShell                         *   const
     d  layoutID                     10a   varying const
      // clear layout
     d dsm_ClearLayout...
     d                 pr
     d lLayout                         *                                   const
      // init shell
     d dsm_initShell   pr
     d lShell                          *                                   const
      // init layout
     d dsm_initLayout...
     d                 pr
     d lLayout                         *                                   const
      // Print text in layout + LF + CR
     d dsm_printLN     pr
     d  lLayout                        *                                   const
     d  atr1                          1a                                   const
     d  text                       1000a   varying                         const
     d  y                             3u 0 options(*nopass)
      // Print text in layout
     d dsm_print       pr
     d  lLayout                        *                                   const
     d  atr1                          1a                                   const
     d  text                        100a   varying                         const
      // print field in layout
     d dsm_printFld    pr
     d  lLayout                        *                                   const
     d  atr1                          1a                                   const
     d  fldAtr                        2a                                   const
     d  value                       100a   varying                         const
     d  pFld                           *                                   const
      // try top print panel in layout
     d dsm_printPanelLN...
     d                 pr
     d  lLayout                        *                                   const
     d  lPanel                         *                                   const
      // try to print label in layout
     d dsm_printlabelLN...
     d                 pr
     d  lLayout                        *                                   const
     d  lLabel                         *                                   const
     d  dspFormula_                    n   options(*nopass)                const
     d  editable_                      n   options(*nopass)                const
      // clear the remain from position in a layout
     ddsm_padLayout    pr
     d lLayout                         *                                   const
      // Display the screen
     d dsm_DspScr      pr
     d  lShell                         *                                   const
     d  forceRefresh_                  n   options(*nopass)                const
      // clear and intialize the screen
     d dsm_ClrScr      pr
      // read modified fields
     d dsm_ReadMdt     pr
     d  lShell                         *                                   const
     d  lLayout                        *                                   const
     d  pClientRead                    *   procPtr                         const
      // get function key
     d dsm_getAID      pr             1a
     d  lShell                         *                                   const
     d  lLayout                        *                                   const
     d  csrx                         10i 0
     d  csry                         10i 0
     d  pClientRead                    *   procPtr                         const
      // roll up
     d dsm_rollup      pr              *
     d  lLayout                        *                                   const
     d  lRoot                          *                                   const
     d  lRow1Old                       *                                   const
      // get Row at position
     d dsm_getRowAt    pr              *
     d  lList                          *                                   const
     d  lRoot                          *                                   const
     d  lRow1                          *                                   const
     d  lRow9                          *                                   const
     d  csrY                         10i 0                                 const
      // control
     d dsm_control     pr              n
     d  lShell                         *                                   const
     d  pCliCon                        *   procptr                         const
      // can print
     d dsm_CanPrint    pr              n
     d  lLayout                        *                                   const
      // Position on field
     ddsm_PosOnField   pr
     d lShell                          *                                   const
     d lLayout                         *                                   const
     d pItem                           *
