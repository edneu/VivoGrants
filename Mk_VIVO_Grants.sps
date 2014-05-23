



GET DATA /TYPE=XLSX
  /FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_SUMMARY_5-23-2014.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.

FORMATS TotalAwarded (F12.2).
FORMATS Direct (F12.2).

COMPUTE AwardDate=date.mdy(number(substr(Award_DT,6,2),F2),number(substr(Award_DT,9,2),N2),number(substr(Award_DT,1,4),N4)).
FORMATS AwardDate (ADATE10).
EXECUTE.

COMPUTE StartDate=date.mdy(number(substr(Start_DT,6,2),F2),number(substr(Start_DT,9,2),N2),number(substr(Start_DT,1,4),N4)).
FORMATS StartDate (ADATE10).

COMPUTE EndDate=date.mdy(number(substr(End_DT,6,2),F2),number(substr(End_DT,9,2),N2),number(substr(End_DT,1,4),N4)).
FORMATS EndDate (ADATE10).

STRING TITLE (A150).
COMPUTE TITLE=REPLACE(SR_TITLE,';',' ').

EXECUTE.



SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_SUMMARY_RAW.sav'
  /COMPRESSED.

Compute DropCase=0.
*If Category="Research Training" DropCase=1.
*If Category="Instruction/Non Research Training" DropCase=1.
*If Category="Other" DropCase=1.
If Category="Public Service/Outreach" DropCase=1.
If Category="Service Agreements" DropCase=1.
IF EndDate<=date.mdy(12,31,2007) DropCase=1.
EXECUTE.


Select if DropCase=0.
Execute.

SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_SUMMARY_RESEARCH.sav'
  /COMPRESSED.

STRING AWARD_TYPE_INDICATOR (A4).
Compute AWARD_TYPE_INDICATOR='UNKNOWN'.
IF AwardID_Source='CONTRACT_NUM' AWARD_TYPE_INDICATOR='CONT'.
IF AwardID_Source='PROJECT_ID' AWARD_TYPE_INDICATOR='PROJ'.
EXECUTE.


AGGREGATE
  /OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_ROOT.sav'
  /BREAK=AWARD_TYPE_INDICATOR AwardID Title TotalAwarded Direct StartDate EndDate AwardDeptID 
    AwardPrimeCustID REF_AWD_NUMBER
  /Scratch=SUM(DropCase).


GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_ROOT.sav'.
 
String Note (A10).
COMPUTE Note='          '.
EXECUTE.

*VARIABLE LABELS 
AWARD_TYPE_INDICATOR 'AwardID Type'
AwardID 'AwardID'
SR_Title 'Title'
TotalAwarded 'TotalAwarded'
Direct 'DirectCosts'
StartDate 'StartDate'
EndDate 'EndDate'
Invest 'PI;CoPI; Inv'
AwardDeptID 'DeptID'
AwardPrimeCustID 'SponserID'
REF_AWD_NUMBER 'SponserAwardID'
Note 'Note'.


        
SORT CASES BY AwardID(A).

SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_ROOT.sav'
 /KEEP = AWARD_TYPE_INDICATOR
                       AwardID
                       Title
                       TotalAwarded
                       Direct
                       StartDate
                       EndDate
                       AwardDeptID
                       AwardPrimeCustID
                       REF_AWD_NUMBER
                       Note
         /COMPRESSED.

GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_ROOT.sav'
  /KEEP = AWARD_TYPE_INDICATOR
                       AwardID
                       Title
                       TotalAwarded
                       Direct
                       StartDate
                       EndDate
                       AwardDeptID
                       AwardPrimeCustID
                       REF_AWD_NUMBER
                       Note



SAVE TRANSLATE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_ROOT.dat'
  /TYPE=TAB
  /ENCODING='UTF8'
  /MAP
  /REPLACE
  /CELLS=VALUES
  /RENAME AWARD_TYPE_INDICATOR=AwardIDType
                 AwardID=AwardID
                 Title=Title
                 TotalAwarded=TotalAwarded
                 Direct=DirectCosts
                 StartDate=StartDate
                 EndDate=EndDate
                 AwardDeptID=DeptID
                 AwardPrimeCustID=SponserID
                 REF_AWD_NUMBER=SponserAwardID
                 Note=Note.

