USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dishhomePin]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
EXEC proc_dishhomePin @flag='a', @user = 'testagenta', @deno = '100', @qty = '3', 
@agentId = '4616', @sAgentId = '1002', @intMapCode = '33431560'

	EXEC [192.168.1.7].MEROIME.dbo.[BranchPinprocessDishHome]
        @amount ='100',
        @QTY='5',
        @ip = '10.1.1.254',
        @userName='raghu',
        @ImeMapCode = '33431560'

*/

CREATE proc [dbo].[proc_dishhomePin]
	  @flag                         VARCHAR(50)		= NULL
     ,@user                         VARCHAR(30)		= NULL
     ,@agentId						VARCHAR(50)		= NULL
     ,@intMapCode					VARCHAR(100)	= NULL
     ,@sAgentId						VARCHAR(50)		= NULL
     ,@deno		                    VARCHAR(30)		= NULL
     ,@qty							INT				= NULL
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

	
IF @flag = 'a' 
BEGIN	
	DECLARE @MSG AS VARCHAR(MAX)
	IF OBJECT_ID('tempdb..#tempTable') IS NOT NULL 
	DROP TABLE #tempTable
	CREATE TABLE #tempTable
	(
		ERR_CODE		VARCHAR(20)	 NULL,
		MSG				VARCHAR(MAX) NULL,
		PinNo			VARCHAR(100) NULL,
		Amount			MONEY NULL,
		ExpDate			DATETIME NULL, 
		PinSN			FLOAT NULL,	
		PIN_LOG_ID		INT NULL,
		ROWID			INT	NULL		
	)
	INSERT INTO #tempTable
	/*
	EXEC [192.168.1.7].MEROIME.dbo.[BranchPinprocessDishHome]
        @amount =@deno,
        @QTY=@qty,
        @ip = '10.1.1.254',
        @userName='raghu',
        @ImeMapCode = @intMapCode
    */
	
	SELECT 
			'0' errCode,
			'SUCCESS' msg,
			pin_code ,
			pin_price,
			CONVERT(VARCHAR,expire_date,101) expire_date,
			CAST(pin_sn AS VARCHAR(100)),
			'' LogId,
			rowid			
	FROM pin_charge_history1

	SELECT TOP 1 @MSG=MSG FROM #tempTable  
	
	IF @MSG='SUCCESS'
	BEGIN
		INSERT INTO pin_charge_history(deno,qty,reqDate,reqBy,agentId,sAgentId,pinCode,pinSN,pinExpDate,pinLogId)
		SELECT Amount,@qty,GETDATE(),@user,@agentId,@sAgentId,PinNo,PinSN,ExpDate,PIN_LOG_ID
		FROM #tempTable	
	END
	
	SELECT * FROM #tempTable
	
	DROP TABLE #tempTable
	
	/*
	 EXEC [192.168.1.7].MEROIME.dbo.[BranchPinprocessDishHome]
        @amount =@deno,
        @QTY=@qty,
        @ip = '10.1.1.254',
        @userName='raghu',
        @ImeMapCode = @intMapCode
	
	*/
	--SELECT  pin_code, pin_sn, expire_date,@rowid LogId, rowid 
	--FROM pin_charge_history 
	--WHERE log_id = @rowid	

END	


GO
