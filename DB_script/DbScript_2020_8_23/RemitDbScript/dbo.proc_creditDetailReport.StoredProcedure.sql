USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_creditDetailReport]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC proc_creditDetailReport 
	 @flag = 'b'
	,@user = 'admin'
	,@fromDate = '2010-01-01'
	,@toDate = '2014-12-31'	
	
*/

CREATE procEDURE [dbo].[proc_creditDetailReport]
	 @flag					VARCHAR(20)
	,@user					VARCHAR(30)	
	,@issuedDateFrom		DATETIME	= NULL
	,@issuedDateTo			DATETIME	= NULL
	,@validDateFrom			DATETIME	= NULL
	,@validDateTo			DATETIME	= NULL
	,@followUpDateFrom		DATETIME	= NULL
	,@followUpDateTo		DATETIME	= NULL
	,@sAgent				INT			= NULL
	,@country				INT			= NULL
	,@agentId				INT			= NULL
AS

DECLARE 
			 @sql VARCHAR(MAX)
			,@table VARCHAR(MAX)
			,@selectList VARCHAR(MAX)
			
--Filters 2	
IF @flag = 'b'			-- Bank Guarantee
BEGIN
		SET @sql = ''
		IF @agentId IS NOT NULL
			SET @sql = @sql + ' AND main.agentId = ' + CAST(@agentId AS VARCHAR) + ''
			 
		IF @issuedDateFrom IS NOT NULL
			SET @sql = @sql + ' AND main.issuedDate >= ''' + @issuedDateFrom  + ''''
		
		IF @issuedDateTo IS NOT NULL
			SET @sql = @sql + ' AND main.issuedDate <= ''' + @issuedDateTo + ' 23:59:59'''
	
		IF @validDateFrom IS NOT NULL
			SET @sql = @sql + ' AND main.validDate >= ''' + @validDateFrom + ''''
			
		IF @validDateTo IS NOT NULL
			SET @sql = @sql + ' AND main.validDate <= ''' + @validDateTo + ' 23:59:59'''

		IF @followUpDateFrom IS NOT NULL
			SET @sql = @sql + ' AND main.followUpDate >= ''' + @followUpDateFrom + ''''

		IF @followUpDateTo IS NOT NULL
			SET @sql = @sql + ' AND main.followUpDate <= ''' + @followUpDateTo + ' 23:59:59'''
		
		SET @table = '
			SELECT
				 [Agent Name]		= am.agentName
				,[Guarantee No]		= main.guaranteeNo
				,[Amount]			= main.amount
				,[Currency]			= curr.currencyCode
				,[Bank Name]		= main.bankName
				,[Issued Date]		= main.issuedDate
				,[Expiry Date]		= main.expiryDate
				,[FollowUp Date]	= main.followUpDate
			FROM bankGuarantee main
			LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
			LEFT JOIN currencyMaster curr WITH(NOLOCK) ON main.currency = curr.currencyId
			WHERE 1 = 1 		
		'
		
		SET @sql = 'SELECT * FROM ('
					 	+ @table
						+ @sql
						+
					' ) x '
		
		PRINT @table	
		EXEC (@sql)
END
ELSE IF @flag = 'm'
BEGIN
		SET @sql = ''
		IF @agentId IS NOT NULL
			SET @sql = @sql + ' AND main.agentId = ' + CAST(@agentId AS VARCHAR) + ''
		
		IF @issuedDateFrom IS NOT NULL
			SET @sql = @sql + ' AND main.valuationDate >= ''' + @issuedDateFrom  + ''''
		
		IF @issuedDateTo IS NOT NULL
			SET @sql = @sql + ' AND main.valuationDate <= ''' + @issuedDateTo + ' 23:59:59'''
		
		SET @table = '
			SELECT
				 [Agent Name]			= am.agentName
				,[Registration Office]	= main.regOffice
				,[Registration No]		= main.mortgageRegNo
				,[ValuationAmount]		= main.valuationAmount
				,[Currency]				= curr.currencyCode
				,[Valuator]				= main.valuator
				,[Mortgage Date]		= main.valuationDate
				,[Property Type]		= pt.detailTitle
				,[Plot No]				= main.plotNo
				,[Ownner]				= main.owner
			FROM mortgage main
			LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
			LEFT JOIN currencyMaster curr WITH(NOLOCK) ON main.currency = curr.currencyId
			LEFT JOIN staticDataValue pt WITH(NOLOCK) ON main.propertyType = pt.valueId
			WHERE 1 = 1 		
		'
		
		SET @sql = 'SELECT * FROM ('
					 	+ @table
						+ @sql
						+
					' ) x '
		
		PRINT @table	
		EXEC (@sql)