.
******************************************************************************.
******************************************************************************.
* INVESTGATOR CODE FROM DETAIL VIEWS HERE
******************************************************************************.

GET DATA /TYPE=XLSX
  /FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_DETAIL_5-23-2014.xlsx'
  /SHEET=name 'Sheet1'
  /CELLRANGE=full
  /READNAMES=on
  /ASSUMEDSTRWIDTH=32767.
EXECUTE.


COMPUTE EndDate=date.mdy(number(substr(SR_ProjectEnd_DT,6,2),F2),number(substr(SR_ProjectEnd_DT,9,2),N2),number(substr(SR_ProjectEnd_DT,1,4),N4)).
FORMATS EndDate (ADATE10).


SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_DETAIL_RAW.sav'   /COMPRESSED.

Compute DropCase=0.
*If Category="Research Training" DropCase=1.
*If Category="Instruction/Non Research Training" DropCase=1.
*If Category="Other" DropCase=1.
If Category="Public Service/Outreach" DropCase=1.
If Category="Service Agreements" DropCase=1.
*IF EndDate<=date.mdy(12,31,2007) DropCase=1.
EXECUTE.

Select if DropCase=0.
Execute.

STRING AWARD_TYPE_INDICATOR (A4).
STRING AwardID (A8).

COMPUTE AWARD_TYPE_INDICATOR='CONT'.
COMPUTE AwardID=CONTRACT_NUM.
IF CONTRACT_NUM='' AWARD_TYPE_INDICATOR='PROJ'.
IF CONTRACT_NUM='' AwardID=PROJECT_ID.
EXECUTE.



SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_DETAIL_Research.sav'   /COMPRESSED.


*********************************************************************************************************************.
*  Identify Investigators
*     Create a series of Temporary Tables containing Investigator UFIDs classified into PI, CoPI, or INV
*     Append the temporary tables, unduplicate the results, and output to 
*     "VIVO_INVESTIGATOR.SAV" and "VIVO_INVESTIGATOR.DAT"
*      These files contain :  PS_CONTRACT - Contract ID Number
*                                     INV_TYPE   Type of Investigatirs
                                                              - "PI" Principal Investigator
*                                                             - "CoPI" - Co-Principal Investigator
*                                                              - "Inv" - Investigator
*                                     UFID  - ID Number of Investigaotor       
*                                     INVEST_LEVEL   1 for "PI", 2 for "CoPI", 3 for "Inv"   (I Know, same as INV_TYPE, but in a needed order)        
*                                     
*************************************************************************************************************************.

GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_DETAIL_Research.sav' .
EXECUTE.

SORT CASES BY AwardID (A) SR_ProjectBegin_DT (A).
EXECUTE.

COMPUTE ROOT_REC=1.
IF AwardID = LAG(AwardID) Root_Rec=0.
EXECUTE.

SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_WORK.sav'   /COMPRESSED.


GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_WORK.sav'.

STRING UFID (A8).
STRING INV_TYPE (A4).

COMPUTE INV_TYPE="PI".
COMPUTE UFID=''.
COMPUTE UFID=ContractUFID.
EXECUTE.

SELECT IF UFID<>''.

SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP1.sav'
  /KEEP=AwardID, INV_TYPE, UFID 
  /COMPRESSED.


******** SECOND PI ***.
GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_WORK.sav'.

SELECT IF ROOT_REC=1.

STRING UFID (A8).
STRING INV_TYPE (A4).

COMPUTE INV_TYPE="PI".
COMPUTE UFID=''.
IF ContractUFID<>SR_PI_UFID    UFID=SR_PI_UFID.
EXECUTE.

SELECT IF UFID<>''.

SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP2.sav'
  /KEEP=AwardID, INV_TYPE, UFID 
  /COMPRESSED.

**** CO PI ***.
GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_WORK.sav'.

SELECT IF ROOT_REC=1.

STRING UFID (A8).
STRING INV_TYPE (A4).

COMPUTE INV_TYPE="CoPI".
Compute UFID=SR_CoPI_UFID.
EXECUTE.

SELECT IF UFID<>''.
Execute.


SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP3.sav'
  /KEEP=AwardID, INV_TYPE, UFID 
  /COMPRESSED.

