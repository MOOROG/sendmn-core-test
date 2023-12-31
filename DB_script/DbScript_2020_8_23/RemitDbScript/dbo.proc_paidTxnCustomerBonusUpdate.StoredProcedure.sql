USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_paidTxnCustomerBonusUpdate]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_paidTxnCustomerBonusUpdate]
	 @flag			VARCHAR(50)		= NULL
	,@date			DATETIME		= NULL
AS

DECLARE @FromDate DATETIME, @toDate DATETIME

IF @flag = 'schedule'
BEGIN
	 
	SET @FromDate = CONVERT(VARCHAR, GETDATE() - 1, 101)
	SET @toDate = CONVERT(VARCHAR, GETDATE(), 101)+' 23:59:59'
	
	IF @date IS NOT NULL
	BEGIN
		SET @FromDate = CONVERT(VARCHAR, @date, 101)
		SET @toDate = @FromDate + ' 23:59:59'
	END
	DECLARE @customerBonus TABLE(tranId BIGINT, bonusPoint INT, customerId BIGINT)
	DECLARE @customerBonusGroup TABLE(bonusPoint MONEY, customerId BIGINT,totBonus MONEY, mobileNo VARCHAR(50))
	
	-->>Get Transaction Id and customer bonus earned from paid transactions
	INSERT INTO @customerBonus(tranId, bonusPoint, customerId)
	SELECT
		 rt.id 
		,ISNULL(rt.bonusPoint, 0)
		,sen.customerId
	FROM remitTran rt WITH(NOLOCK)
	INNER JOIN tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId
	INNER JOIN customerMaster cm with(nolock) on sen.membershipId = cm.membershipId
	WHERE rt.paidDate BETWEEN @FromDate AND @toDate 
		AND rt.isBonusUpdated IS NULL 
		AND ISNULL(rt.bonusPoint, 0) <> 0 
		AND rt.tranStatus <> 'Cancel'
	
	-->>Group By customerId to get total bonus earned by customer
	INSERT INTO @customerBonusGroup(bonusPoint, customerId)
	SELECT SUM(bonusPoint), customerId FROM @customerBonus GROUP BY customerId

	-->>Update customer bonus earned and deduct pending bonus
	UPDATE customerMaster SET
		 bonusPoint			= ISNULL(c.bonusPoint, 0) + ISNULL(cbg.bonusPoint, 0)
		,bonusPointPending	= ISNULL(c.bonusPointPending, 0) - ISNULL(cbg.bonusPoint, 0)
	FROM customerMaster c
	INNER JOIN @customerBonusGroup cbg ON c.customerId = cbg.customerId
	
	-->>Mark transaction as bonus Updated
	UPDATE remitTran SET
		 isBonusUpdated	= 'Y'
	FROM remitTran rt 
	INNER JOIN @customerBonus cb ON rt.id = cb.tranId

	/*
	-- ## SMS Module
	UPDATE @customerBonusGroup SET 
		totBonus = ISNULL(B.bonusPoint,0) ,
		mobileNo = mobile
	FROM @customerBonusGroup A,
	(
		SELECT cm.bonusPoint,mobile,cm.customerId FROM customerMaster cm WITH(NOLOCK) 
		INNER JOIN @customerBonusGroup t ON cm.customerId = t.customerId
	)B WHERE A.customerId = B.customerId 
	
	INSERT INTO SMSQUEUE(mobileNo,msg,createdDate,createdBy)
	SELECT mobileNo,'Tapai ko halko bonus point: '+cast(totBonus as varchar(50))+'.IME Garnu bhayeko ma dhanyabad.Samparka ko laagi 01-4430600, IME',GETDATE(),'system' 
	FROM @customerBonusGroup WHERE totBonus > 0 and mobileNo <> '' and mobileNo is not null and mobileNo <> '0000000000'
	*/
	RETURN
END


--select to 10 * from SMSQueue order by rowid desc





GO
