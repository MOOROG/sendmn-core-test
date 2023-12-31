USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cancelTranAPI]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM remitTran
EXEC proc_cancelTranAPI @flag = 'details', @user = 'shree_b1', @controlNo = '91191505349'

*/

CREATE proc [dbo].[proc_cancelTranAPI] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@agentRefId		VARCHAR(50)		= NULL
	,@tranId			INT				= NULL	
	,@sCountry			INT				= NULL
	,@sFirstName		VARCHAR(30)		= NULL
	,@sMiddleName		VARCHAR(30)		= NULL
	,@sLastName1		VARCHAR(30)		= NULL
	,@sLastName2		VARCHAR(30)		= NULL
	,@sMemId			VARCHAR(30)		= NULL
	,@sId				BIGINT			= NULL	
	,@sTranId			VARCHAR(50)		= NULL	
	,@rCountry			INT				= NULL
	,@rFirstName		VARCHAR(30)		= NULL
	,@rMiddleName		VARCHAR(30)		= NULL
	,@rLastName1		VARCHAR(30)		= NULL
	,@rLastName2		VARCHAR(30)		= NULL
	,@rMemId			VARCHAR(30)		= NULL
	,@rId				BIGINT			= NULL
	,@pCountry			INT				= NULL

	,@customerId		INT				= NULL
	,@agentId			INT				= NULL
	,@senderId			INT				= NULL
	,@benId				INT				= NULL
	,@cancelReason		VARCHAR(200)	= NULL
	,@refund			CHAR(1)			= NULL
) 
AS

--SELECT * FROM customers
--select * from customerDocument
--select * from customerIdentity


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
--select * from customers

DECLARE
	 @code						VARCHAR(50)
	,@userName					VARCHAR(50)
	,@password					VARCHAR(50)
	
	EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT

DECLARE @controlNoEncrypted VARCHAR(20)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

--Cancel API----------------------------------------------------------------------------------------------------
IF @flag = 'cancelAPI'
BEGIN
	--Necessary Parameters: @user, @controlNo, @agentRefId, @cancelReason
	DECLARE @tranStatus VARCHAR(20)
	SELECT @tranStatus = tranStatus FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	IF @tranStatus = 'Hold'
	BEGIN
		EXEC proc_errorHandler 1, 'Transaction is hold. Transaction must be approved for cancellation.', NULL
		RETURN
	END
	DECLARE @chargeToCustomer INT
	IF @refund = 'Y'
		SET @chargeToCustomer = 0
	ELSE IF @refund = 'N'
		SET @chargeToCustomer = 1
	ELSE IF @refund = 'D'
	BEGIN
		IF EXISTS(SELECT createdDate FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted AND CAST(createdDate AS DATE) = CAST(GETDATE() AS DATE))
		BEGIN
			SET @chargeToCustomer = 0
		END
		ELSE
		BEGIN
			SET @chargeToCustomer = 1
		END
	END
	SELECT @user = 'S:' + @user
	EXEC ime_plus_01.dbo.[spa_SOAP_Domestic_CancelTXN]
		 @accesscode			= @code
		,@username				= @userName
		,@password				= @password
		,@AGENT_REFID			= @agentRefId
		,@control_no			= @controlNo
		,@Cancel_Reason			= @cancelReason
		,@cancel_by				= @user
		,@charge_to_customer	= @chargeToCustomer


END

----------------------------------------------------------------------------------------------------------------

GO
