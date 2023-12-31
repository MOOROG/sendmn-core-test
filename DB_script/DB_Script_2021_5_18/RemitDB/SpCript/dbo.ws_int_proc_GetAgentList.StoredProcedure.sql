USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_GetAgentList]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ws_proc_GetAgentList]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].ws_proc_GetAgentList

GO
*/
--EXEC ws_proc_GetAgentList @AGENT_CODE='IMEARE01',@USER_ID='arapi01',@PASSWORD='ime@123123',@AGENT_SESSION_ID='1234567',@PAYMENTTYPE='B',@PAYOUT_COUNTRY='Philippines'

CREATE proc [dbo].[ws_int_proc_GetAgentList] 
	@AGENT_CODE			varchar(50),
	@USER_ID			varchar(50),
	@PASSWORD			varchar(50),
	@AGENT_SESSION_ID  varchar(50),
	@PAYMENTTYPE		CHAR(1),
	@PAYOUT_COUNTRY		varchar(50)


AS
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	



	DECLARE @apiRequestId BIGINT
	INSERT INTO requestApiLogOther(
		 AGENT_CODE			
		,USER_ID			
		,PASSWORD			
		,AGENT_SESSION_ID
		,PAYMENTTYPE	
		,PAYOUT_COUNTRY	
		,METHOD_NAME
		,REQUEST_DATE
		
		

	)
	SELECT
		 @AGENT_CODE					
		,@USER_ID			
		,@PASSWORD			
		,@AGENT_SESSION_ID
		,@PAYMENTTYPE	
		,@PAYOUT_COUNTRY	
		,'ws_int_proc_GetAgentList'
		,GETDATE()
		
		SET @apiRequestId = SCOPE_IDENTITY()	


	DECLARE @errCode INT
	DECLARE @autMsg	VARCHAR(500)
	EXEC ws_int_proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT, @autMsg OUT

	DECLARE @errorTable TABLE(
		AGENT_SESSION_ID VARCHAR(150)
		, LOCATIONID MONEY
		, AGENT VARCHAR(150)
		, BRANCH VARCHAR(150)
		, ADDRESS VARCHAR(150)
		, CITY VARCHAR(150)
		, CURRENCY VARCHAR(150)
		, BANKID VARCHAR(150)
	)

	INSERT INTO @errorTable(AGENT_SESSION_ID) 
	SELECT @AGENT_SESSION_ID

	IF(@errCode = 1)
	BEGIN
		SELECT '1002' CODE, ISNULL(@autMsg,'Authentication Fail') MESSAGE, * FROM @errorTable
		RETURN
	END

	IF EXISTS(SELECT 'X' FROM applicationUsers WITH (NOLOCK) WHERE userName = @USER_ID AND forceChangePwd = 'Y')
	BEGIN
		SELECT '1002' CODE, 'You logged on first time,must first change your password and try again!' MESSAGE, * FROM @errorTable
		RETURN
	END
		------------------VALIDATION-------------------------------
		
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT '1001' CODE, 'AGENT SESSION ID Field is Empty' MESSAGE, AGENT_SESSION_ID = @AGENT_SESSION_ID, * FROM @errorTable
		RETURN;
	END
	IF @PAYMENTTYPE IS NULL
	BEGIN
		SELECT '1001' CODE, 'PAYMENT TYPE Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @PAYOUT_COUNTRY IS NULL
	BEGIN
		SELECT '1001' CODE,'PAYOUT COUNTRY Field is Empty' MESSAGE, * FROM @errorTable
		RETURN;
	END
	IF @PAYMENTTYPE NOT IN('B','C','D')
	BEGIN
		SELECT CODE = '3001', MESSAGE = 'Invalid Payment Type, Must be C - Cash Pickup  B - Account Deposit to Bank D - Account Deposit To Other Bank', * FROM @errorTable
		RETURN
	END
	----DECLARE @PAYMENTMODE CHAR(1) = 'D',@PAYOUT_COUNTRY VARCHAR(100)='BANGLADESH'
	DECLARE @PAYMODE VARCHAR(50),@pcountryId VARCHAR(10),@pCurr VARCHAR(5), @countryId INT, @agentId INT, @branchId INT

	SELECT @countryId = countryId, @branchId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @USER_ID AND ISNULL(isDeleted, 'N') = 'N'
	SELECT @agentId = parentId FROM agentMaster WITH(NOLOCK) WHERE agentId = @branchId
	SELECT @pcountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @PAYOUT_COUNTRY

	SELECT @pCurr = currencyCode FROM currencyMaster C WITH (NOLOCK)
	INNER JOIN countryCurrency CC WITH (NOLOCK) ON C.currencyId = CC.currencyId
	WHERE CC.countryId = @pcountryId AND ISNULL(C.isActive,'Y') = 'Y' AND ISNULL(C.isDeleted,'N') = 'N'
	AND ISNULL(CC.isActive,'Y') = 'Y' AND ISNULL(CC.isDeleted,'N') = 'N'

	SET @PAYMODE = CASE WHEN @PAYMENTTYPE = 'B' THEN 'Bank Deposit'
						WHEN @PAYMENTTYPE = 'C' THEN 'Cash Payment'
						WHEN @PAYMENTTYPE = 'D' THEN 'Account Deposit To Other Bank' END

	DECLARE @SQL VARCHAR(MAX)
	DECLARE @agentSelection CHAR (1)
	DECLARE @serviceTypeId INT
	SELECT @serviceTypeId = serviceTypeId FROM serviceTypeMaster WITH (NOLOCK) WHERE typeTitle = @PAYMODE AND ISNULL(isDeleted, 'N') = 'N'

	IF NOT EXISTS(SELECT 'X' FROM countryReceivingMode WITH(NOLOCK) WHERE countryId = @pcountryId)
	BEGIN
		SELECT '5001' CODE, 'You are not allowed to sent to country ' + @PAYOUT_COUNTRY MESSAGE, * FROM @errorTable
		RETURN;
	END
			--------------------------------------------------------------------------------------
	If OBJECT_ID('tempdb..#AGENT') IS NOT NULL
		DROP TABLE [dbo].#AGENT
	----If OBJECT_ID('tempdb..#TempResult') is not null
	----	DROP TABLE [dbo].#TempResult

	DECLARE @TempResult TABLE(
		 LOCATIONID VARCHAR(50)
		,AGENT VARCHAR(200)
		,BRANCH VARCHAR(200)
		,ADDRESS VARCHAR(300)
		,CITY VARCHAR(200)
		,CURRENCY VARCHAR(5)
		,BANKID VARCHAR(350)
		,EXT_BANK_BRANCH_ID VARCHAR(300)
	)

	-->>For Payment Type - Account Deposit to Other Bank	 
	IF @PAYMENTTYPE = 'D'
	BEGIN
		SELECT MAINAGENT, X.AGENTNAME, AGENTID, mapCodeInt, A.agentName BRANCHNAME
		INTO #AGENT 
		FROM 
		(
			SELECT AM.agentId MAINAGENT, AM.AGENTNAME FROM receiveTranLimit RTL WITH(NOLOCK) 
			INNER JOIN agentMaster AM WITH(NOLOCK) ON RTL.agentId = AM.agentId
			WHERE ISNULL(tranType, ISNULL(@serviceTypeId, '0')) = ISNULL(@serviceTypeId, '0')
			AND countryId = @pcountryId
			AND ISNULL(RTL.isActive, 'N') = 'Y'
			AND ISNULL(RTL.isDeleted, 'N') = 'N'
			AND ISNULL(AM.isActive, 'N') = 'Y'
			AND ISNULL(AM.isDeleted, 'N') = 'N' 
		) X
		INNER JOIN agentMaster A ON X.MAINAGENT = A.parentId
		AND ISNULL(A.isHeadOffice, 'N') = 'Y'
		
		INSERT INTO @TempResult(LOCATIONID, AGENT, BRANCH, ADDRESS, CITY, CURRENCY, BANKID, EXT_BANK_BRANCH_ID)
		SELECT * FROM (
			SELECT 
				 LOCATIONID			= X.MAPCODEINT
				,AGENT				= X.AGENTNAME + '-' + Y.bankName
				,BRANCH				= Y.BRANCH
				,address			= Y.address
				,city				= Y.city
				,currency			= @pCurr
				,BANKID				= Y.BANKID
				,EXT_BANK_BRANCH_ID	= Y.EXT_BANK_BRANCH_ID
			FROM (
				SELECT EB.bankName, EB.externalCode BANKID, EBB.ExternalCode EXT_BANK_BRANCH_ID, ISNULL(EBB.branchName, 'Head Office') BRANCH, EBB.address, EBB.city
				FROM  externalBank EB WITH (NOLOCK)
				LEFT JOIN externalBankBranch EBB WITH (NOLOCK) ON EB.extBankId = EBB.extBankId
				WHERE EB.externalBankType = '7401'
				AND EB.country = @PAYOUT_COUNTRY
				AND ISNULL(EB.isDeleted,'N') = 'N'
				AND internalCode IS NULL
			)Y, #AGENT X

			UNION ALL
			
			SELECT  
				 LOCATIONID			= X.MAPCODEINT
				,AGENT				= X.AGENTNAME + '-' + bankName
				,BRANCH				= EBC.externalCode 
				,address			= NULL
				,city				= NULL
				,currency			= @pCurr
				,BANKID				= EB.externalCode
				,EXT_BANK_BRANCH_ID	= NULL
			FROM  externalBank EB WITH(NOLOCK)
			INNER JOIN ExternalBankCode EBC WITH(NOLOCK) ON EBC.bankId = EB.extBankId
			INNER JOIN #AGENT X ON EBC.agentId = X.MAINAGENT
			WHERE EB.country = @PAYOUT_COUNTRY
			AND externalBankType = '7400'
			AND ISNULL(EB.isDeleted,'N') = 'N'
			AND ISNULL(EBC.isDeleted,'N') = 'N'
		) X
		 
	END
	ELSE
	BEGIN
	-->>For Payment Type except Account Deposit to Other Bank
		--SELECT 
		--@countryId =181   ---QATAR
	 --  ,@PAYOUT_COUNTRY =174  ----- 16 BANGLADESH | 174  PHILIPPINES
	 --  ,@serviceTypeId =1   -- A/c Deposit
	 --  ,@agentid=  '1073'   ---Al Dar For Exchange Works
		INSERT INTO @TempResult(LOCATIONID, AGENT, BRANCH, ADDRESS, CITY, CURRENCY, BANKID)
		SELECT
			 LOCATIONID			= ebb.extBranchId
			,AGENT				= eb.bankName
			,[BRANCH]			= ebb.branchName
			,[ADDRESS]			= ebb.address
			,[CITY]				= ebb.city
			,currency			= @pCurr
			,BANKID				= eb.externalCode
		FROM externalBank eb WITH(NOLOCK)
		INNER JOIN externalBankBranch ebb WITH(NOLOCK) ON eb.extBankId = ebb.extBankId
		WHERE eb.country = 'Nepal' AND eb.country = @PAYOUT_COUNTRY AND @PAYMENTTYPE = 'B'

		UNION ALL

		SELECT 
			 LOCATIONID			= am.mapCodeInt 
			,[AGENT]			= X.agentName 
			,[BRANCH]			= am.agentName  
			,[ADDRESS]			= am.agentAddress 
			,CITY				= am.agentCity 
			,currency			= @pCurr 
			,BANKID				= am.mapCodeInt 
		--,extcode
		FROM agentMaster am WITH(NOLOCK)
		,(
			SELECT AM.AGENTID, UPPER(AGENTNAME) AGENTNAME, MIN(maxLimitAmt) maxLimitAmt, MAPCODEINT
			FROM agentMaster AM WITH(NOLOCK) INNER JOIN 
			(
				-->>For Country Receiving Mode - Applicable For All
				SELECT AM.agentId,maxLimitAmt FROM receiveTranLimit RTL WITH (NOLOCK) 
				INNER JOIN agentMaster AM WITH(NOLOCK) ON RTL.countryId = AM.agentCountryId
				INNER JOIN countryReceivingMode CRM ON RTL.COUNTRYID = CRM.COUNTRYID
				WHERE RTL.countryId = @pcountryId 
				AND ISNULL(CRM.applicablefor,'A') = 'A'
				AND ISNULL(sendingCountry, ISNULL(@countryId,0)) = ISNULL( @countryId,0) 
				AND ISNULL(TRANTYPE, ISNULL(@serviceTypeId ,0)) = ISNULL( @serviceTypeId,0) 
				AND ISNULL(CRM.receivingmode, '0') = @serviceTypeId
				AND ISNULL(RTL.isActive,'N') = 'Y'
				AND ISNULL(RTL.isDeleted,'N') = 'N'
				--AND ISNULL(AM.routing,'N') = 'N'
				AND ISNULL(AM.isActive,'N')='Y'
				AND ISNULL(AM.isDeleted,'N')='N'
				AND RTL.agentId IS NULL
				AND AM.agentType='2903' AND am.agentId = (CASE WHEN @PAYMENTTYPE = 'B' AND @pcountryId = 151 THEN 2 ELSE AM.agentId END)
				
				UNION ALL
				
				-->>For Country Receiving Mode - Applicable For Agent Specific
				SELECT AM.agentId, maxLimitAmt FROM receiveTranLimit RTL WITH(NOLOCK) 
				INNER JOIN agentMaster AM WITH(NOLOCK) ON RTL.countryId = AM.agentCountryId
				INNER JOIN countryReceivingMode CRM ON RTL.countryId = CRM.countryId
				WHERE RTL.countryId = @pcountryId
				AND ISNULL(CRM.applicablefor, 'A') = 'S'
				AND ISNULL(sendingCountry, ISNULL(@countryId,0)) = ISNULL(@countryId,0) 
				AND ISNULL(TRANTYPE,ISNULL(@serviceTypeId, 0)) = ISNULL(@serviceTypeId,0) 
				AND ISNULL(CRM.receivingmode, '0') = @serviceTypeId
				AND ISNULL(RTL.isActive,'N') = 'Y'
				AND ISNULL(RTL.isDeleted,'N') = 'N'
				--AND ISNULL(AM.routing,'N')='N'
				AND ISNULL(AM.isActive,'N') = 'Y'
				AND ISNULL(AM.isDeleted,'N') = 'N'
				AND RTL.agentId = @agentid
				AND AM.agentType = '2903'

				UNION ALL 

				SELECT RTL.agentId, maxLimitAmt FROM receiveTranLimit RTL WITH(NOLOCK) 
				INNER JOIN agentMaster AM WITH(NOLOCK) ON RTL.agentId = AM.agentId
				WHERE RTL.countryId = @pcountryId
				AND ISNULL(sendingCountry, ISNULL(@countryId,0)) = ISNULL(@countryId, 0) 
				AND ISNULL(TRANTYPE, ISNULL(@serviceTypeId,0)) = ISNULL(@serviceTypeId,0) 
				AND ISNULL(RTL.isActive,'N') = 'Y'
				AND ISNULL(RTL.isDeleted,'N') = 'N'
				--AND ISNULL(AM.routing,'N')='N'
				AND ISNULL(AM.isActive,'N') = 'Y'
				AND ISNULL(AM.isDeleted,'N') = 'N'
				AND RTL.agentId IS NOT NULL

				UNION ALL

				SELECT receivingAgent,max (maxLimitAmt)maxLimitAmt
				FROM sendTranLimit SL WITH(NOLOCK)
				INNER JOIN agentMaster AM WITH(NOLOCK) ON SL.agentId=AM.agentId
				INNER JOIN agentMaster AM1 WITH(NOLOCK) ON SL.receivingAgent=AM1.agentId
				WHERE countryId = @countryId
				AND SL.receivingCountry= @pcountryId 
				AND SL.agentId= @agentid
				AND ISNULL(SL.isActive,'N')='Y'
				AND ISNULL(SL.isDeleted,'N')='N'
				AND receivingAgent IS NOT NULL
				--AND ISNULL(AM1.routing,'N')='N'
				AND ISNULL(AM1.isActive,'N')='Y'
				AND ISNULL(AM1.isDeleted,'N')='N'
				AND ISNULL(AM.isActive,'N')='Y'
				AND ISNULL(AM.isDeleted,'N')='N'
				AND ISNULL(SL.tranType,ISNULL( @serviceTypeId,0))=ISNULL( @serviceTypeId,0)
				----AND ISNULL(SL.collmode,ISNULL( @collectionmode,0))=ISNULL( @collectionmode,0)
				----AND ISNULL(customerType,ISNULL( @customerType,0))=ISNULL( @customerType,0)
				----AND SL.currency=@currency
				GROUP BY receivingAgent
			) X ON AM.agentId = X.agentId AND ISNULL(AM.isActive,'N') = 'Y' AND ISNULL(AM.isDeleted,'N') = 'N'
			GROUP BY AM.agentId, AM.agentName, AM.MAPCODEINT
			HAVING MIN(X.maxLimitAmt) > 0
		) X

		WHERE AM.PARENTID = X.AGENTID
		ORDER BY AGENT, BRANCH
	END   
	  
	IF EXISTS(SELECT 'X' FROM @TempResult)
	BEGIN
		SELECT 
			 CODE					= '0' 
			,AGENT_SESSION_ID		= @AGENT_SESSION_ID 
			,MESSAGE				= 'Success'			
			,LOCATIONID				= LOCATIONID			
			,AGENT					= AGENT		
			,BRANCH					= BRANCH		
			,ADDRESS				= ADDRESS		
			,CITY					= CITY		 
			,CURRENCY				= currency	
			,BANKID					= BANKID	
			,EXT_BANK_BRANCH_ID		= EXT_BANK_BRANCH_ID			
		FROM @TempResult 
		ORDER BY AGENT

			UPDATE requestApiLogOther SET 
			errorCode = '0'
			,errorMsg = 'Success'			
			WHERE rowId = @apiRequestId


	END
	ELSE
	BEGIN
		SELECT 
			 CODE					= '5001'
			,AGENT_SESSION_ID		= @AGENT_SESSION_ID
			,MESSAGE				= 'Location Not Found'
			,LOCATIONID				= NULL
			,AGENT					= NULL
			,BRANCH					= NULL
			,ADDRESS				= NULL
			,CITY					= NULL
			,CURRENCY				= NULL
			,BANKID					= NULL
			,EXT_BANK_BRANCH_ID		= NULL
	END   
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN

	SELECT 
		 CODE					= '9001'
		,AGENT_SESSION_ID		= @AGENT_SESSION_ID
		,MESSAGE				= 'Technical Error : ' + ERROR_MESSAGE()
		,LOCATIONID				= NULL
		,AGENT					= NULL
		,BRANCH					= NULL
		,ADDRESS				= NULL
		,CITY					= NULL
		,CURRENCY				= NULL
		,BANKID					= NULL
		,EXT_BANK_BRANCH_ID		= NULL

	INSERT INTO Logs (errorPage, errorMsg, errorDetails, createdBy, createdDate)
	SELECT 'API SP Error','Technical Error : ' + ERROR_MESSAGE() MESSAGE,'ws_proc_GetAgentList',@USER_ID, GETDATE()
END CATCH

GO
