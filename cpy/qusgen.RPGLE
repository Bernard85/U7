     D*****************************************************************
     D*Type Definition for the User Space Generic Header.
     D*****************************************************************
     DQUSH0100         DS
     D*                                             Qus Generic Header 0100
     D QUSUA                   1     64
     D*                                             User Area
     D QUSSGH                 65     68B 0
     D*                                             Size Generic Header
     D QUSSRL                 69     72
     D*                                             Structure Release Level
     D QUSFN                  73     80
     D*                                             Format Name
     D QUSAU                  81     90
     D*                                             Api Used
     D QUSDTC                 91    103
     D*                                             Date Time Created
     D QUSIS                 104    104
     D*                                             Information Status
     D QUSSUS                105    108B 0
     D*                                             Size User Space
     D QUSOIP                109    112B 0
     D*                                             Offset Input Parameter
     D QUSSIP                113    116B 0
     D*                                             Size Input Parameter
     D QUSOHS                117    120B 0
     D*                                             Offset Header Section
     D QUSSHS                121    124B 0
     D*                                             Size Header Section
     D QUSOLD                125    128B 0
     D*                                             Offset List Data
     D QUSSLD                129    132B 0
     D*                                             Size List Data
     D QUSNBRLE              133    136B 0
     D*                                             Number List Entries
     D QUSSEE                137    140B 0
     D*                                             Size Each Entry
     D QUSSIDLE              141    144B 0
     D*                                             CCSID List Ent
     D QUSCID                145    146
     D*                                             Country ID
     D QUSLID                147    149
     D*                                             Language ID
     D QUSSLI                150    150
     D*                                             Subset List Indicator
     D QUSERVED00            151    192
     D*                                             Reserved
