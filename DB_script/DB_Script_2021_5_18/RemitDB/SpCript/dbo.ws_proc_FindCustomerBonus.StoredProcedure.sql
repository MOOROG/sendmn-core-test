USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_FindCustomerBonus]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[ws_proc_FindCustomerBonus]
(
     @AGENT_CODE				VARCHAR(50)
	,@USER_ID					VARCHAR(50)
	,@PASSWORD					VARCHAR(50)
	,@MEMBERSHIP_ID				VARCHAR(50)
	,@FROM_DATE					VARCHAR(50)			=	NULL
    ,@TO_DATE					VARCHAR(50)			=	NULL
)
AS
BEGIN
	DECLARE @SQL VARCHAR(MAX)
	
	
	/*authenticating user*/
	DECLARE @errCode INT
	DECLARE @autMsg	VARCHAR(500)
	
	IF @USER_ID IS NULL
	BEGIN
		SELECT '1001' CODE, 'USER_ID Field is Empty' MESSAGE, NULL id
		RETURN
	END
	IF @AGENT_CODE IS NULL
	BEGIN
		SELECT '1001' CODE, 'AGENT_CODE Field is Empty' MESSAGE, NULL id
		RETURN
	END
	
	IF @PASSWORD IS NULL
	BEGIN
		SELECT '1001' CODE, 'PASSWORD Field is Empty' MESSAGE, NULL id
		RETURN
	END
	
	IF @USER_ID <> 'n3p@lU$er' OR @AGENT_CODE <> '1001' OR @PASSWORD <> '36928c11f93d6b0cbf573d0e1ac350f7'
	BEGIN
		SELECT '1002' CODE,'Authentication Failed' MESSAGE, NULL id
		RETURN
	END


	--EXEC ws_proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT, @autMsg OUT
	
	--IF(@errCode = 1)
	--BEGIN
	--	SELECT '1002' errorCode, ISNULL(@autMsg,'Authentication Fail') msg
	--	RETURN
	--END
	/*authenticating user*/
	
	
	
	IF NOT EXISTS(SELECT 'X' FROM dbo.customerMaster cm WITH(NOLOCK) 
		WHERE cm.membershipId = @MEMBERSHIP_ID 
		AND ISNULL(isDeleted,'N') = 'N' 
		AND ISNULL(isActive,'Y')='Y')
	BEGIN
		EXEC proc_errorHandler 1, 'Invalid IME Customer Card Number', @MEMBERSHIP_ID
		RETURN
	END
	
	IF NOT EXISTS(SELECT 'X' FROM dbo.customerMaster cm WITH(NOLOCK) 
		WHERE cm.membershipId = @MEMBERSHIP_ID 
		AND cm.approvedDate IS NOT NULL)
	BEGIN
		EXEC proc_errorHandler 1, 'Your IME Customer Card Number is under process of activation.', @MEMBERSHIP_ID
		RETURN
	END
	
	SELECT 
		errorCode = '0',
		msg = 'Success',
		customerName = firstName + ISNULL( ' ' + middleName, '') + ISNULL( ' ' + lastName, ''),
		approvedDate,
		bonusPoint = CAST(ISNULL(bonusPoint,0) AS DECIMAL(15, 0))
	FROM customerMaster WITH(NOLOCK)
	WHERE membershipId = @MEMBERSHIP_ID
	
	SET @SQL = 'SELECT TOP 5
					controlNo = dbo.fnadecryptString(rt.controlNo),
					receiverName = rt.receiverName,
					payoutAmt = CAST(rt.pAmt AS DECIMAL(15,2)),
					txnDate = rt.approvedDateLocal,
					status = rt.payStatus,
					idBonusPoint = case when rt.payStatus = ''Paid'' then isnull(rt.bonusPoint,0) else ''0'' end
				FROM remitTran rt WITH(NOLOCK) 
				INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
				WHERE sen.membershipId = '''+@MEMBERSHIP_ID+''''

	IF @FROM_DATE IS NOT NULL AND @TO_DATE IS NOT NULL
		SET @SQL = @SQL+' AND rt.approvedDateLocal BETWEEN '''+@FROM_DATE+''' AND '''+@TO_DATE+' 23:59:59''' 

	SET @SQL = @SQL+' ORDER BY rt.approvedDateLocal DESC' 

	PRINT(@SQL)
	EXEC(@SQL) 

END

/*
SELECT * FROM CUSTOMERMASTER WHERE APPROVEDDATE IS NOT NULL
EXEC [ws_proc_FindCustomerBonus] @AGENT_CODE = 'IMENPJA001',@USER_ID = 'aalesh123',@PASSWORD='jaljale11',
	@MEMBERSHIP_ID = '3333333333333333',@FROM_DATE ='2014-11-11',@TO_DATE='2014-11-30'

EXEC [ws_proc_FindCustomerBonus] @AGENT_CODE = '',@USER_ID = '',@PASSWORD='',
	@MEMBERSHIP_ID = '3333333333333333'

*/

GO
