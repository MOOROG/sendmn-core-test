USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ExchangeDropdown]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_ExchangeDropdown]
 @FLAG					VARCHAR(20),
 @BRANCH_ID				VARCHAR(30) = NULL,
 @USER				    VARCHAR(50) = NULL,
 @CTYPE					INT			= NULL,
 @SEARCHTYPE			VARCHAR(50) = NULL,
 @SEARCHVALUE			VARCHAR(50)	= NULL
 
AS
SET NOCOUNT ON;

IF @BRANCH_ID IS NOT NULL
 SELECT @BRANCH_ID = BRANCH_ID from Branches WITH(NOLOCK) WHERE COMPANY_ID = @BRANCH_ID 

IF @FLAG ='operationDDL' -->> ONLY FOR BUY,SELL,CROSS OPERATION DO NOT CHANGE THE QUERY
BEGIN
 --CURRENCY DDL
 IF @BRANCH_ID IS NOT NULL
 BEGIN
  select  c.curr_code+'('+c.curr_name+')' [curr_name],c.curr_code 
  from Branch_Currency b WITH(NOLOCK)
  INNER JOIN currency_setup c WITH(NOLOCK) on b.curr_code=c.rowid
  INNER JOIN Branches BS WITH(NOLOCK) ON b.branch_id = BS.BRANCH_ID
  where BS.BRANCH_ID = @BRANCH_ID AND C.curr_code <> 'MYR'
  ORDER BY ISNULL(CAST(b.displayOrder AS VARCHAR),C.curr_code) 
 END
 ELSE
 BEGIN
  select curr_code+'('+curr_name+')' [curr_name],curr_code from currency_setup WHERE 1=2
 END
 --COUNTRY DDL
 SELECT refid,ref_code FROM ref_master WITH(NOLOCK) WHERE ref_rec_type=1 ORDER BY ref_code
 
 -->>  Customer Type
 SELECT refid,ref_code FROM ref_master WITH(NOLOCK) WHERE ref_rec_type='106' order by ref_code
 -->> Purpose of Txn
 SELECT refid,ref_code FROM ref_master WITH(NOLOCK) WHERE ref_rec_type=104 order by ref_code
 -->> ID Type
 SELECT refid,ref_code FROM ref_master WITH(NOLOCK) WHERE ref_rec_type=101 order by ref_code
 -->> Occupation
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=102 order by ref_code
 -->> Source of Money
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=103 order by ref_code
 --BUSINESS TYPE
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=107 order by ref_code
 -- STR REASON
  select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=109 order by ref_code
 
END
IF @FLAG = 'BEXC' -->> BRANCHWISE CURRENCY LOAD FOR EXCHANGE
BEGIN
 
 IF @BRANCH_ID IS NOT NULL
 BEGIN
  select  c.curr_code+'('+c.curr_name+')' [curr_name],c.curr_code 
  from Branch_Currency b WITH(NOLOCK)
  INNER JOIN currency_setup c WITH(NOLOCK) on b.curr_code=c.rowid
  INNER JOIN Branches BS WITH(NOLOCK) ON b.branch_id = BS.BRANCH_ID
  where BS.BRANCH_ID = @BRANCH_ID AND C.curr_code <> 'MYR'
  ORDER BY C.curr_code
 END
 ELSE
 BEGIN
  select curr_code+'('+curr_name+')' [curr_name],curr_code from currency_setup WHERE 1=2
 END

END

ELSE IF @FLAG='ct'-->>  Customer Type
BEGIN
 SELECT refid,ref_code FROM ref_master WITH(NOLOCK) WHERE ref_rec_type='106' order by ref_code
End
ELSE IF @FLAG='fc' -->> Filter Customer
BEGIN
 select cid,cName from customerSetup WITH(NOLOCK) WHERE CTYPE ='726' AND branchId =  @BRANCH_ID order by cName
