USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ApCashExpressTXN]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC proc_ApCashExpressTXN @flag = 'details', @user = 'bajrashali_b1', @tranId = '1', @controlNo = '91191505349'

*/

CREATE proc [dbo].[proc_ApCashExpressTXN] (	 
	 @flag						VARCHAR(50)	
	,@rowId						BIGINT			= NULL	
	,@controlNo					VARCHAR(20)		= NULL	
    ,@agentId					VARCHAR(10)		= NULL
	,@agentRequestId			VARCHAR(30)		= NULL
	,@beneAddress				VARCHAR(200)	= NULL
	,@beneBankAccountNumber		VARCHAR(30)		= NULL
	,@beneBankBranchCode		VARCHAR(20)		= NULL
	,@beneBankBranchName		VARCHAR(100)	= NULL
	,@beneBankCode				VARCHAR(30)		= NULL
	,@beneBankName				VARCHAR(100)	= NULL
	,@beneIdNo					VARCHAR(20)		= NULL
	,@beneName					VARCHAR(200)	= NULL
	,@rFirstName				VARCHAR(50)		= NULL
	,@rMiddleName				VARCHAR(50)		= NULL
	,@rLastName1				VARCHAR(50)		= NULL
	,@rLastName2				VARCHAR(50)		= NULL
	,@benePhone					VARCHAR(100)	= NULL
	,@custAddress				VARCHAR(500)	= NULL
	,@custIdDate				VARCHAR(50)		= NULL
	,@custIdNo					VARCHAR(20)		= NULL
	,@custIdType				VARCHAR(20)		= NULL
	,@custName					VARCHAR(200)	= NULL
	,@sFirstName				VARCHAR(50)		= NULL
	,@sMiddleName				VARCHAR(50)		= NULL
	,@sLastName1				VARCHAR(50)		= NULL
	,@sLastName2				VARCHAR(50)		= NULL				
	,@custNationality			VARCHAR(100)	= NULL
	,@custPhone					VARCHAR(30)		= NULL
	,@description				VARCHAR(500)	= NULL
	,@destinationAmount			VARCHAR(10)		= NULL
	,@destinationCurrency		VARCHAR(5)		= NULL
	,@gitNo						VARCHAR(15)		= NULL
	,@paymentMode				VARCHAR(30)		= NULL
	,@purpose					VARCHAR(100)	= NULL
	,@responseCode				VARCHAR(10)		= NULL
	,@settlementCurrency		VARCHAR(5)		= NULL
	,@status					VARCHAR(100)	= NULL
	,@pBranch					INT				= NULL
	,@user						VARCHAR(50)		= NULL
	,@rIdType					VARCHAR(50)		= NULL
	,@rIdNo						VARCHAR(30)		= NULL
	,@rPlaceOfIssue				VARCHAR(200)	= NULL
	,@rIssuedDate				DATETIME		= NULL
	,@rValidDate				DATETIME		= NULL
	,@sortBy					VARCHAR(50)		= NULL
	,@sortOrder					VARCHAR(5)		= NULL
	,@pageSize					INT				= NULL
	,@pageNumber				INT				= NULL
) 
AS

DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)

SET NOCOUNT ON
SET XACT_ABORT ON

SELECT @pageSize = 1000, @pageNumber = 1

DECLARE
	 @tranId					BIGINT 
	,@sBranch					INT
	,@sBranchName				VARCHAR(100)
	,@sAgent					INT
	,@sAgentName				VARCHAR(100)
	,@sSuperAgent				INT
	,@sSuperAgentName			VARCHAR(100)
	,@pSuperAgent				INT
	,@pSuperAgentName			VARCHAR(100)
	,@pAgent					INT
	,@pAgentName				VARCHAR(100)
	,@pBranchName				VARCHAR(100)
	,@pCountry					VARCHAR(100)
	,@pState					VARCHAR(100)
	,@pDistrict					VARCHAR(100)
	,@pLocation					INT
	,@deliveryMethod			VARCHAR(100)
	,@cAmt						MONEY
	,@pAmt						MONEY
	,@serviceCharge				MONEY
	,@pAgentComm				MONEY
	,@pAgentCommCurrency		VARCHAR(3)
	,@pSuperAgentComm			MONEY
	,@pSuperAgentCommCurrency	VARCHAR(3)
	,@pHubComm					MONEY
	,@pHubCommCurrency			VARCHAR(3)
	,@collMode					INT
	,@sendingCustType			INT
	,@receivingCurrency			INT
	,@senderId					INT
	,@payoutMethod				INT
	,@agentType					INT
	,@actAsBranchFlag			CHAR(1)
	,@tokenId					BIGINT
	,@controlNoEncrypted		VARCHAR(20)

	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

