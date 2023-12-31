USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_modifyTxnAPI]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_modifyTxnAPI] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(50)		= NULL
	,@tranId			BIGINT			= NULL
	,@newPLocation		INT				= NULL
) 
AS

/*

SELECT * FROM remitTran
EXEC proc_modifyTxnAPI @flag = 'details', @user = 'shree_b1', @controlNo = '91191505349'

*/

DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)
	
	,@sAgent			INT
	,@tAmt				MONEY
	,@cAmt				MONEY
	,@pAmt				MONEY
	,@message			VARCHAR(200)

SET NOCOUNT ON
SET XACT_ABORT ON

--Modify Location----------------------------------------------------------------------------------------------------
IF @flag = 'ml'				--Modify Location
BEGIN
	--Necessary Parameters: @user, @tranId, @newDdlValue
	IF @agentRefId IS NULL
		SET @agentRefId = '4' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7)
		
	IF @newPLocation IS NULL 
	BEGIN
		EXEC proc_errorHandler 1, 'Please enter valid agent payout location!', @tranId
		RETURN
	END
	
	DECLARE 
			 @deliveryMethodId	INT
			,@deliveryMethod	VARCHAR(50)
			,@sBranch			INT
			,@pSuperAgent		INT
			,@sCountryId		INT
			,@sCountry			VARCHAR(100)
			,@pCountryId		INT
			,@pCountry			VARCHAR(100)
			,@pLocation			INT
			,@agentId			INT
			,@amount			MONEY
			,@oldSc				MONEY
			,@newSc				MONEY
			,@collCurr			VARCHAR(3)
	
	SELECT
		 @deliveryMethod	= paymentMethod
		,@sBranch			= sBranch
		,@pSuperAgent		= pSuperAgent
		,@sCountry			= sCountry
		,@pCountry			= pCountry
		,@agentId			= pBranch
		,@amount			= tAmt
		,@oldSc				= serviceCharge	
		,@collCurr			= collCurr
		,@controlNo			= dbo.FNADecryptString(controlNo)
	FROM remitTran WITH(NOLOCK)
	WHERE id = @tranId
	
	SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
	SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry
	SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry
	IF(@sCountry = 'Nepal')
		SELECT @newSc = ISNULL(serviceCharge, 0) FROM dbo.FNAGetDomesticSendComm(@sBranch, NULL, @newPLocation, @deliveryMethodId, @amount)
	ELSE
		SELECT @newSc = ISNULL(amount, -1) FROM [dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountryId, @newPLocation, @agentId , @deliveryMethodId, @amount, @collCurr)
	IF (@oldSc <> @newSc)
	BEGIN
		EXEC proc_errorHandler 1, 'Service charge for this location varies. Cannot modify location.', @tranId
		EXEC proc_errorHandler 1, 'Service charge for this location varies. Cannot modify location.', @tranId
		RETURN
	END
	
	SELECT '0' Code, '123' AGENT_REFID, 'TXN Location Changed' Message, @controlNo REFID
END

IF @flag = 'mpl'
BEGIN
	IF @agentRefId IS NULL
		SET @agentRefId = '4' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '0000000000', 7)
		
	SELECT '0' Code, @agentRefId AGENT_REFID, 'TXN Location Changed' Message, '' REFID
END

----------------------------------------------------------------------------------------------------------------


GO