END
ELSE IF @FLAG='c' -->> Country
BEGIN
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=1 order by ref_code
END
ELSE IF @FLAG='pot' -->> Purpose of Txn
BEGIN
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=104 order by ref_code
END
ELSE IF @FLAG='idt' -->> ID Type
BEGIN
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=101 order by ref_code
END
ELSE IF @FLAG='occ' -->> Occupation
BEGIN
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=102 order by ref_code
END
ELSE IF @FLAG='som' -->> Source of Money
BEGIN
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=103 order by ref_code
END
ELSE IF @FLAG='pocm' -->> Purpose of Changing Money
BEGIN
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=104 order by ref_code
END
ELSE IF @FLAG='bidt' -- Beneficiary ID Type
BEGIN
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=101 order by ref_code
END
ELSE IF @FLAG = 'custByCtype' -->> customer detail by customer id
BEGIN
--select @SEARCHVALUE = fileName from customerdocument where fileDescription = 'Customer Id photo' and cid = @BRANCH_ID
SELECT @SEARCHVALUE = FILENAME FROM CUSTOMERDOCUMENT WHERE FILEDESCRIPTION = 'CUSTOMER ID PHOTO' AND CUSTOMERID = @BRANCH_ID
  SELECT cid,a.acct_num,C.cType,C.cName,C.country,C.cAddress,C.contact,C.nativCountry,CONVERT(VARCHAR,CAST(C.dob AS DATE),101) DOB,C.idType,C.idNumber,C.postalCode,C.occupation ,businessType = bt.refid,btypetxt =  c.businessType ,s.*,@SEARCHVALUE 'custImage'FROM customerSetup C 
  CROSS apply dbo.FNASplitName(C.CNAME) S
  LEFT join ac_master a ON c.cid = a.acct_type_code AND a.acct_rpt_code ='C'
  LEFT JOIN ref_master bt WITH(NOLOCK) ON c.businessType = bt.ref_code AND ref_rec_type = 107
  WHERE cid = @BRANCH_ID
END 
ELSE IF @FLAG = 'cByCtype' -->> customer detail by customer type
BEGIN
 SELECT cid,cName 
 FROM customerSetup WITH(NOLOCK) 
 WHERE CTYPE = @BRANCH_ID AND cType = @CTYPE   ORDER BY cName
END
ELSE IF @FLAG='businessType' -- Beneficiary ID Type
BEGIN
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=107 order by ref_code
END
ELSE IF @FLAG = 'searchType' -- SEARCH CUSTOMER FROM OPERATION PAGE
BEGIN
 SELECT 'cName' val, 'Customer Name' txt UNION ALL
 SELECT 'CHKID','ID Number' UNION ALL
 SELECT 'contact','Contact Number' 