IF @flag = 'temp'
BEGIN
	INSERT INTO ApCashExpressTXN (
		 controlNo
		,agentId				
		,agentRequestId
		,beneAddress
		,beneBankAccountNumber
		,beneBankBranchCode
		,beneBankBranchName
		,beneBankCode
		,beneBankName
		,beneIdNo
		,beneName
		,benePhone
		,custAddress
		,custIdDate		
		,custIdNo		
		,custIdType
		,custName
		,custNationality
		,custPhone
		,[description]
		,destinationAmount
		,destinationCurrency
		,gitNo
		,paymentMode
		,purpose
		,responseCode
		,settlementCurrency
		,[status]
		,fetchUser
		,fetchDate
	)
	SELECT 
		 @controlNo
		,@agentId				
		,@agentRequestId
		,@beneAddress
		,@beneBankAccountNumber
		,@beneBankBranchCode
		,@beneBankBranchName
		,@beneBankCode
		,@beneBankName
		,@beneIdNo
		,@beneName
		,@benePhone
		,@custAddress
		,@custIdDate		
		,@custIdNo		
		,CASE WHEN @custIdType = '1' THEN 'Passport'
				WHEN @custIdType = '2' THEN 'Driving License'
				WHEN @custIdType = '3' THEN 'Work Permit'
				WHEN @custIdType = '4' THEN 'National ID'
				WHEN @custIdType = '5' THEN 'Civil ID'
				WHEN @custIdType = '6' THEN 'Election ID'
				WHEN @custIdType = '7' THEN 'Ration Card'
				WHEN @custIdType = '8' THEN 'Health Card'
				WHEN @custIdType = '99' THEN 'Others'
				END
		,@custName
		,@custNationality
		,@custPhone
		,@description
		,@destinationAmount
		,@destinationCurrency
		,@gitNo
		,CASE WHEN @paymentMode = '1' THEN 'Cash Payment' 
				WHEN @paymentMode = '2' THEN 'Bank Deposit' END
		,@purpose
		,@responseCode
		,@settlementCurrency
		,@status
		,@user
		,GETDATE()
	
	SET @rowId = SCOPE_IDENTITY()
	SELECT * FROM ApCashExpressTXN WHERE sno = @rowId
END

