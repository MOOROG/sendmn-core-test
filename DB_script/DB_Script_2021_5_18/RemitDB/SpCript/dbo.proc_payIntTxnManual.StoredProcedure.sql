USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_payIntTxnManual]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* 
exec proc_payIntTxnManual @flag ='payTran',@user ='sheela123',@pBranch = '1247'
*/
CREATE proc [dbo].[proc_payIntTxnManual] (	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@pBranch			INT				= NULL
	,@controlNo			VARCHAR(20)		= NULL	
	,@agentRefId		VARCHAR(20)		= NULL
	,@rIdType			VARCHAR(30)		= NULL
	,@rIdNumber			VARCHAR(30)		= NULL
	,@rPlaceOfIssue		VARCHAR(50)		= NULL
	,@rMobile			VARCHAR(100)	= NULL
	,@rRelationType		VARCHAR(50)		= NULL
	,@rRelativeName		VARCHAR(100)	= NULL	
	,@membershipId		VARCHAR(50)		= NULL
    ,@customerId		VARCHAR(50)		= NULL
) 
AS

SET NOCOUNT ON
SET XACT_ABORT ON

	DECLARE 
	     @sCountry					VARCHAR(200)
		,@sCountryId				INT 
		,@sBranch					INT
		,@sAgent					INT
		,@sSuperAgent				INT
		,@sSuperAgentName			VARCHAR(100)
		,@sLocation					INT
		,@pSuperAgent				INT
		,@pSuperAgentName			VARCHAR(100)
		,@pAgent					INT
		,@pAgentName				VARCHAR(100)
		,@pBranchName				VARCHAR(100)
		,@pCountry					VARCHAR(100)
		,@pCountryId				INT
		,@pState					VARCHAR(100)
		,@pDistrict					VARCHAR(100)
		,@pLocation					INT
		,@deliveryMethod			VARCHAR(100)
		,@deliveryMethodId			INT 
		,@pAmt						MONEY
		,@cAmt						MONEY
		,@pAgentComm				MONEY
		,@pAgentCommCurrency		VARCHAR(3)
		,@pSuperAgentComm			MONEY
		,@pSuperAgentCommCurrency	VARCHAR(3)
		,@pHubComm					MONEY
		,@pHubCommCurrency			VARCHAR(3)
		,@collMode					INT
		,@receivingCurrency			INT
		,@senderId					INT
		,@agentType					INT
		,@actAsBranchFlag			CHAR(1)
		,@tokenId					BIGINT
		,@controlNoEncrypted		VARCHAR(20)
		,@mapCodeInt				VARCHAR(20)
		,@commCheck					MONEY
		,@settlingAgent				int
		,@userId					int
		,@tranId					BIGINT
		,@serviceCharge				MONEY
		,@sRouteId					VARCHAR(5)
		,@lockStatus				VARCHAR(10)
	
	SELECT @controlNo = UPPER(LTRIM(RTRIM(@controlNo)))
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)
	/*
	SELECT agentType,actAsbranch,* FROM agentMaster with(nolock) where agentId =1247 
	select * from applicationUsers with(nolock) where agentId = 1247 --sheela123

	*/
	IF @flag = 'payTran' 
	BEGIN	
		
		SELECT TOP 150 * INTO #TEMP_TXN
		FROM RemittanceLogData.dbo.unpaidTxn with(nolock) where  IS_PAID is null and flag is null

		--drop table #TEMP_TXN
		--SELECT * FROM RemittanceLogData.dbo.unpaidTxn 

		BEGIN TRANSACTION

		UPDATE remitTran SET
			 pAgentComm					= (SELECT ISNULL(amount, 0)
											FROM dbo.FNAGetPayComm(B.sBranch, B.sCountryId, B.sLocation, B.pSuperAgent, B.pCountryId, B.pLocation, B.pBranch, 'NPR', 
																	B.deliveryMethodId, B.cAmt, B.pAmt, B.serviceCharge, NULL, NULL)
											)
			,pAgentCommCurrency			= 'NPR'
			,pBranch					= '1247'
			,pBranchName				= 'IME EXCHANGE COUNTER (A)'
			,pAgent						= '1247'
			,pAgentName					= 'IME EXCHANGE COUNTER (A)'
			,pSuperAgent				= '1002'
			,pSuperAgentName			= 'INTERNATIONAL MONEY EXPRESS (IME) PVT. LTD'
			,pCountry					= 'Nepal'
			,pState						= 'Bagmati'
			,pLocation					= '137'
			,pDistrict					= 'Bagmati'
			,tranStatus					= 'Paid'
			,payStatus					= 'Paid'
			,paidDate					= dbo.FNAGetDateInNepalTZ()
			,paidDateLocal				= GETDATE()
			,paidBy						= 'sheela123'
			,lockStatus					= 'unlocked'
			,voucherNo					= 'SYSTEM'
		FROM remitTran A,
		(
			select TOP 150 
				controlNo = up.encryptedControlNo, 
				sBranch = rt.sBranch,
				sCountryId = sam.agentCountryId,
				sLocation = sam.agentLocation,
				pSuperAgent = 1002,
				pCountryId = 151,
				pLocation = 137,
				pBranch = 1247,
				deliveryMethodId = 1,
				cAmt = rt.cAmt,
				pAmt = rt.pAmt,
				serviceCharge = rt.serviceCharge
			from #TEMP_TXN up with(nolock) 
			inner join remitTran rt with(nolock) on up.encryptedControlNo = rt.controlNO
			left join agentMaster sam with(nolock) on sam.agentId = rt.sBranch
			where rt.tranStatus = 'Payment'
		)B  WHERE A.controlNo =B.controlNo
		
		UPDATE RemittanceLogData.dbo.unpaidTxn SET IS_PAID = 'Y'
		WHERE encryptedControlNo IN (SELECT encryptedControlNo FROM #TEMP_TXN)
		
		declare @txnCount varchar(50),@msg varchar(max)
		select @txnCount = count('x') from #TEMP_TXN
		drop table #TEMP_TXN 
		/*
			select rt.tranStatus,rt.payStatus from remitTran rt with(nolock) inner join #TEMP_TXN t on rt.controlNo = t.encryptedControlNo

		*/
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		set @msg = @txnCount+' Transaction(s) has been paid successfully.'
		EXEC [proc_errorHandler] 0, @msg, @controlNo

	END		
/*

select * from remitTran with(nolock) where pAgent = 1247 and paidDate > '2014-08-18'
and tranType='I' and sBranch is null

update remitTran set sAgent ='20398',sBranch='20398' where pAgent = 1247 and paidDate > '2014-08-17'
and tranType='I'  and sAgentName='City Exchange'

select * from remitTran with(nolock) where pAgent = 1247,sBranch= and paidDate > '2014-08-13'
and tranType='I' and sAgentName='Islamic Exchange'

select agentType,actasbranch,* from agentMaster with(nolock) where agentName like '%City Exchange%'

select * from agentMaster with(nolock) where agentId = 20398

*/

GO
