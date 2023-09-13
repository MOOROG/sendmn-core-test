alter proc proc_CustomerModifyLogs_Report
	@FLAG				VARCHAR(20)
	,@user				VARCHAR(30)		
	,@FROM_DATE			VARCHAR(10)	= NULL
	,@TO_DATE			VARCHAR(10)	= NULL
	,@agentId			BIGINT		= NULL
	,@branchId			BIGINT		= NULL
	,@withAgent			varchar(20) = NULL
AS 
BEGIN
IF @flag = 's'
BEGIN 

	SELECT X.CustomerId,X.MODIFIEDDATE,X.AGENTID INTO #TEMP
	from
	(
		SELECT distinct CustomerId,MAX(MODIFIEDDATE) [MODIFIEDDATE] ,agentId FROM tblCustomerModifylogs where modifiedDate between @FROM_DATE and @TO_DATE + ' 23:59:59'
		and columnname in ('visaStatus','idType','idNumber','idIssueDate','idExpiryDate','additionalAddress','address')
		GROUP BY CUSTOMERID,agentId
	)X
	SELECT row_number() over (order by cm.customerid) SN
		   ,ISNULL(CM.POSTALCODE,CM.membershipId) MembershipId
		   ,CM.FULLNAME [CustomerName]
		   ,isnull(cm.zipcode,'') + isnull(', ' + csm.stateName,'') +  isnull(', ' +cm.city,'') + isnull(', ' + cm.street,'')+isnull(', ' +cm.ADDITIONALADDRESS,'') [Address]
		   ,SDV1.DETAILTITLE [Visa Status]
		   ,SDV.DETAILTITLE [IdType]
		   ,CM.IdNumber
		   ,CONVERT(DATE,cm.IdIssueDate, 121) [IdIssueDate]
		   ,[IdExpiryDate] = CONVERT(DATE,CM.IdExpiryDate,121)
		   ,CONVERT(DATE,CM.DOB,121)  [DOB]
		   ,CM.Mobile
		   ,cm.ModifiedBy
		   ,TMP.ModifiedDate
	FROM customerMaster CM(NOLOCK)
	INNER JOIN #TEMP TMP ON TMP.CustomerId = CM.CustomerId
	LEFT JOIN countryStateMaster csm (nolock) on cast(csm.stateId as varchar) = cm.state
	LEFT JOIN staticdatavalue SDV (NOLOCK) ON SDV.VALUEID = CM.IDTYPE
	LEFT JOIN staticdatavalue SDV1 (NOLOCK) ON SDV1.VALUEID = CM.visaStatus
	INNER JOIN APPLICATIONUSERS AU (nolock) on AU.USERNAME = CM.MODIFIEDBY
	WHERE ISNULL(TMP.agentId,'') = ISNULL(@agentId,TMP.agentId)
	ORDER BY TMP.MODIFIEDDATE


		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'From Date' head,@FROM_DATE VALUE
		UNION ALL
		SELECT 'To Date' head,@TO_DATE VALUE

		SELECT 'Update Customer Report' title
END
END