END
ELSE IF @FLAG = 'aSearch' --CUSTOMER ADVANCE SEARCH 
BEGIN
 DECLARE @SQL VARCHAR(500) =''

 SET @SQL = 'SELECT C.cid,ct.ref_code CTYPE,C.cName,C.cAddress,id.ref_code IDTYPE,C.idNumber,C.contact 
    FROM CUSTOMERSETUP C WITH(NOLOCK)
    INNER JOIN ref_master ct WITH(NOLOCK) ON C.cType = ct.refid
    LEFT JOIN ref_master id WITH(NOLOCK) ON C.idType = id.refid
    WHERE 1=1 AND approvedDate IS NOT NULL AND ISNULL(C.isActive,''Y'')=''Y'''
 --AND C.branchId ='''+@BRANCH_ID+'''
 IF @SEARCHTYPE ='CHKID'
  BEGIN
   UPDATE customersetup SET chkid=REPLACE(REPLACE(REPLACE(idnumber,' ',''),'-',''),'/','') WHERE  chkid IS NULL AND idnumber  IS NOT NULL
   SET @SEARCHVALUE = REPLACE(REPLACE(REPLACE(@SEARCHVALUE,' ',''),'-',''),'/','')
  END

 IF @SEARCHVALUE IS NOT NULL
  SET @SQL = @SQL + ' AND '+ @SEARCHTYPE + ' LIKE '''+@SEARCHVALUE +'%'''
 
 --IF @CTYPE IS NOT NULL
 -- SET @SQL = @SQL +' AND C.cType = '''+CAST(@CTYPE AS VARCHAR)+''''
 
 PRINT @SQL 
 EXEC(@SQL)
 
END
ELSE IF @FLAG = 'docDesc'
BEGIN
 SELECT refid ,ref_code  FROM ref_master WITH(NOLOCK) WHERE ref_rec_type='108' 
END
ELSE IF @FLAG = 'branchType'
BEGIN
 SELECT DISTINCT CASE BRANCH_TYPE WHEN 'A' THEN 'Agent'   
       WHEN 'AP' THEN 'Agent Partner'
       WHEN 'B' THEN 'Branch'
       WHEN 'H' THEN 'Hotel'
     END typeDesc
     ,RTRIM(BRANCH_TYPE) BRANCH_TYPE
 FROM Branches WITH(NOLOCK) WHERE BRANCH_TYPE IS NOT NULL
END
ELSE IF @FLAG = 'BranchByType' --## GET BRANCH LIST BY BRANCH TYPE
BEGIN
 SELECT COMPANY_ID,BRANCH_NAME FROM Branches WITH(NOLOCK) WHERE RTRIM(BRANCH_TYPE) = @SEARCHVALUE AND COMPANY_ID IS NOT NULL ORDER BY BRANCH_NAME
END
ELSE IF @FLAG = 'branchList'
BEGIN
 SELECT COMPANY_ID  , BRANCH_NAME  FROM Branches WITH(NOLOCK) where COMPANY_ID is not null order by BRANCH_NAME
END
ELSE IF @FLAG = 'branchList1'
BEGIN
 SELECT null COMPANY_ID,'All' BRANCH_NAME union all
 SELECT COMPANY_ID  , BRANCH_NAME  FROM Branches WITH(NOLOCK) where COMPANY_ID is not null order by BRANCH_NAME
END
ELSE IF @FLAG ='currList'
BEGIN
 select  curr_code+'('+curr_name+')' [curr_name],curr_code 
 from currency_setup WITH(NOLOCK) where curr_code <> 'MYR' ORDER BY curr_code
END

ELSE IF @FLAG ='RateCode'
BEGIN
 SELECT ratecodeId,rate_code+'-'+rate_description RateCode 
 FROM RateCodeTable WITH(NOLOCK) WHERE ISNULL(active,'N')='Y' 
END
ELSE IF @FLAG ='BlankRateCode'
BEGIN
 SELECT ratecodeId,rate_code+'-'+rate_description RateCode 
 FROM RateCodeTable WITH(NOLOCK) WHERE ISNULL(active,'N')='Y' 
 AND ratecodeId NOT IN(
 SELECT DISTINCT ratecode FROM ExchangeRateTable WHERE ISNULL(active,'N')='Y' )
END
ELSE IF @FLAG ='IndIdtype'  ---->> ONLY FOR INDIVIDUAL CUSTOMER ID TYPE
BEGIN
 SELECT * FROM ref_master WHERE refid <> 728 AND ref_rec_type=101
END
ELSE IF @FLAG ='NonIndIdtype'  ---->> ONLY FOR OTHER THAN INDIVIDUAL CUSTOMER ID TYPE
BEGIN
 SELECT * FROM ref_master WHERE refid=728 AND ref_rec_type=101
END
ELSE IF @FLAG='strReason' -->> str reason 
BEGIN
 select refid,ref_code from ref_master WITH(NOLOCK) where ref_rec_type=109 order by ref_code
END

ELSE IF @FLAG ='txnHistBycId' ---- TRANSACTION HISTORY BY CUSTOMER ID
BEGIN
 SELECT T.customer_name [Customer Name],R.ref_code [ID],T.id_number [ID Number],T.Nationality
  ,BillNo = '<a href="#" onClick="OpenReceipt('''+RTRIM(T.tran_type)+'='+CAST(T.tran_id AS VARCHAR)+''')"> '+ T.BillNo +'</a>'
  ,T.entered_date [Txn. Date]
  ,[Txn. Type] = CASE T.tran_type WHEN 'P' THEN 'BUY' WHEN 'S' THEN 'SELL' END 
  ,CONVERT(VARCHAR,CAST(ISNULL(T.total_amt,0) AS MONEY),1) [Txn. Amount]
 FROM CUSTOMER C WITH(NOLOCK)
 INNER JOIN transaction_info T WITH(NOLOCK) ON C.tran_id = T.tran_id 
 INNER JOIN ref_master R WITH(NOLOCK) ON T.id_type = R.refid
  WHERE CID = @SEARCHVALUE
END

-->>## GRID DROP DOWN 
ELSE IF @FLAG = 'tranType'  ---->> TRANSACTION TYPE
BEGIN
 SELECT NULL '0','Both' '1' UNION ALL
 SELECT 'P','BUY' UNION ALL
 SELECT 'S','SELL'
END
---->>>>  USE ONLY IN GRID FILTER
ELSE IF @FLAG = 'GetBranchList'
BEGIN
 SELECT X.[0],X.[1] FROM (
 SELECT NULL AS [0], 'ALL' [1],1 VAL UNION ALL
 SELECT BRANCH_ID  AS '0', BRANCH_NAME '1', 2 VAL FROM Branches WITH(NOLOCK)
 )X ORDER BY X.VAL,X.[1]
END
ELSE IF @FLAG='ct1'-->>  Customer Type
BEGIN
 SELECT X.[0],X.[1] FROM (
 SELECT NULL AS [0], 'ALL' [1],1 VAL UNION ALL
 SELECT refid,ref_code,2 VAL FROM ref_master WITH(NOLOCK) WHERE ref_rec_type='106'
 )X ORDER BY X.VAL,X.[1]
End
ELSE IF @FLAG = 'ctype_Grid'  --## CUSTOMER TYPE FOR GRID
BEGIN
 SELECT NULL '0','ALL' '1' UNION ALL
 SELECT refid '0',ref_code '1' FROM ref_master WITH(NOLOCK) WHERE ref_rec_type='106' 
 RETURN
END
ELSE IF @FLAG = 'haschange_Grid'  --## CHECK CUSTOMER HAS APPROVED FOR GRID
BEGIN
 SELECT NULL '0','ALL' '1' UNION ALL
 SELECT 'Yes','Yes' UNION ALL
 SELECT 'No','No'
 RETURN
END
ELSE IF @FLAG ='RateCodeList'
BEGIN
 SELECT NULL '0','ALL' '1' UNION ALL
 SELECT ratecodeId,rate_code+'-'+rate_description RateCode 
 FROM RateCodeTable WITH(NOLOCK) WHERE ISNULL(active,'N')='Y' 
END
ELSE IF @FLAG ='statusList'
BEGIN
 SELECT NULL '0','ALL' '1' UNION ALL
 SELECT 'Approved','Approved' UNION ALL
 SELECT 'Rejected','Rejected' 
END

ELSE IF @FLAG = 'hotelCust'   ----## HOTEL ASSIGNED CUSTOMER 
BEGIN
 select TOP 12 c.cid,c.cName from customersetup C WITH(NOLOCK)
 INNER JOIN hotelCustomers H ON C.cid = h.cid
 RETURN
END
ELSE IF @FLAG = 'NonRetailctype'  ----## NON RETAIL CUSTOMER  TYPE LIST
BEGIN
 SELECT NULL '0','ALL' '1' UNION ALL
 SELECT refid '0',ref_code '1' FROM ref_master WITH(NOLOCK) WHERE REFID <> 726 AND ref_rec_type='106' 
END
GO
