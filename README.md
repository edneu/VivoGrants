VivoGrants
==========

# Getting UF Research Awards Data into VIVO


##  VIVO_SRMaster.SPS Program creates the two input file for this Script,
<<<<<<< HEAD
##  INV_ROOT.DAT  Tab Delingied file containing
=======
###  INV_ROOT.DAT  Tab Delimited file containing
>>>>>>> f833630fbfafd50439878bc8391ac5b51e220196

###            AwardIndicator,
###            AwardID,
###            TotalAwarded,
###            Direct,
###            StartDate,
###            EndDate,
###            AwardDeptID,
###            AwardPrimeCustID,
###            RefAwardNumber,
###            Note

##   VIVO_INVESTIGATOR.DAT
<<<<<<< HEAD
   the input file is tab delimited and contains 
           PS_CONTRACT  (AwardID Number) 
           INV_TYPE  (values : 
                 'PI' for principal investigator, 
               'CoPI' for Co principal inv,
                'Inv' for other investigators
           UFID  (ID number of Investogotor
           INVEST_LEVEL Redundant with INV_TYPE  1=PI, 2=CoPI, 3=Inv
=======
###   the input file is tab delimited and contains 
###           PS_CONTRACT  (AwardID Number) 
###           INV_TYPE  (values : 
###                 'PI' for principal investigator, 
###               'CoPI' for Co principal inv,
###                'Inv' for other investigators
###           UFID  (ID number of Investogotor
###           INVEST_LEVEL Redundant with INV_TYPE  1=PI, 2=CoPI, 3=Inv
>>>>>>> f833630fbfafd50439878bc8391ac5b51e220196
 
##   Mk_VIVO_Grants.pl  
   


###    A Hash table is popultated with the Key = AwardID 
###                values =          
###                        <comma delimited list (cdl) of the UFIDs of PIs> ; 
###                             <<cdl  of the UFIDs of CoPIs> ; 
###                             <<cdl  of the UFIDs of Invs> ;
          
<<<<<<< HEAD
##   The final output file is a semicolon delimited file of the following format:
           AwardIndicator;
           AwardID;
           AwardTitle;
           TotalAwarded;
           Direct;
           StartDate;
           EndDate;
           UFID of PI (comma delimited list);
           UFID of CoPI (comma delimited list);
           UFID of other Investigators (comma delimited list);
           AwardDeptID;
           AwardPrimeCustID;
           RefAwardNumber;
           Note "\n"
=======
###   The final output file is a semicolon delimited file of the following format:
###           AwardIndicator;
###           AwardID;
###           AwardTitle;
###           TotalAwarded;
###           Direct;
###           StartDate;
###           EndDate;
###           UFID of PI (comma delimited list);
###           UFID of CoPI (comma delimited list);
###           UFID of other Investigators (comma delimited list);
###           AwardDeptID;
###           AwardPrimeCustID;
###           RefAwardNumber;
###           Note "\n"
>>>>>>> f833630fbfafd50439878bc8391ac5b51e220196
