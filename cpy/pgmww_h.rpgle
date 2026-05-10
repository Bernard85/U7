     d xButDs          ds
     d       xBut01
     d       xBut02
     d       xBut03
     d       xBut04
     d       xBut05
     d       xBut06
     d       xBut07
     d       xBut08
     d       xButs                           like(xBut01) dim(8)
     d                                      overlay(xButds)
     d xOptDs          ds
     d       xopt01
     d       xopt02
     d       xopt03
     d       xopt04
     d       xopt05
     d       xopt06
     d       xopt07
     d       xopt08
     d       xopts                           like(xopt01) dim(8)
     d                                      overlay(xoptds)
     d  pxfilDs        ds
     d      pxfil01                    *    inz(%addr(xfil01))
     d      pxfil02                    *    inz(%addr(xfil02))
     d      pxfil03                    *    inz(%addr(xfil03))
     d      pxfil04                    *    inz(%addr(xfil04))
     d      pxfil05                    *    inz(%addr(xfil05))
     d      pxfil06                    *    inz(%addr(xfil06))
     d      pxfil07                    *    inz(%addr(xfil07))
     d      pxfil08                    *    inz(%addr(xfil08))
     d      pxFils                     *    dim(8) overlay(pxfilds)
      // pgm family
       dcl-c kRoot 'r';
       dcl-c kPgm  'p';
      // root
       dcl-ds tRoot qualified;
         kind char(1) inz(kRoot);
         id   varChar(30);
         title varChar(80);
       end-ds;
      // pgm
       dcl-ds tPgm qualified;
         kind char(1)     inz(kPgm);
         ID   varchar(10) ;
         text varchar(128);
       end-ds;
      // get item for PGM family
       dcl-pr pgm_XMLinput pointer;
         ND    likeDs(xml_nodeDefine) const;
         lItem pointer                const;
       end-pr;
