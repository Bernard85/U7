     D*****************************************************************
     D*Type Definition for the OBJD0200 format.
     D*****************************************************************
     DQUSD0200         DS
     D*                                             Qus OBJD0200
     D QUSBRTN07               1      4B 0
     D*                                             Bytes Returned
     D QUSBAVL08               5      8B 0
     D*                                             Bytes Available
     D QUSOBJN01               9     18
     D*                                             Object Name
     D QUSOBJLN00             19     28
     D*                                             Object Lib Name
     D QUSOBJT01              29     38
     D*                                             Object Type
     D QUSRL02                39     48
     D*                                             Return Lib
     D QUSASP05               49     52B 0
     D*                                             Aux Storage Pool
     D QUSOBJO05              53     62
     D*                                             Object Owner
     D QUSOBJD05              63     64
     D*                                             Object Domain
     D QUSCDT12               65     77
     D*                                             Create Date Time
     D QUSCDT13               78     90
     D*                                             Change Date Time
     D QUSEOA05               91    100
     D*                                             Extended Obj Attr
     D QUSTD12               101    150
     D*                                             Text Description
     D QUSSFILN06            151    160
     D*                                             Source File Name
     D QUSSFLN06             161    170
     D*                                             Source File Lib Name
     D QUSSFMN03             171    180
     D*                                             Source File Mbr Name
