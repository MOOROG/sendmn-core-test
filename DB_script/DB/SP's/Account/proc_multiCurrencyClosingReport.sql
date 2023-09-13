

ALTER proc proc_multiCurrencyClosingReport(
	@flag		varchar(30),
	@asOnDate	varchar(10) = NULL,
	@partner	VARCHAR(20) = NULL,
	@user		VARCHAR(30) 
)AS
BEGIN
	IF @flag='rpt'
	BEGIN
		
		IF OBJECT_ID('tempdb..#temp') IS NOT NULL        
			DROP TABLE #temp			
		DECLARE @sql VARCHAR(MAX)=''

		declare @accNumber table(Accountno varchar(20))

		insert into @accNumber
		select '771000937' union all 
		select '100284039207'union all 
		select '771000915'union all 
		select '771345592' union all 
		select '771155502' union all 
		select '771155503'union all 
		select '771000938'union all 
		select '771315375'union all 
		select '771230099'union all 
		select '771407269'union all 
		select '771348523'union all 
		select '100570487576'union all 
		select '771315393' union all
		select '771407271'

		if @partner is not null
			delete from @accNumber where Accountno <> @partner

		SELECT * INTO #temp FROM (
			SELECT 
				dbo.fungetacName(acc_num) AS ACCOUNT_NAME
				,(CASE WHEN part_tran_type='CR' THEN TRAN_AMT*-1 ELSE TRAN_AMT END) AS [JPY]
				,(CASE WHEN part_tran_type='CR' THEN USD_AMT*-1 ELSE USD_AMT END) AS [FCY]
				,0.00 [Rates]
				,VOUCHER_TYPE = field2
			FROM tran_master(NOLOCK) where 1=1 
			AND field2 in ('FOREIGN GAIN','TRADING GAINLOSS','REVALUATION GAINLOSS','FOREIGN GAIN FCY','TRADING GAINLOSS FCY','REVALUATION GAINLOSS FCY')
			AND tran_date = @asOnDate
			AND acc_num IN(select * from @accNumber)
			UNION ALL
			SELECT 
				dbo.fungetacName(acc_num) AS ACCOUNT_NAME
				,SUM(CASE WHEN part_tran_type='CR' THEN TRAN_AMT*-1 ELSE TRAN_AMT END) AS [JPY]
				,SUM(CASE WHEN part_tran_type='CR' THEN USD_AMT*-1 ELSE USD_AMT END) AS [FCY]
				,0.00 [Rates]
				,VOUCHER_TYPE='REMITTANCE VOUCHER'
			FROM tran_master(NOLOCK) where 1=1 
			AND tran_date <= @asOnDate
			AND acc_num IN(select * from @accNumber)
		GROUP BY acc_num
		)X
	
	--SELECT * FROM #temp
	SELECT *,[Rates] = [JPY]/CASE WHEN [FCY]=0 THEN 1 ELSE [FCY] END FROM (
		SELECT
				ACCOUNT_NAME 
			,SUM(CASE WHEN VOUCHER_TYPE='REMITTANCE VOUCHER' THEN [JPY] ELSE 0 END) AS [JPY]
			,SUM(CASE WHEN VOUCHER_TYPE='REMITTANCE VOUCHER' THEN [FCY] ELSE 0 END) AS [FCY]
			,SUM(CASE WHEN VOUCHER_TYPE in ('FOREIGN GAIN','FOREIGN GAIN FCY') THEN [JPY] ELSE 0 END)  AS [FOREIGN GAIN]
			,SUM(CASE WHEN VOUCHER_TYPE in ('TRADING GAINLOSS','TRADING GAINLOSS FCY') THEN [JPY] ELSE 0 END) AS [TRADING GAINLOSS]
			,SUM(CASE WHEN VOUCHER_TYPE in ('REVALUATION GAINLOSS','REVALUATION GAINLOSS FCY') THEN [JPY] ELSE 0 END) AS [REVALUATION GAINLOSS]
		FROM #temp AS T GROUP BY T.ACCOUNT_NAME
	)X

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT  'As on Date' head, @asOnDate value UNION ALL
		SELECT	'Account' head,acct_name FROM AC_MASTER(NOLOCK) WHERE ACCT_NUM = @partner
		
		SELECT 'Register Report' title

	END

	IF @flag='ddlAccountNo'
	BEGIN
		SELECT 
			ACCT_NUM AS id,acct_name AS text 
		FROM AC_MASTER(NOLOCK) 
		WHERE ACCT_NUM IN('771000937','100284039207','771000915','771345592','771155502','771155503','771000938','771315375','771230099','771407269','771348523','100570487576','771315393')
	END
END


