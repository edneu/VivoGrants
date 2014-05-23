# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# #   Mk_VIVO_Grants.pl  
# #   Created 1-29-2014 by Ed Neu  Univeristy of Florida CTSI 
# #   Modidied 3-12-2014 (Updated AwardID from PS_Contract)
# #
# #
# #  VIVO_SRMaster.SPS Program creates the two input file for this Script,
# #  INV_ROOT.DAT  Tab Delingied file containing
# #
# #            AwardIndicator,
# #            AwardID,
# #            AwardTitle,
# #            TotalAwarded,
# #            Direct,
# #            StartDate,
# #            EndDate,
# #            AwardDeptID,
# #            AwardPrimeCustID,
# #            RefAwardNumber,
# #            Note
# #
# #   VIVO_INVESTIGATOR.DAT
# #   the input file is tab delimited and contains 
# #           PS_CONTRACT  (AwardID Number) 
# #           INV_TYPE  (values : 
# #                 'PI' for principal investigator, 
# #               'CoPI' for Co principal inv,
# #                'Inv' for other investigators
# #           UFID  (ID number of Investogotor
# #           INVEST_LEVEL Redundant with INV_TYPE  1=PI, 2=CoPI, 3=Inv
# # 
# #   A Hash table is popultated with the Key = AwardID 
# #                values =          
# #                        <comma delimited list (cdl) of the UFIDs of PIs> ; 
# #                             <<cdl  of the UFIDs of CoPIs> ; 
# #                             <<cdl  of the UFIDs of Invs> ;
# #          
# #   The final output file is a semicolon delinted file of the following format:
# # 
# #
# #
# #          $AwardIndicator;
# #           AwardID;
# #           AwardTitle;
# #           TotalAwarded;
# #           Direct;
# #           StartDate;
# #           EndDate;
# #           UFID of PI (comma delimited list);
# #           UFID of CoPI (comma delimited list);
# #           UFID of other Investigators (comma delimited list);
# #           AwardDeptID;
# #           AwardPrimeCustID;
# #           RefAwardNumber;
# #           Note "\n"
# #
# # cd\My Documents\My Documents\GrantsData\VIVO_GRANTS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


$root_filename='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_ROOT.DAT' ;
$inv_filename='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_INVESTIGATOR.DAT' ;
$out_filename='P:\My Documents\My Documents\GrantsData\VIVO_Grants\VIVO_GRANTS.TXT' ;


# # See if Input files exist or DIE!!!!

if (open(TEST,"<", $inv_filename))  { close(TEST); }
else {die "\n","ERROR: Cannot Open ",$inv_filename,"\n","\n"; }
 
if (open(TEST,"<", $root_filename))  { close(TEST); }
else {die "\n","ERROR: Cannot Open ",$root_filename,"\n","\n"; }

# # OPEN the output file
open(OUTFILE, '>', $out_filename); 



# # Initialize - Variables 

$lag_AwardID='initial';
$curr_AwardID='initial';
$curr_rec='initial';
$root_rec='initial';
$rec_type='firstinseries';

$out_PI   = '';
$out_CoPI = '';
$out_INV  = '';
$rec_count = 0;
$in_count = 0;
$out_count = 0;
%inv_hash = (0000000000=>'PI;CoPI;Inv;');

# # Process the Investigator Records - Process Assumes File is ordered by AwardID

open(INVFILE,"<", $inv_filename);

while ($curr_rec ne '')
      {
  
          $in_count += 1 ;      
  
          $curr_rec = <INVFILE> ;
          
          
          ( $in_AwardID,
            $in_INV_TYPE,
            $in_UFID,
            $in_INVEST_LEVEL ) = split(/\t/,$curr_rec);     
          
            $rec_count +=1;
            $in_UFID .= ',';
          
            if($rec_count=1) {$rec_type = 'firstinseries'}
            if($rec_count>=1 && $lag_AwardID eq $in_AwardID) {$rec_type = 'appendUFID'}
            if($rec_count>=1 && $lag_AwardID ne $in_AwardID) {$rec_type = 'write'}
   
      
            if ($rec_type eq 'firstinseries' || $rec_type eq 'appendUFID')
             {
               
                      if ($in_INV_TYPE eq 'PI') {$out_PI .= $in_UFID;}
                      if ($in_INV_TYPE eq 'CoPI') {$out_CoPI .= $in_UFID;}
                      if ($in_INV_TYPE eq 'Inv') {$out_INV .= $in_UFID;}
                      $lag_AwardID=$in_AwardID;
                      $rec_count += 1;
             }  
      
            if ($rec_type eq 'write') 
             {
                               chop($out_PI);
                               chop($out_CoPI);
                               chop($out_INV);
       
                           if (length($out_PI.$out_CoPI.$out_INV)>0)
                               {  
                                    $invrec = join ';',
                                    $out_PI,
                                    $out_CoPI,
                                    $out_INV;
                                    
                                    $inv_hash{$lag_AwardID} = $invrec ;
  
                               }
                           
                                $lag_AwardID=$in_AwardID;
                                $out_PI   = '';
                                $out_CoPI = '';
                                $out_INV  = '';
                                $rec_count = 0;  
                              
                                if ($in_INV_TYPE eq 'PI') {$out_PI .= $in_UFID;}
                                if ($in_INV_TYPE eq 'CoPI') {$out_CoPI .= $in_UFID;}
                                if ($in_INV_TYPE eq 'Inv') {$out_INV .= $in_UFID;}                    
             
                                $rec_type='firstinseries';
                                $rec_count = 0;
             }
   

 
      } 
 
 
 ## ADD INVESTIGATORS TO ROOT FILE COMPONENTS
 
 open(ROOTFILE,"<", $root_filename);
 
 print OUTFILE ('AwardIDType;AwardID;Title;TotalAwarded;DirectCosts;StartDate;EndDate;PI;CoPI;Inv;DeptID;SponserID;SponserAwardID;Note',"\n");
 
 
 
 while ($root_rec ne '')
{
        $root_rec = <ROOTFILE>;

          ( $AwardIndicator,
            $AwardID,
            $AwardTitle,
            $TotalAwarded,
            $Direct,
            $StartDate,
            $EndDate,
            $AwardDeptID,
            $AwardPrimeCustID,
            $RefAwardNumber,
            $Note ) 
            = split(/\t/,$root_rec);     


           $InvStr=$inv_hash{$AwardID};

           $outrec = join ';',
           $AwardIndicator,
           $AwardID,
           $AwardTitle,
           $TotalAwarded,
           $Direct,
           $StartDate,
           $EndDate,
           $InvStr,
           $AwardDeptID,
           $AwardPrimeCustID,
           $RefAwardNumber,
           $Note;

 
          print OUTFILE ($outrec);
          $out_count += 1;
}

print("\n \n \n",$out_count-1," records written to: ","\n",$out_filename,"\n \n \n");

#############  END OF FILE  ###############


