use FastMoneyPro_Account
GO

ALTER PROC PROC_JOB_DONGA_CALC_FX
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @DATE DATE, @END_DATE DATE, @SESSION_ID VARCHAR(50), @COMM_AMT MONEY, @V_DATE DATE, @COUNT_TXN INT, @NARRATION VARCHAR(150)

	SELECT @DATE = CAST(MAX(DATEADD(DAY, 1, TRAN_DATE)) AS DATE)
	FROM TRAN_MASTER (NOLOCK) 
	WHERE field2 = 'TRADING GAINLOSS FCY'
	
	WHILE @DATE <= CAST(GETDATE() AS DATE)
	BEGIN
		EXEC Proc_FCY_ForeignGainloss @Date = @DATE,@PartnerAccount = '111004015'
		SET @DATE = DATEADD(DAY, 1, @DATE)
	END
	
	--MONTHLY WISE INCENTIVE CALCULATION FOR AMRITA PREVIOUS MONTH
	SELECT @DATE = DATEADD(MM, -1, DATEADD(MM, DATEDIFF(MM, 0, GETDATE()), 0)), @END_DATE = DATEADD(MM, -1, DATEADD(DD, -1, DATEADD(MM, DATEDIFF(MM, 0, GETDATE()) + 1, 0))), @SESSION_ID = NEWID()
	--SELECT @DATE = '2019-11-01', @END_DATE = '2019-11-30', @SESSION_ID = NEWID()

	IF NOT EXISTS(SELECT 1 FROM TRAN_MASTER(NOLOCK) WHERE TRAN_DATE BETWEEN @DATE AND CAST(@END_DATE AS VARCHAR) + ' 23:59:59' AND FIELD2 = 'Monthly Incentive' AND ACC_NUM = '500439205691')
	BEGIN
		SELECT @COUNT_TXN = COUNT(0)
		FROM FASTMONEYPRO_REMIT.DBO.REMITTRAN (NOLOCK)
		WHERE CREATEDDATE BETWEEN @DATE AND CAST(@END_DATE AS VARCHAR) + ' 23:59:59'
		AND SAGENT = 394394
		AND TRANSTATUS <> 'CANCEL'

		--incentive txn wise (150-200 10K) and (>200 20K)
		IF @COUNT_TXN BETWEEN 150 AND 200
			SET @COMM_AMT = 10000
		ELSE IF @COUNT_TXN > 200
			SET @COMM_AMT = 20000
		ELSE 
			SET @COMM_AMT = 0

		--20K is the monthly incentive
		SET @COMM_AMT += 20000

		INSERT INTO temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,usd_amt,usd_rate,tran_amt,tran_date
			,rpt_code,trn_currency,emp_name,field1,field2)	
		SELECT @SESSION_ID,'system','500439205691','j','cr',@COMM_AMT,1,@COMM_AMT,@END_DATE,'USDVOUCHER','JPY','','','Monthly Incentive' UNION ALL
		SELECT @SESSION_ID,'system','910139266612','j','dr',@COMM_AMT,1,@COMM_AMT,@END_DATE,'USDVOUCHER','JPY','','','Monthly Incentive' 

		SET @NARRATION = 'Monthly Incentive : '+FORMAT(@END_DATE, 'MMMM')
		EXEC [spa_saveTempTrnUSD] @flag='i',@sessionID= @SESSION_ID,@date = @END_DATE,@narration = @NARRATION,@company_id=1,@v_type='j',@user='system'
	END
END

--SELECT MAX(TRAN_DATE) FROM TRAN_MASTER (NOLOCK) WHERE field2 = 'TRADING GAINLOSS FCY'
--SELECT MAX(TRAN_DATE) FROM TRAN_MASTER (NOLOCK) WHERE field2 = 'Monthly Incentive'

select * from tran_master where ref_num = '255271'

select * from tran_master_deleted where ref_num = '146' and cast(created_date as date) = '2020-03-12'



select * from tran_masterdetail where ref_num = '265607'
select * from fastmoneypro_remit.dbo.customer_deposit_logs where tranid=2023

select * from tran_master where field1 = '33JP212784181'
select * from tran_master where field1 = '2023'