END
ELSE IF @flag = 'c'
BEGIN
		SET @sql = ''
		IF @agentId IS NOT NULL
			SET @sql = @sql + ' AND main.agentId = ' + CAST(@agentId AS VARCHAR) + ''
		
		IF @issuedDateFrom IS NOT NULL
			SET @sql = @sql + ' AND main.depositedDate >= ''' + @issuedDateFrom  + ''''
		
		IF @issuedDateTo IS NOT NULL
			SET @sql = @sql + ' AND main.depositedDate <= ''' + @issuedDateTo + ' 23:59:59'''
		
		SET @table = '
			SELECT
				 [Agent Name]			= am.agentName
				,[Deposit Account No]	= main.depositAcNo
				,[Cash Deposit]			= main.cashDeposit
				,[Currency]				= curr.currencyCode
				,[Deposited Date]		= main.depositedDate
			FROM cashSecurity main
			LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
			LEFT JOIN currencyMaster curr WITH(NOLOCK) ON main.currency = curr.currencyId
			WHERE 1 = 1 		
		'
		
		SET @sql = 'SELECT * FROM ('
					 	+ @table
						+ @sql
						+
					' ) x '
		
		PRINT @table	
		EXEC (@sql)
END
ELSE IF @flag = 'f'
BEGIN
		SET @sql = ''
		IF @agentId IS NOT NULL
			SET @sql = @sql + ' AND main.agentId = ' + CAST(@agentId AS VARCHAR) + ''
			 
		IF @issuedDateFrom IS NOT NULL
			SET @sql = @sql + ' AND main.issuedDate >= ''' + @issuedDateFrom  + ''''
		
		IF @issuedDateTo IS NOT NULL
			SET @sql = @sql + ' AND main.issuedDate <= ''' + @issuedDateTo + ' 23:59:59'''
	
		IF @validDateFrom IS NOT NULL
			SET @sql = @sql + ' AND main.validDate >= ''' + @validDateFrom + ''''
			
		IF @validDateTo IS NOT NULL
			SET @sql = @sql + ' AND main.validDate <= ''' + @validDateTo + ' 23:59:59'''

		IF @followUpDateFrom IS NOT NULL
			SET @sql = @sql + ' AND main.followUpDate >= ''' + @followUpDateFrom + ''''

		IF @followUpDateTo IS NOT NULL
			SET @sql = @sql + ' AND main.followUpDate <= ''' + @followUpDateTo + ' 23:59:59'''
		
		SET @table = '
			SELECT
				 [Agent Name]		= am.agentName
				,[Fixed Deposit No]	= main.fixedDepositNo
				,[Amount]			= main.amount
				,[Currency]			= curr.currencyCode
				,[Bank Name]		= main.bankName
				,[Issued Date]		= main.issuedDate
				,[Expiry Date]		= main.expiryDate
				,[FollowUp Date]	= main.followUpDate
			FROM fixedDeposit main
			LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
			LEFT JOIN currencyMaster curr WITH(NOLOCK) ON main.currency = curr.currencyId
			WHERE 1 = 1 		
		'
		
		SET @sql = 'SELECT * FROM ('
					 	+ @table
						+ @sql
						+
					' ) x '
		
		PRINT @table	
		EXEC (@sql)
END
ELSE IF @flag = 'l'
BEGIN
		SET @sql = ''
		IF @agentId IS NOT NULL
			SET @sql = @sql + ' AND main.agentId = ' + CAST(@agentId AS VARCHAR) + ''
		
		IF @validDateFrom IS NOT NULL
			SET @sql = @sql + ' AND main.expiryDate >= ''' + @validDateFrom  + ''''
		
		IF @validDateTo IS NOT NULL
			SET @sql = @sql + ' AND main.expiryDate <= ''' + @validDateTo + ' 23:59:59'''
		
		SET @table = '
			SELECT
				 [Agent Name]			= am.agentName
				,[Limit Amount]			= main.limitAmt
				,[Per Top Up Amount]	= main.perTopUpAmt
				,[Max Limit Amount]		= main.maxLimitAmt
				,[Currency]				= curr.currencyCode
				,[Expiry Date]			= main.expiryDate
			FROM creditLimit main
			LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
			LEFT JOIN currencyMaster curr WITH(NOLOCK) ON main.currency = curr.currencyId
			WHERE 1 = 1 		
		'
		
		SET @sql = 'SELECT * FROM ('
					 	+ @table
						+ @sql
						+
					' ) x '
		
		PRINT @table	
		EXEC (@sql)
END
		
EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

SELECT '' head, '' value from (select 0 id ) x where id <> 0

SELECT 'Credit Detail Report' title


GO
