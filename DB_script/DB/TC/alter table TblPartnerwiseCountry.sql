ALTER TABLE TblPartnerwiseCountry ADD isRealTime BIT 

ALTER TABLE TblPartnerwiseCountryHistory ADD isRealTime BIT 

ALTER TABLE TblPartnerwiseCountry ADD minTxnLimit MONEY,maxTxnLimit MONEY,LimitCurrency VARCHAR(3),exRateCalByPartner BIT  

ALTER TABLE TblPartnerwiseCountryHistory ADD minTxnLimit MONEY,maxTxnLimit MONEY,LimitCurrency VARCHAR(3),exRateCalByPartner BIT  

--added by gunn
alter table tblpartnerwiseCountry add modType char(1)
alter table tblpartnerwiseCountry add approvedBy varchar(50)
alter table tblpartnerwiseCountry add approvedDate datetime


select * into tblpartnerwiseCountryMod 
from tblpartnerwiseCountry where 1 = 2

alter table tblpartnerwiseCountryMod drop column id

alter table tblpartnerwiseCountryMod add modType char(1)
alter table tblpartnerwiseCountryMod add id bigint

INSERT INTO dbo.changesApprovalSettings
      		  (  functionId ,
      		     mainTable ,
     		     modTable ,
                     pKfield ,
      		     spName ,
      		     pageName
    		    )
                   VALUES  ( 20177300 , -- functionId - int
	          'tblpartnerwiseCountry' , -- mainTable - varchar(255)
      		    'tblpartnerwiseCountryMod' , -- modTable - varchar(255)
       		   'id' , -- pKfield - varchar(255)
       		   'PROC_API_ROUTE_PARTNERS' , -- spName - varchar(255)
       		   'Api Routing Setup'  -- pageName - varchar(255)
  		      )


