      // Statistic family
       dcl-c kStats 'S';
       dcl-c kStat  's';
       dcl-c kModel 'm';
      *
       dcl-ds tStats qualified;
         kind char(1) inz(kStats);
       end-ds;
      *
       dcl-ds tStat qualified;
         kind         char(1)     inz(kStat);
         ID           varchar(10) inz('');
         text         varchar(50) inz('');
         modelsSelect uns(5)      inz(0);
         modelsCount  uns(5)      inz(0);
         itemsSelect  uns(5)      inz(0);
         itemsCount   uns(5)      inz(0);
         formula      varchar(50) inz('');
         lFormula     pointer     inz(*null);
       end-ds;
      *
       dcl-ds tModel qualified;
         kind       char(1)     inz(kModel);
         ID         varchar(50) inz('');
         statID     varchar(10) inz('');
         text       varchar(50) inz('');
         itemsCount uns(5)      inz(0);
         lFormula   pointer     inz(*null);
       end-ds;
      // get item for STAT family for Xml parser
       dcl-pr stat_XmlInput pointer;
         ND const likeDs(xml_nodeDefine);
       end-pr;
