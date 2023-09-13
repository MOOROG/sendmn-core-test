SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,ANOJ KATTEL>
-- Create date: <Create Date,2019/04/03>
-- Description:	<Description,This sp is used for Check available balance of user>
-- =============================================
ALTER PROCEDURE proc_checkUserAvailableBalance 
	-- Add the parameters for the stored procedure here
	@username		VARCHAR(200)	=	NULL,
	@customerId		VARCHAR(200)	=	NULL,
	@paymentMethod	VARCHAR(200)	=	NULL,
	@branchId		VARCHAR(100)	=	NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF @paymentMethod ='Cash Collect'
	BEGIN
	IF @branchId IS NOT NULL
	BEGIN
	    SELECT avilableBalance = availableLimit, holdType = CASE WHEN ruleType = 'H' THEN 'Hold' Else 'Block' END FROM DBO.FNAGetUserCashLimitDetails(NULL,@branchId)
		RETURN;
	END
	ELSE
	BEGIN
		SELECT avilableBalance = availableLimit, holdType = CASE WHEN ruleType = 'H' THEN 'Hold' Else 'Block' END FROM DBO.FNAGetUserCashLimitDetails(@username,NULL)
		RETURN;
	END
	END
	ELSE IF @paymentMethod='Bank Deposit'
	BEGIN
	   SELECT DBO.FNAGetCustomerAvailableBalance(@customerId) avilableBalance;
	   RETURN;
	END
END
GO