*********PROJECT PI IF DIFFERENT AS INV

GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_WORK.sav'.

SELECT IF ROOT_REC=1.

STRING UFID (A8).
STRING INV_TYPE (A4).
COMPUTE UFID=''.

COMPUTE INV_TYPE="Inv".
IF     ((ProjectUFID<>ContractUFID)
     AND  (ProjectUFID<>SR_PI_UFID)
     AND (ProjectUFID<>SR_CoPI_UFID))
UFID=ProjectUFID.

EXECUTE.

SELECT IF UFID<>''.
Execute.


SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP4.sav'
  /KEEP=AwardID, INV_TYPE, UFID 
  /COMPRESSED.

*********OTHER INVESTIGATRS AS INV - Project PI

GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_WORK.sav'.

SELECT IF ROOT_REC=0.

STRING UFID (A8).
STRING INV_TYPE (A4).
COMPUTE UFID=''.

COMPUTE INV_TYPE="Inv".
IF     ((ProjectUFID<>ContractUFID)
     AND  (ProjectUFID<>SR_PI_UFID)
     AND (ProjectUFID<>SR_CoPI_UFID))
UFID=ProjectUFID.

EXECUTE.

SELECT IF UFID<>''.
Execute.


SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP5.sav'
  /KEEP=AwardID, INV_TYPE, UFID 
  /COMPRESSED.

GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_WORK.sav'.

SELECT IF ROOT_REC=0.

STRING UFID (A8).
STRING INV_TYPE (A4).

COMPUTE INV_TYPE="Inv".
COMPUTE UFID=''.
IF ContractUFID<>SR_PI_UFID UFID=SR_PI_UFID.
EXECUTE.

SELECT IF UFID<>''.

SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP6.sav'
  /KEEP=AwardID, INV_TYPE, UFID 
  /COMPRESSED.

**** CO PI ***.
GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_WORK.sav'.

SELECT IF ROOT_REC=0.

STRING UFID (A8).
STRING INV_TYPE (A4).

COMPUTE INV_TYPE="INV".
Compute UFID=SR_CoPI_UFID.
EXECUTE.

SELECT IF UFID<>''.
Execute.


SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP7.sav'
  /KEEP=AwardID, INV_TYPE, UFID 
  /COMPRESSED.


*********** ALL TOGERTHER NOW.
*GET   FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP1.sav'.


** EOF

ADD FILES  FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP1.sav'
  /FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP2.sav'
  /FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP3.sav'
  /FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP4.sav'
  /FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP5.sav'
  /FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP6.sav'
  /FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVEST_TEMP7.sav'.

EXECUTE.

Compute Invest_Level=3.
IF Inv_Type='PI' Invest_Level=1.
IF Inv_Type='CoPI' Invest_Level=2.
EXECUTE.

SORT CASES AwardID (A), INVEST_LEVEL (A), UFID (A).
EXECUTE.


SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVESTIGATOR.sav'
  /COMPRESSED.


*********************************************************************************************************************.
*  Unduplicate the list of Investigaots on each AwardID
*************************************************************************************************************************.

GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVESTIGATOR.sav'.

COMPUTE INVEST_LEVEL=3.
IF INV_TYPE="PI" INVEST_LEVEL=1. 
IF INV_TYPE="CoPI" INVEST_LEVEL=2. 
EXECUTE.

SORT CASES BY AwardID (A), UFID, INVEST_LEVEL (A).
COMPUTE KEEP_REC=1.
IF AwardID=LAG(AwardID) AND UFID=LAG(UFID) KEEP_REC=0.
EXECUTE.

SELECT IF KEEP_REC=1.
EXECUTE.

SORT CASES BY AwardID (A), INVEST_LEVEL (A), UFID.

SAVE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVESTIGATOR.sav'
 /KEEP AwardID, Inv_type, UFID, INVEST_LEVEL
 /COMPRESSED.
EXECUTE.

GET FILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVESTIGATOR.sav'.

SAVE TRANSLATE OUTFILE='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVESTIGATOR.dat'
  /TYPE=TAB
  /ENCODING='UTF8'
  /MAP
  /REPLACE
  /CELLS=VALUES.


