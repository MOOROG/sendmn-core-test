USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_updateCancelTopUpLimit]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

*/	
        
CREATE proc [dbo].[proc_updateCancelTopUpLimit] 
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
			 todaysCancelled = ISNULL(todaysCancelled, 0) + ISNULL(@amount, 0)
		WHERE agentId = @agentId
	END
	ELSE
	BEGIN
		UPDATE creditLimit SET
			 todaysCancelled = ISNULL(todaysCancelled, 0) + ISNULL(@amount, 0)
			,topUpTillYesterday = CASE WHEN @topUpTillYesterday - ISNULL(@amount, 0) <= 0 THEN 0 ELSE @topUpTillYesterday - ISNULL(@amount, 0) END 
		WHERE agentId = @agentId 
	END
END

--select * from ac_master





GO