ELSE IF @flag = 'pay'
BEGIN
	SELECT
		 @custName				= custName
		,@custAddress			= custAddress
		,@custNationality		= custNationality
		,@custPhone				= custPhone
		,@custIdType			= custIdType
		,@custIdNo				= custIdNo
		,@custIdDate			= custIdDate
		,@beneName				= beneName
		,@beneAddress			= beneAddress
		,@benePhone				= benePhone
		,@beneBankAccountNumber = beneBankAccountNumber
		,@beneBankBranchCode	= beneBankBranchCode
		,@beneBankBranchName	= beneBankBranchName
		,@beneBankCode			= beneBankCode
		,@beneBankName			= beneBankName
		,@beneIdNo				= beneIdNo
		,@destinationAmount		= destinationAmount
		,@destinationCurrency	= destinationCurrency
		,@paymentMode			= paymentMode
		,@purpose				= purpose
		,@settlementCurrency	= settlementCurrency
	FROM ApCashExpressTXN WHERE sno = @rowId
	
	--1. Find Sending Agent Details-------------------------------------------------------------------------
	SELECT @sBranch = agentId, @agentType = agentType FROM agentMaster WITH(NOLOCK) WHERE agentCode = 'CASHEXPRESS' AND ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'N') = 'Y'
	IF @agentType = 2903
	BEGIN
		SET @sAgent = @sBranch
	END
	ELSE
	BEGIN
		SELECT @sAgent = parentId, @sBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sBranch
	END
	SELECT @sSuperAgent = parentId, @sAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sAgent
	SELECT @sSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @sSuperAgent
	--End of Find Sending Agent Details----------------------------------------------------------------------
	
	--2. Find Payout Agent Details---------------------------------------------------------------------------
	IF @pBranch IS NULL
		SELECT @pBranch = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user 
	SELECT 
		 @pCountry = agentCountry
		,@pState = agentState
		,@pDistrict = agentDistrict
		,@pLocation = agentLocation 
	FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch 
	
	--Payout
	SELECT @agentType = agentType, @pbranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
	--Check for branch or agent acting as branch
	IF @agentType = 2903	--Agent
	BEGIN
		SET @pAgent = @pBranch
	END
	ELSE
	BEGIN
		SELECT @pAgent = parentId, @pBranchName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pBranch
	END
	SELECT @pSuperAgent = parentId, @pAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pAgent
	SELECT @pSuperAgentName = agentName FROM agentMaster WITH(NOLOCK) WHERE agentId = @pSuperAgent
	--End of Find Payout Agent Details--------------------------------------------------------------------------------
	
	--3. Find Settling Agent-------------------------------------------------------------------------------------------
	DECLARE @settlingAgent INT = NULL
	SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @pBranch AND isSettlingAgent = 'Y'
	IF @settlingAgent IS NULL
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @pAgent AND isSettlingAgent = 'Y'
	IF @settlingAgent IS NULL
		SELECT @settlingAgent = agentId FROM agentMaster WHERE agentId = @pSuperAgent AND isSettlingAgent = 'Y'
	--End of Find Settling Agent--------------------------------------------------------------------------------------
	
	--4. Commission Calculation Start
	SET @payoutMethod = 'Cash Payment'
	DECLARE @pCountryId INT = NULL
	SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry 
	
	SELECT @pAgentComm = 0
	SELECT @pAgentCommCurrency = 'NPR'
	
	--Commission Calculation End
		
	BEGIN TRANSACTION
		BEGIN
		--Transaction Insert
		INSERT INTO remitTran(
			 controlNo
			,pAgentComm
			,pAgentCommCurrency
			,pSuperAgentComm
			,pSuperAgentCommCurrency
			,pHubComm
			,pHubCommCurrency
			,sBranch
			,sBranchName
			,sAgent
			,sAgentName
			,sSuperAgent
			,sSuperAgentName
			,pBranch
			,pBranchName
			,pAgent
			,pAgentName
			,pSuperAgent
			,pSuperAgentName
			,pCountry
			,pState
			,pDistrict
			,pLocation
			,tAmt
			,collCurr
			,pAmt
			,payoutCurr
			,paymentMethod
			,tranStatus
			,payStatus
			,createdBy
			,createdDate
			,approvedBy
			,approvedDate
			,paidDate
			,paidDateLocal
			,paidBy
		)
		SELECT
			 @controlNoEncrypted
			,@pAgentComm
			,@pAgentCommCurrency
			,@pSuperAgentComm
			,@pSuperAgentCommCurrency
			,@pHubComm
			,@pHubCommCurrency
			,@sBranch
			,@sBranchName
			,@sAgent
			,@sAgentName
			,@sSuperAgent
			,@sSuperAgentName
			,@pBranch
			,@pBranchName
			,@pAgent
			,@pAgentName
			,@pSuperAgent
			,@pSuperAgentName
			,@pCountry
			,@pState
			,@pDistrict
			,@pLocation
			,NULL
			,NULL
			,@destinationAmount
			,@destinationCurrency
			,@paymentMode
			,'Paid'
			,'Paid'
			,'system'
			,NULL
			,NULL
			,NULL
			,GETDATE()
			,dbo.FNADateFormatTZ(GETDATE(), @user)
			,@user
		
		SET @tranId = SCOPE_IDENTITY()
		--Sender Insert
		INSERT INTO tranSenders(
			tranId, firstName, middleName, lastName1, lastName2, address, mobile
		)
		SELECT
			@tranId,@sFirstName,@sMiddleName,@sLastName1,@sLastName2,@custAddress,@custPhone
		
		--Receiver Insert
		INSERT INTO tranReceivers(
			tranId, firstName, middleName, lastName1, lastName2, address, mobile
			, idType, idNumber, idPlaceOfIssue, issuedDate, validDate
		)
		SELECT
			@tranId,@rFirstName,@rMiddleName,@rLastName1,@rLastName2,@beneAddress,@benePhone
			,@rIdType,@rIdNo,@rPlaceOfIssue,@rIssuedDate,@rValidDate
		END
	--A/C Master
		EXEC proc_updatePayTopUpLimit @settlingAgent, @destinationAmount			
	IF @@TRANCOUNT > 0
	COMMIT TRANSACTION
	
	EXEC [proc_errorHandler] 0, 'Transaction paid successfully', @tranId	
END

GO
