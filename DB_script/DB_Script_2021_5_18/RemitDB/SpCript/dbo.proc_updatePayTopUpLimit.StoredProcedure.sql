USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_updatePayTopUpLimit]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

*/	
        
CREATE proc [dbo].[proc_updatePayTopUpLimit] 
	 @agentId INT
	,@amount MONEY

AS 
SET NOCOUNT ON 
BEGIN
	DECLARE
		 @glCode				INT 
		,@topUpTillYesterday	MONEY
	
	SET @glCode = 1	
	SELECT 
		 @topUpTillYesterday = ISNULL(topUpTillYesterday, 0)
	FROM creditLimit WHERE agentId = @agentId
	
	IF (@topUpTillYesterday = 0)
	BEGIN
		UPDATE creditLimit SET
			 todaysPaid = ISNULL(todaysPaid, 0) + ISNULL(@amount, 0)
		WHERE agentId = @agentId
	END
	ELSE
	BEGIN
		UPDATE creditLimit SET
			 todaysPaid = ISNULL(todaysPaid, 0) + ISNULL(@amount, 0)
			,topUpTillYesterday = CASE WHEN @topUpTillYesterday - ISNULL(@amount, 0) <= 0 THEN 0 ELSE @topUpTillYesterday - ISNULL(@amount, 0) END 
		WHERE agentId = @agentId
	END
END

--select * from ac_master




GO
