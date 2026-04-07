       ctl-opt DFTACTGRP(*NO) bnddir('U7');
       ctl-opt option(*NOSHOWCPY);
       dcl-f jrnentdpd WORKSTN SFILE(SFL1:SFlRRN) InfDS(wsDS);
      /copy cpy,u7DS_h
      /copy cpy,u7file_h
      /copy cpy,u7fmt_h
      /copy cpy,u7form_h
      /copy cpy,u7int_h
      /copy cpy,u7msg_h
      /copy cpy,u7screen_h
      /copy cpy,u7screen_s
      /copy cpy,u7Tree_h
      /copy cpy,u7XML_h
      /copy cpy,u7YView_h
      // -------------------------------------------------------------------
      // main
      // -------------------------------------------------------------------
       dcl-pi jrndtarp2;
         rtnCode  int(3)      ;
         option   char(1)      const;
         lYViews  pointer     ;
         lFmts    pointer     ;
         lForms   pointer     ;
       end-pi;
      // Anchors
       dcl-ds A qualified;
         lFKs pointer;
       end-ds;
      // Global
       dcl-ds G qualified;
         pScreen pointer(*proc);
         item                  dim(23) likeDs(tItem);
         armTop                likeDs(tArm);
         rcdChg  ind           ;
       end-ds;
      // item
       dcl-ds tItem qualified;
         lVariant pointer;
         segment  uns(5) ;
       end-ds;
      //
       dcl-s lYView pointer;
       dcl-ds YView likeDs(tYView) based(pYView);
       dcl-s lFile pointer;
       dcl-ds file     likeDs(tFile) based(pFile);
       dcl-ds fmt      likeDs(tFormat) based(pFmt);
       // Load function keys
       screen_setFK(a.lFKs:x'f1':'0':%pAddr(Enter));
       screen_setFK(a.lFKs:x'33':'0':%pAddr(F3):'F3=Exit');
       screen_setFK(a.lFKs:x'39':'0':%paddr(F9):'F9=Journal':'F9=Data   ');
       screen_setFKcontext(a.lFKs:x'39':%char(%int(option='j')));
       screen_setFK(a.lFKs:x'3a':'0':%pAddr(f10):'F10=Move top');
       screen_setFK(a.lFKs:x'3b':'0':*null:'F11=Formula':'F11=Value');
       screen_setFK(a.lFKs:x'f4':'0':%pAddr(rollUP));
       screen_setFK(a.lFKs:x'f5':'0':%pAddr(rolldown));
       wrkScreens();
       *inlr=*on;
      // --------------------------------------------------------------------
      // boucle écrans
      // --------------------------------------------------------------------
       dcl-proc  wrkScreens;
       dcl-pr Screen extproc(g.pScreen);
       end-pr;
       // F9=Chargement
        F9();
       // Activation de l'écran 1
       g.pScreen=%paddr(Screen1);
       // Boucle sur les écrans
       dow g.pScreen<>*null;
         screen();
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // Ecran 1
      // --------------------------------------------------------------------
       dcl-proc  Screen1;
       dcl-s cond1 ind;
       dcl-s cond2 ind;
       dcl-ds label likeDs(tLabel) based(pLabel);
       // Rafraichissement
       if YView.armTop<>g.armTop or screen_FKsToRefresh();
         zFK=screen_getfkentitle(a.lFKs);
         g.armTop=YView.armTop;
         loadSFL();
         // Fin des données ?
         if tree_isofthekind(kLabel:YView.armBot.lVariant:pLabel);
           cond1=YView.armBot.segment=%int((label.maxWidth-1)/70);
         else;
           cond1=*on;
         endIf;
         cond2=tree_getNextToDisplay(YView.lForm
                                    :YView.armBot.lVariant)=*null;
         screen_setSflEnd(mySflEnd:cond1 and cond2);
       endif;
       // Affichage
       write msgCtl;
       write hdr1;
       sflDsp=*on;
       sflClr=*off;
       exfmt ctl1;
       msg_rmvPM(pgmID);
       csrtorow=0;
       csrtocol=0;
       // Traitement des touches de fonctions
       screen_processFK(pgmID:a.lFKs:wsds.kp:*null);
       end-proc;
      // --------------------------------------------------------------------
      // Chargement du sous-fichier
      // --------------------------------------------------------------------
       dcl-proc  loadSfl;
       dcl-pi loadSfl end-pi;
      *
       dcl-s lVariant pointer   ;
       dcl-s lPanel$  pointer   ;
       dcl-s lLabel$  pointer   ;
       dcl-s LabelChg ind       ;
       dcl-s PanelChg ind       ;
       dcl-s SegChg   ind       ;
       dcl-s NO       zoned(4:0) inz(0);
       dcl-s segment  int(5)    ;
       dcl-s s        int(5)    ;
       dcl-s s0       int(5)    ;
       dcl-s s9       int(5)    ;
       dcl-ds label likeDs(tLabel) based(pLabel);
       dcl-s String1       char(32000);
       dcl-s String2       char(32000);
       dcl-s Segment1      char(70)   ;
       dcl-s Segment2      char(70)   ;
       dcl-s remainingRows uns(3)     ;
       dcl-s NecessaryRows uns(3)     ;
       // Effacement
       sflClr=*on;
       sflDsp=*off;
       WRITE ctl1;
       lVariant=g.armTop.lVariant;
       // Chargement du panel
       if tree_getKind(lVariant)=kPanel;
         lPanel$=lVariant;
       else;
         lPanel$=tree_getParent(lVariant);
       endIf;
       PanelChg=*on;
       s0=g.armTop.segment;
       // Boucle sur les éléments
       dow lVariant<>*null;
         if tree_isofthekind(kLabel:lVariant:pLabel);
           labelChg=*on;
           // load value(s) for the label
           if g.rcdChg;
             string2=int_FormulaExec(label.lFormula:0);
             string1=int_FormulaExec(label.lFormula:1);
           else;
             string1=int_FormulaExec(label.lFormula:1);
           endIf;
           // Boucle sur les segments
           s9=(label.maxWidth-1)/70;
           for s=s0 to s9;
             // Chargement d'un segment (avant/après)
             SegChg=cmpSegments(label:String1:String2:s);
             // check if enought space avalaible
             remainingRows=23-NO;
             NecessaryRows=%int(PanelChg)*2+%int(SegChg)*1+1;
             if remainingRows<NecessaryRows;
               return;
             endIf;
             // Print new panel
             if PanelChg;
               printPanel(NO:lPanel$);
               PanelChg=*off;
             endIf;
             // Print segment
             printSegment(NO:lVariant:labelChg:SegChg:String1:string2:s);
             labelChg=*off;
           endFor;
         endIf;
         s0=0;
         lVariant=tree_getNextToDisplay(YView.lForm:lVariant);
         // new panel?
         if tree_isOfTheKind(kPanel:lVariant);
           lPanel$=lVariant;
           PanelChg=*on;
         endIf;
       endDo;
       end-proc;
      // --------------------------------------------------------------------
      // comparaisons de 2 segments (avant/après)
      // --------------------------------------------------------------------
       dcl-proc  cmpSegments;
       dcl-pi cmpSegments ind;
         label              const likeDs(tLabel);
         string1 char(32000) const;
         string2 char(32000) const;
         segment int(5)      const;
       end-pi;
      *
       dcl-s pos    uns(5);
       dcl-s length int(3);
       if not g.rcdChg;
         return *off;
       endIf;
       pos=segment*70+1;
       length=int_getMin(70:label.maxwidth-segment*70);
       return %subst(string1:pos:length)
            <>%subst(string2:pos:length);
       end-proc;
      // -------------------------------------------------------------------
      // Impression d'un panel
      // -------------------------------------------------------------------
       dcl-proc  printPanel;
       dcl-pi printPanel;
         no      zoned(4:0);
         lPanel$ pointer   ;
       end-pi;
      *
       dcl-ds panel likeDs(tPanel) based(pPanel);
       pPanel=tree_getItem(lPanel$);
       // saut de ligne ?
       if no>1;
         no+=1;
         // line feed
         sflRRN=no;
         write sfl1;
         memoryItem(NO:lPanel$:0);
       endIf;
       // panel
       NO+=1;
       xFil=panel.text;
       sflrrn=no;
       write sfl1;
       memoryItem(NO:lPanel$:0);
       end-proc;
      // -------------------------------------------------------------------
      // impression d'un segment
      // -------------------------------------------------------------------
       dcl-proc  printSegment;
       dcl-pi printSegment;
         no       zoned(4:0) ;
         lLabel   pointer     const;
         labelChg ind         const;
         segChg   ind         const;
         string1  char(32000) const;
         string2  char(32000) const;
         segment  int(5)      const;
       end-pi;
      *
       dcl-ds label likeDs(tLabel) based(pLabel);
       pLabel=tree_getItem(lLabel);
       // si nouveau label impression du texte
       if labelChg;
         xFil=int_AddSpaceDot('  '+Label.text+' ':52);
         if g.rcdChg and string1<>string2;
           %subst(xFil:1:1)=x'28';
           %subst(xFil:53:1)=x'20';
         endIf;
         if screen_getFKcontext(a.lFKS:x'3b')='1';
           %subst(xFil:60-%len(label.formula)-2:%len(label.formula)+2)
           =x'22'+label.formula+x'20';
         endIf;
       endIf;
       // value
       %subst(xFil:62)=%subst(String1:segment*70+1:70);
       // if segment is changed:hight the changed value (before)
       if SegChg;
         %subst(xFil:59:2)=x'20'+'>';
       endif;
       no+=1;
       sflrrn=no;
       write sfl1;
       xFil='';
       memoryItem(NO:lLabel:segment);
       // if segment is changed:hight the changed value (post)
       if SegChg;
         no+=1;
         %subst(xFil:59:2)=x'28'+'>';
         %subst(xFil:62)=%subst(String2:segment*70+1:70);
         sflrrn=no;
         write sfl1;
         xFil='';
         memoryItem(NO:lLabel:segment);
       endIf;
       end-proc;
      // -------------------------------------------------------------------
      // memorisation de l'élément
      // -------------------------------------------------------------------
       dcl-proc  memoryItem;
       dcl-pi memoryItem;
         NO       uns(3)     const;
         lVariant pointer    const;
         segment  zoned(5:0) const;
       end-pi;
       g.item(NO).lVariant=lVariant;
       g.item(NO).segment =segment;
       YView.armBot.lVariant=lVariant;
       YView.armBot.segment =segment;
       end-proc;
      // -------------------------------------------------------------------
      // Entrée
      // -------------------------------------------------------------------
       dcl-proc  Enter;
       dcl-pi Enter end-pi;
       g.pScreen=*null;
       rtnCode=fContinue;
       end-proc;
      // -------------------------------------------------------------------
      // F3=Exit
      // -------------------------------------------------------------------
       dcl-proc  F3;
       dcl-pi F3 end-pi;
       g.pScreen=*null;
       rtnCode=fStop;
       end-proc;
      // --------------------------------------------------------------------
      // F9=Data/Journal
      // --------------------------------------------------------------------
       dcl-proc  F9;
       dcl-s lJrnFmt pointer;
       dcl-ds jrnFmt likeDs(tFormat)  based(pJrnFmt);
       // get the entry (parent if sub-entry)
       // JOURNAL DATA
            // CONTEXT=DISPLAY JOURNAL PART
              // get the format
            // CONTEXT=DISPLAY DATA PART
              // get the file/format
              lYView=tree_getFirst(lYviews);
              pYView=tree_getItem(lYView);
              // get corresponding data
              pFmt=tree_getitem(YView.lFmt);
           if fmt.pBuffer0<>*null;
             g.rcdChg=*on;
           endif;
            // CONTEXT=DISPLAY DATA PART for SUBENTRY
       end-proc;
      // -------------------------------------------------------------------
      // F10=Move to top
      // -------------------------------------------------------------------
       dcl-proc  F10;
       dcl-pi F10 end-pi;
       if SFLCSRRRN=0;
         msg_SndPM(pgmID:'Wrong cursor position');
       else;
         YView.armTop.lVariant=g.item(SFLCSRRRN).lVariant;
         YView.armTop.segment=g.item(SFLCSRRRN).segment;
       endIf;
       end-proc;
      // -------------------------------------------------------------------
      // paginer après
      // -------------------------------------------------------------------
       dcl-proc  RollDown;
       dcl-pi RollDown end-pi;
      *
       dcl-ds label likeDs(tLabel) based(pLabel);
       if mySflEnd='Bottom';
         msg_SndPM(pgmID:'You have reached the bottom of the form');
       else;
          YView.armTop=YView.armBot;
          pLabel=tree_getItem(YView.armBot.lVariant);
          if YView.armTop.segment<(label.maxWidth-1)/70;
            YView.armTop.segment+=1;
          else;
            YView.armTop.lVariant=tree_getNextToDisplay(YView.lForm
                                                       :YView.armTop.lVariant);
            YView.armTop.segment=0;
          endif;
       endIf;
       end-proc;
      // -------------------------------------------------------------------
      // paginer avant
      // -------------------------------------------------------------------
       dcl-proc  RollUp;
       dcl-pi RollUp  end-pi;
      *
       dcl-s lVariant pointer   ;
       dcl-s PanelChg ind       ;
       dcl-s SegChg   ind       ;
       dcl-s NO       zoned(4:0) inz(0);
       dcl-s segment  int(5)    ;
       dcl-s s        int(5)    ;
       dcl-s s0       int(5)    ;
       dcl-s s9       int(5)    ;
       dcl-ds label likeDs(tLabel) based(pLabel);
       dcl-s String1       char(32000);
       dcl-s String2       char(32000);
       dcl-s remainingRows uns(3)     ;
       dcl-s NecessaryRows uns(3)     ;
       lVariant=YView.armTop.lVariant;
       if YView.armTop.segment>0;
         s9=YView.armTop.segment-1;
       else;
         lVariant=tree_getPrevToDisplay(YView.lForm:lVariant);
         if tree_isOftheKind(kLabel:lVariant:pLabel);
           s9=(label.maxWidth-1)/70;
         endIf;
       endIf;
       PanelChg=*on;
       // loop on each item
       dow lVariant<>*null;
         if tree_isofthekind(kForm:lVariant);
           return;
         elseif tree_isofthekind(kLabel:lVariant:pLabel);
           // load value(s) for the label
           if g.rcdChg;
             string2=int_FormulaExec(label.lFormula:0);
             string1=int_FormulaExec(label.lFormula:1);
           endIf;
           // loop on each segment
           for s=s9 downto 0;
             // load segments
             SegChg=cmpSegments(label:String1:String2:s);
             // check if enought space avalaible
             remainingRows=23-NO;
             NecessaryRows=%int(PanelChg)*2-%int(no=0)
                          +%int(SegChg)*1
                          +1;
             if remainingRows<NecessaryRows;
               return;
             endIf;
             no+=necessaryRows;
             // Print new panel
             PanelChg=*off;
             // Print segment
             YView.armtop.lVariant=lVariant;
             YView.armtop.segment=s;
           endFor;
         endIf;
         lVariant=tree_getPrevToDisplay(YView.lForm:lVariant);
         // new panel/label?
         if tree_isOfTheKind(kPanel:lVariant);
           PanelChg=*on;
         elseif tree_isOfTheKind(kLabel:lVariant:pLabel);
           s9=(label.maxWidth-1)/70;
         endIf;
       endDo;
       end-proc;
