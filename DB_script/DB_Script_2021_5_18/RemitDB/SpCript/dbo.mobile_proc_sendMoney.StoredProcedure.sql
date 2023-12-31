USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_sendMoney]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC mobile_proc_sendMoney @Flag='load',@pCountry='pk',@receiverId = '268980',@customerId='32994'
--EXEC mobile_proc_sendMoney @flag='bankBranch', @pCountry = 'NP', @receiverId = '26663',@Bank='1066',@Search='CCBL'
CREATE PROC [dbo].[mobile_proc_sendMoney](
	 @Flag			VARCHAR(20)	= NULL
	,@pCountry		VARCHAR(10)	= NULL 
	,@receiverId	VARCHAR(10)	= NULL 
	,@Bank			VARCHAR(100)= NULL 
	,@Search		VARCHAR(100)= NULL 
	,@customerId	INT		    = NULL 
)
AS
SET NOCOUNT ON
BEGIN
	IF @Flag='load'
	BEGIN
		IF OBJECT_ID('tempdb..#payoutMode') IS NOT NULL
			DROP TABLE #payoutMode

		IF OBJECT_ID('tempdb..#tempBankList') IS NOT NULL
			DROP TABLE #tempBankList
		
		SELECT @pCountry = CM.countryId 
		FROM dbo.countryMaster(NOLOCK) AS CM 
		WHERE CM.countryCode = @pCountry

		SELECT DISTINCT * INTO #payoutMode FROM (
		SELECT 
			CRM.countryId
			,Id = crm.receivingMode
			,Mode = STM.typeDesc
			,PayoutPartner = TPC.AgentId
			,BankRequired = CASE WHEN crm.agentSelection ='N' THEN 'False' ELSE 'True' END 
		--INTO #payoutMode
		FROM dbo.countryReceivingMode(NOLOCK) AS CRM
		INNER JOIN dbo.serviceTypeMaster(NOLOCK) AS STM ON CRM.receivingMode = STM.serviceTypeId
		INNER JOIN dbo.TblPartnerwiseCountry(NOLOCK) AS TPC ON TPC.CountryId = CRM.countryId AND CRM.receivingMode = ISNULL(TPC.PaymentMethod,CRM.receivingMode)
		WHERE CRM.countryId = @pCountry AND TPC.IsActive = 1
		AND STM.isActive = 'Y'
		)x
		
		SELECT 
			 AM.agentCountryId AS countryId
			,am.agentId AS Id,am.agentName AS [Name]
			,am.agentCode AS Code
			,AgentRole
			,parentId =CASE WHEN @pCountry=151 THEN '1036' ELSE am.parentId END
			,am.agentState
			,am.isInternal ---- this field is used for account validation 1: allow to do account validation , 0 or null : no need validation
		INTO #tempBankList
		FROM dbo.agentMaster(NOLOCK) AS AM
		WHERE AM.agentType = 2903 AND AM.isActive = 'Y' AND AM.agentCountryId = @pCountry
		AND ISNULL(isApiPartner,'0') = '0'
		ORDER BY am.agentId
		

		--DECLARE @col varchar(MAX);
		--SELECT @col = COALESCE(@col + ',', '') + xx.value
		--FROM (
		--	SELECT DISTINCT p.PayoutPartner,x.value FROM #payoutMode p
		--	INNER JOIN (
		--			SELECT @pCountry AS Country,* FROM dbo.GetCountryCurrency(@pCountry,null,null)
		--		)x ON x.Country = p.countryId
		--	)xx WHERE xx.value <> 'KRW'

		----## GET COUNTRY INFO
		SELECT CM.countryId AS Id,CM.countryName AS Name, CM.countryCode AS Code 
		FROM dbo.countryMaster(NOLOCK) AS CM 
		WHERE CM.countryId = @pCountry

		SELECT 
			 PM.countryId AS CountryId
			,PM.Id AS ModeId
			,PM.Mode,PM.PayoutPartner
			,PayCurrency = dbo.GetAllowCurrency(@pCountry,Id,null)
			,BankRequired
		FROM #payoutMode AS PM 
		WHERE PM.PayoutPartner IS NOT NULL 
		ORDER BY PM.Mode ASC
		

		CREATE TABLE #TEMPBRANCH(parentId BIGINT)

		IF @pCountry NOT IN (151)
		BEGIN
			INSERT INTO #TEMPBRANCH
			SELECT DISTINCT parentId FROM agentMaster(NOLOCK) 
			WHERE agentCountryId = @pCountry AND agentType = '2904' AND isActive = 'Y'
		END

		--SELECT * FROM #tempBankList
		--SELECT * FROM #payoutMode
		--RETURN
		----## GET COUNTRY WISE PAYMODE AND PARTNER
		SELECT 
			 t.countryId,t.id
			 ,Name = t.Name + CASE WHEN t.parentId in (224388,2140,392226) THEN ISNULL(' - ' +t.Code, '') WHEN t.countryId = 142 THEN ISNULL(' - ' + t.agentState, '') ELSE '' END
			 ,t.Code,AgentRole = PM.Id
			--,CASE WHEN dbo.IsBranchRequired(t.Id)=0 THEN 'False' ELSE 'True' END AS BranchRequired
			,BranchRequired = CASE WHEN A.parentId IS NOT NULL THEN 'True' ELSE 'False' END
			,IsAccountRequired = CASE WHEN PM.BankRequired = 'True' AND PM.Id NOT IN( 1 ) THEN 'True' ELSE 'False' END
			--,IsAccountValidation = CASE WHEN PM.BankRequired='True' AND dbo.IsBankAccountValidationReq(pm.countryId,pm.Id,t.Id) = 1 THEN 'True' ELSE 'False' END
			,IsAccountValidation = CASE WHEN isInternal='1' THEN 'True' ELSE 'False' END
		FROM #tempBankList t 
		INNER JOIN #payoutMode AS PM ON PM.BankRequired = 'True' AND pm.PayoutPartner = t.parentId 
		LEFT JOIN #TEMPBRANCH a(nolock) ON A.parentId = T.Id  
		WHERE PM.Id = ISNULL(t.AgentRole,PM.ID)
		ORDER BY T.Name	


		SELECT TOP (30)
			 TBL.Id AS BankId
			,AM.agentId  AS Id
			,[Name] = CASE WHEN agentCountryId <> '151' THEN AgentName + ' - ' + CAST(agentCode AS VARCHAR) ELSE AgentName END
		FROM dbo.agentMaster(NOLOCK) AS AM 
		INNER JOIN #tempBankList AS TBL ON AM.parentId = TBL.Id 
		WHERE AM.agentType = 2904
		ORDER BY [Name]

		SELECT DISTINCT
			 Currency = X.value
			 ,T.Id
			 ,X.[Key]
		FROM #tempBankList t 
		INNER JOIN #payoutMode AS PM ON PM.BankRequired = 'True' AND pm.PayoutPartner = t.parentId 
		CROSS APPLY DBO.GetCountryCurrency(@pCountry,PM.Id,T.Id)X
		WHERE PM.Id = ISNULL(t.AgentRole,PM.ID)
		ORDER BY X.[Key] DESC

		--SELECT
		--	DISTINCT Currency = dbo.GetAllowCurrency(AM.agentCountryId,am.agentRole,AM.agentId)
		--	,am.agentId AS Id
		--FROM dbo.agentMaster AS AM(NOLOCK)
		--WHERE AM.agentType = 2903 AND AM.isActive = 'Y' 
		--AND AM.agentCountryId = @pCountry AND ISNULL(AM.isApiPartner,'0') = '0'
		--ORDER BY am.agentId

		SELECT * FROM dbo.receiverInformation (NOLOCK) 
		WHERE receiverId = @receiverId

	END
	IF @Flag='bankBranch'
	BEGIN	
		--IF @countryId IN (105, 174, 151)
		--BEGIN  
		--	SELECT 0 agentId,agentName = 'Any Branch'  
		--	RETURN  
		--END  
		SELECT top 20  
				Id = BRANCH_ID   
				,[Name] = CASE WHEN BRANCH_COUNTRY <> 'NEPAL' THEN BRANCH_NAME + ' - ' + CAST(BRANCH_CODE1 AS VARCHAR) ELSE BRANCH_NAME END  
				,BranhCode = BRANCH_CODE1
		FROM API_BANK_BRANCH_LIST WITH(NOLOCK)  
		WHERE IS_ACTIVE = 1  
		AND BANK_ID = @Bank
		AND (BRANCH_NAME LIKE '%'+ISNULL(@Search, BRANCH_NAME)+'%' OR BRANCH_CODE1 LIKE '%'+ISNULL(@Search, BRANCH_CODE1)+'%')
		ORDER BY [Name]
	END
END
GO
