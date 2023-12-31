USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentSecurityReport_122215]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_agentSecurityReport_122215]
(
	@flag			VARCHAR(10),
	@user			VARCHAR(5),
	@zoneName		VARCHAR(50) =NULL,
	@districtName	VARCHAR(50) =NULL,
	@locationId		VARCHAR(10) =NULL,
	@agentId		VARCHAR(10)  =NULL,
	@securityType	VARCHAR(50) =NULL,
	@isExpiry		VARCHAR(50) =NULL,
	@groupBy		VARCHAR(50)	=NULL
)
AS
SET NOCOUNT ON
BEGIN
	DECLARE @sql VARCHAR(max),@sqlGroupBy VARCHAR(MAX)
	IF @flag = 'rpt' --Security Type = All, Group By = Agent wise
	BEGIN		
		IF @groupBy = 'aw' AND @securityType IS NULL 
		BEGIN
			SET @sql = '			
			SELECT 		
				[S.N.] = row_number()over(order by am.agentState,am.agentDistrict,al.districtName,am.agentName),
				[Zone] = am.agentState,
				[District] = am.agentDistrict,		
				[Agent Name] = am.agentName,				
				[Location] = al.districtName,
				[Bank Guarantee]  = SUM(bg.amount),
				[Fixed Deposit] = SUM(fd.amount),
				[Cash Security] = SUM(cs.cashDeposit),
				[Mortgage] = SUM(m.valuationAmount)				
			FROM dbo.agentMaster am WITH(NOLOCK) 
			LEFT JOIN dbo.api_districtList al WITH(NOLOCK) ON am.agentLocation = al.districtCode
			LEFT JOIN dbo.bankGuarantee bg WITH(NOLOCK) ON am.agentid = bg.agentId
			LEFT JOIN dbo.mortgage m WITH(NOLOCK) ON am.agentid = m.agentId
			LEFT JOIN dbo.fixedDeposit fd WITH(NOLOCK) ON am.agentId = fd.agentId
			LEFT JOIN dbo.cashSecurity cs WITH(NOLOCK) ON am.agentid = cs.agentId
			WHERE 
			am.isSettlingAgent = ''Y'' 
			AND (agentType = 2903 or agentType =2904) 
			and am.parentId <> 5576
			and am.agentCountry =''Nepal''
			AND ISNULL(am.agentBlock,''U'') = ''U''
			AND ISNULL(am.isDeleted,''N'') <> ''Y''
			AND (bg.bgId IS NOT NULL 
				OR m.mortgageId IS NOT NULL 
				OR cs.csId IS NOT NULL 
				OR fd.fdId IS NOT NULL)
			'
			SET @sqlGroupBy	 = ' GROUP BY am.agentId,am.agentName,am.agentState,am.agentDistrict,al.districtName 
								ORDER BY am.agentState,am.agentDistrict,al.districtName,am.agentName'
		END	
		IF @groupBy = 'aw' AND @securityType = 'bg'
		BEGIN
			SET @sql = '
			SELECT 
				[S.N.] = row_number()over(order by am.agentState,am.agentDistrict,al.districtName,am.agentName),
				[Zone] = am.agentState,
				[District] = am.agentDistrict,
				[Agent Name] = am.agentName,				
				[Location] = al.districtName,
				[Guarantee No.] = bg.guaranteeNo,
				[Amount]  = bg.amount,
				[Bank Name] = bg.bankName,
				[Issue Date] = convert(varchar,bg.issuedDate,101),
				[Expiry Date] = convert(varchar,bg.expiryDate,101),
				[Follow Up Date] = convert(varchar,bg.followUpDate,101),
				[Created By] = bg.createdBy,
				[Created Date] = bg.createdDate,
				[Agent Grp] = [dbo].FNAGetDataValue(am.agentGrp)
			FROM dbo.agentMaster am WITH(NOLOCK) 
			LEFT JOIN dbo.api_districtList al WITH(NOLOCK) ON am.agentLocation = al.districtCode
			INNER JOIN dbo.bankGuarantee bg WITH(NOLOCK) ON am.agentid = bg.agentId
			WHERE am.isSettlingAgent = ''Y'' 
			AND (agentType = 2903 or agentType =2904) 
			and am.agentCountry =''Nepal''
			and am.parentId <> 5576'
			SET @sqlGroupBy	 = ''
		END		
		IF @groupBy = 'aw' AND @securityType = 'cs'
		BEGIN
			SET @sql = '
			SELECT 
				[S.N.] = row_number()over(order by am.agentState,am.agentDistrict,al.districtName,am.agentName),
				[Zone] = am.agentState,
				[District] = am.agentDistrict,
				[Agent Name] = am.agentName,				
				[Location] = al.districtName,
				[Deposit A/C No.] = cs.depositAcNo,
				[Amount]  = cs.cashDeposit,
				[Deposit Date] = convert(varchar,cs.depositedDate,101),
				[Bank Name] = cs.bankName,
				[Created By] = cs.createdBy,
				[Created Date] = cs.createdDate,
				[Agent Grp] = [dbo].FNAGetDataValue(am.agentGrp)
			FROM dbo.agentMaster am WITH(NOLOCK) 
			LEFT JOIN dbo.api_districtList al WITH(NOLOCK) ON am.agentLocation = al.districtCode
			INNER JOIN dbo.cashSecurity cs WITH(NOLOCK) ON am.agentid = cs.agentId
			WHERE am.isSettlingAgent = ''Y'' 
			AND (agentType = 2903 or agentType =2904)
			and am.agentCountry =''Nepal''
			and am.parentId <> 5576 '
			SET @sqlGroupBy	 = ''
		END	
		IF @groupBy = 'aw' AND @securityType = 'fd'
		BEGIN
			SET @sql = '
			SELECT 
				[S.N.] = row_number()over(order by am.agentState,am.agentDistrict,al.districtName,am.agentName),
				[Zone] = am.agentState,
				[District] = am.agentDistrict,
				[Agent Name] = am.agentName,				
				[Location] = al.districtName,
				[Bank Name] = fd.bankName,
				[Fixed Deposit No.] = fd.fixedDepositNo,
				[Amount]  = fd.amount,
				[Issued Date] = convert(varchar,fd.issuedDate,101),
				[Expiry Date] = convert(varchar,fd.expiryDate,101),
				[Follow Up Date] = convert(varchar,fd.followUpDate,101),
				[Created By] = fd.createdBy,
				[Created Date] = fd.createdDate,
				[Agent Grp] = [dbo].FNAGetDataValue(am.agentGrp)
			FROM dbo.agentMaster am WITH(NOLOCK) 
			LEFT JOIN dbo.api_districtList al WITH(NOLOCK) ON am.agentLocation = al.districtCode
			INNER JOIN dbo.fixedDeposit fd WITH(NOLOCK) ON am.agentid = fd.agentId
			WHERE and am.isSettlingAgent = ''Y'' 
			AND (agentType = 2903 or agentType =2904)
			and am.agentCountry =''Nepal''
			and am.parentId <> 5576 '
			
			SET @sqlGroupBy	 = ''
		END			
		IF @groupBy = 'aw' AND @securityType = 'mo'
		BEGIN
			SET @sql = '
			SELECT 
				[S.N.] = row_number()over(order by am.agentState,am.agentDistrict,al.districtName,am.agentName),
				[Zone] = am.agentState,
				[District] = am.agentDistrict,
				[Agent Name] = am.agentName,				
				[Location] = al.districtName,
				[Reg. Office] = mo.regOffice,
				[Amount]  = mo.valuationAmount,
				[Mortgage Reg. No.] = mo.mortgageRegNo,				
				[Valuator] = mo.valuator,
				[Valuation Date] = convert(varchar,mo.valuationDate,101),
				[Property Type] = mo.propertyType,
				[Plot No.] = mo.plotNo,
				[Owner] = mo.owner,
				[Country] = mo.country,
				[Zone] = mo.state,
				[City] = mo.city,
				[Zip] = mo.zip,
				[Address] = mo.address,
 				[Created By] = mo.createdBy,
				[Created Date] = mo.createdDate,
				[Agent Grp] = [dbo].FNAGetDataValue(am.agentGrp)
			FROM dbo.agentMaster am WITH(NOLOCK) 
			LEFT JOIN dbo.api_districtList al WITH(NOLOCK) ON am.agentLocation = al.districtCode
			INNER JOIN dbo.mortgage mo WITH(NOLOCK) ON am.agentid = mo.agentId
			WHERE am.isSettlingAgent = ''Y'' 
			AND (agentType = 2903 or agentType =2904)
			and am.agentCountry =''Nepal''
			and am.parentId <> 5576'
			SET @sqlGroupBy	 = ''
		END	
		IF @groupBy = 'aw' AND @securityType = 'na'
		BEGIN
			SET @sql = '
			SELECT 	
				[S.N.] = row_number()over(order by am.agentState,am.agentDistrict,al.districtName,am.agentName),
				[Zone] = am.agentState,
				[District] = am.agentDistrict,					
				[Agent Name] = am.agentName,				
				[Location] = al.districtName			
			FROM dbo.agentMaster am WITH(NOLOCK) 
			LEFT JOIN dbo.api_districtList al WITH(NOLOCK) ON am.agentLocation = al.districtCode
			LEFT JOIN dbo.bankGuarantee bg WITH(NOLOCK) ON am.agentid = bg.agentId
			LEFT JOIN dbo.mortgage m WITH(NOLOCK) ON am.agentid = m.agentId
			LEFT JOIN dbo.fixedDeposit fd WITH(NOLOCK) ON am.agentId = fd.agentId
			LEFT JOIN dbo.cashSecurity cs WITH(NOLOCK) ON am.agentid = cs.agentId
			WHERE am.isSettlingAgent = ''Y'' 
			AND ISNULL(am.agentBlock,''U'') = ''U''
			AND ISNULL(am.isDeleted,''N'') <> ''Y''
			and am.parentId <> 5576			
			AND (agentType = 2903 or agentType =2904)
			and am.agentCountry =''Nepal''
			AND (bg.bgId IS NULL 
				AND m.mortgageId IS NULL 
				AND cs.csId IS NULL 
				AND fd.fdId IS NULL)
				'
			SET @sqlGroupBy	 = ''
		END				

		IF @zoneName IS NOT NULL
			SET @sql = @sql +' AND am.agentState = '''+@zoneName+''''

		IF @districtName IS NOT NULL
			SET @sql = @sql +' AND am.agentDistrict = '''+@districtName+''''

		IF @locationId IS NOT NULL
			SET @sql = @sql +' AND am.agentLocation = '''+@locationId+''''

		IF @agentId IS NOT NULL
			SET @sql = @sql +' AND am.agentId = '''+@agentId+''''

		
		SET @sql = @sql + @sqlGroupBy	

		EXEC(@sql)
		PRINT(@sql)

		IF @groupBy = 'summary'       
		BEGIN
			DECLARE @tbl TABLE (securityType varchar(50),cnt INT,sflag VARCHAR(50))
			DECLARE @na INT
			SELECT 	@na = ISNULL(COUNT('X'),0)	
			FROM dbo.agentMaster am WITH(NOLOCK) 
			LEFT JOIN dbo.api_districtList al WITH(NOLOCK) ON am.agentLocation = al.districtCode
			LEFT JOIN dbo.bankGuarantee bg WITH(NOLOCK) ON am.agentid = bg.agentId
			LEFT JOIN dbo.mortgage m WITH(NOLOCK) ON am.agentid = m.agentId
			LEFT JOIN dbo.fixedDeposit fd WITH(NOLOCK) ON am.agentId = fd.agentId
			LEFT JOIN dbo.cashSecurity cs WITH(NOLOCK) ON am.agentid = cs.agentId
			WHERE 
			am.isSettlingAgent = 'Y' 
			AND (agentType = 2903 or agentType =2904) 
			and am.agentCountry ='Nepal'
			and am.parentId <> 5576 
			AND ISNULL(am.agentBlock,'U') = 'U'
			AND ISNULL(am.isDeleted,'N') <> 'Y'
			AND (bg.bgId IS NULL 
				AND m.mortgageId IS NULL 
				AND cs.csId IS NULL 
				AND fd.fdId IS NULL)

			
			INSERT INTO @tbl(securityType,cnt,sflag)
			SELECT 'Bank Guarantee',COUNT('x'),'bg' FROM dbo.bankGuarantee
			INSERT INTO @tbl(securityType,cnt,sflag)
			SELECT 'Mortgage',COUNT('x'),'mo' FROM dbo.mortgage
			INSERT INTO @tbl(securityType,cnt,sflag)
			SELECT 'Fixed Deposit', COUNT('x'),'fd' FROM dbo.fixedDeposit
			INSERT INTO @tbl(securityType,cnt,sflag)
			SELECT 'Cash Security', COUNT('x'),'cs' FROM dbo.cashSecurity
			INSERT INTO @tbl(securityType,cnt,sflag)
			SELECT 'Not Available', @na,'na'
			SELECT  
					[S.N.] = ROW_NUMBER()OVER(ORDER BY securityType),
					[Security Type] = securityType,
					[Total Count] = cnt 
			FROM @tbl WHERE sflag = ISNULL(@securityType,sflag)
		END

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL	

		SELECT 'Zone' head, ISNULL(@zoneName,'All') value UNION ALL 
		SELECT 'District' head, ISNULL(@districtName,'All') value UNION ALL
		SELECT 'Location' head, CASE WHEN @locationId IS NULL THEN 'All' ELSE 
			(SELECT districtName FROM dbo.api_districtList dl WITH(NOLOCK) WHERE dl.districtCode = @locationId) END UNION ALL

		SELECT 'Agent' head, CASE WHEN @agentId IS NULL THEN 'All' ELSE 
			(SELECT agentName FROM dbo.agentMaster am WITH(NOLOCK) WHERE am.agentId = @agentId) END UNION ALL 

		SELECT 'Security Type' head, CASE WHEN @securityType IS NULL THEN 'All' 
											WHEN  @securityType  = 'bg' THEN 'Bank Guarantee'
											WHEN  @securityType  = 'cs' THEN 'Cash Security'
											WHEN  @securityType  = 'mo' THEN 'Mortgage'
											WHEN  @securityType  = 'fd' THEN 'Fixed Deposit' 
											WHEN  @securityType  = 'na' THEN 'Not Available' END UNION ALL

		SELECT 'Group By' head, CASE WHEN  @groupBy  = 'aw' THEN 'Agent Wise'
											WHEN  @groupBy  = 'zw' THEN 'Zone Wise'
											WHEN  @groupBy  = 'dw' THEN 'District Wise'
											WHEN  @groupBy  = 'summary' THEN 'Summary' END

		SELECT 'Agent Credit Security Report' title
	END	
END


GO
