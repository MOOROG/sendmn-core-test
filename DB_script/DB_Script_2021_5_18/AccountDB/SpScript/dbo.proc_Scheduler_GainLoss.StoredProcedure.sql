USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_Scheduler_GainLoss]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_Scheduler_GainLoss]
AS
SET NOCOUNT ON;

DECLARE @tillDate DATE 

SET @tillDate = DATEADD(D,-1,GETDATE())

IF @tillDate >= CAST(GETDATE() AS DATE)
BEGIN
	SELECT 'FUTURE DATE IS NOT ALLOWED' MSG
	RETURN
END

--DECLARE @SD DATE ='2018-07-27',@ED DATE = '2018-08-01'

--WHILE @ED >=@SD
--BEGIN
--
--select * from ac_master(nolock) where acct_num IN('771348523','100570487576','771315393','771407271')
	PRINT @tillDate
	DECLARE @loopdata TABLE (AccountNo VARCHAR(20))
	----
	INSERT INTO @LOOPDATA
	SELECT ACCT_NUM FROM AC_MASTER(NOLOCK) 
	WHERE ACCT_NUM IN('771000937','100284039207','771000915','771345592','771155502','771155503','771000938','771315375','771230099','771407269','771459676','771532167') AND ac_currency='USD'

	DECLARE @PartnerAccount VARCHAR(20)

	WHILE EXISTS(SELECT 'A' FROM @LOOPDATA)
	BEGIN
		SELECT TOP 1 @PartnerAccount = AccountNo FROM @LOOPDATA 
		--PRINT @PartnerAccount exec Proc_Partner_ForeignGainloss @Date = '2018-11-06',@PartnerAccount = '771532167'
		exec Proc_Partner_ForeignGainloss @Date = @tillDate,@PartnerAccount = @PartnerAccount

		DELETE FROM @LOOPDATA WHERE AccountNo = @PartnerAccount
		WAITFOR DELAY '000:00:01'
		PRINT 'WAITING FOR 1 SEC'
	END
	
	DELETE FROM @LOOPDATA

	----for bni 
	EXEC Proc_ForeignGainloss_KRWVSOTHER @Date = @tillDate,@PartnerAccount = '771474249'

	INSERT INTO @LOOPDATA
	SELECT ACCT_NUM FROM AC_MASTER(NOLOCK) WHERE ACCT_NUM IN('771348523','100570487576','771315393','771407271','771532178')

	WHILE EXISTS(SELECT 'A' FROM @LOOPDATA)
	BEGIN
		SELECT TOP 1 @PartnerAccount = AccountNo FROM @LOOPDATA 
		--PRINT @PartnerAccount exec Proc_FCY_ForeignGainloss @Date = '2018-11-06',@PartnerAccount = '771532178'
		exec Proc_FCY_ForeignGainloss @Date = @tillDate,@PartnerAccount = @PartnerAccount

		DELETE FROM @LOOPDATA WHERE AccountNo = @PartnerAccount
		WAITFOR DELAY '000:00:01'
		PRINT 'WAITING FOR 1 SEC'
	END
	--SET @SD = DATEADD(DAY,1,@SD)
	
--END

GO
