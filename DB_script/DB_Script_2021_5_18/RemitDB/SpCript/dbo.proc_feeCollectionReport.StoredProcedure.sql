USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_feeCollectionReport]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_feeCollectionReport]
		 @flag                              VARCHAR(50)		= NULL
		,@user                              VARCHAR(50)		= NULL
		,@fromDate							VARCHAR(20) 	= NULL
		,@toDate							VARCHAR(20)		= NULL
		,@level								VARCHAR(50)		= NULL
		,@controlNo							VARCHAR(50)		= NULL
		,@agentId							INT				= NULL
		,@sAgentId							VARCHAR(50)		= NULL
		,@status							VARCHAR(50)		= NULL
		,@sortOrder                         VARCHAR(50)		= NULL
		,@pageSize                          VARCHAR(20)		= NULL
		,@pageNumber                        VARCHAR(20)		= NULL
		,@sortBy							VARCHAR(20)		= NULL

AS

SET NOCOUNT ON
SET XACT_ABORT ON
DECLARE @SQL AS VARCHAR(MAX),
		@SQL1 AS VARCHAR(MAX),
		@schoolId AS VARCHAR(50)
SET @toDate=@toDate+' 23:59:59'
				
	IF @flag = 'a'
	BEGIN

				SELECT @schoolId = rowId FROM schoolMaster WITH(NOLOCK) WHERE agentId=@agentId
				SET @SQL ='
							SELECT 
							    [S.N.]			= row_number()over(ORDER BY CONVERT(VARCHAR,a.createdDate,101)),
								[Control No] = dbo.FNADecryptString(controlNo),								
								[TXN Date] = CONVERT(VARCHAR,a.createdDate,101),
								[Amount] = pAmt,
								[Student Name] = b.stdName,
								[Reg. No./Roll No.] = b.stdRollRegNo,
								[Level/Class] = f.name,
								[Semester/Year] = b.stdSemYr,
								[Fee Type]	= d.feeType,
								[Sender Name] = ISNULL(c.firstName,'''')+'' ''+ISNULL(c.middleName,'''')+'' ''+ISNULL(c.lastName1,''''),								
								[Contact No.] = c.mobile
								FROM remitTran a WITH(NOLOCK) 
								INNER JOIN tranReceivers b WITH(NOLOCK) ON a.id=b.tranId
								INNER JOIN tranSenders c WITH(NOLOCK) ON b.tranId=c.tranId
								LEFT JOIN schoolFee d WITH(NOLOCK) ON b.feeTypeId=d.rowId
								LEFT JOIN schoolLevel f WITH(NOLOCK) ON f.rowId = b.stdLevel
							WHERE 1=1 AND b.stdCollegeId is not null and a.tranStatus <> ''Cancel''
							and a.createdDate between '''+@fromDate+''' and  '''+@toDate+''''
				
				IF @schoolId IS NOT NULL 
					SET @SQL=@SQL+' AND b.stdCollegeId= '''+@schoolId+''''
						
				IF @controlNo IS NOT NULL
					SET @SQL=@SQL+' AND a.controlNo = '''+dbo.FNAEncryptString(@controlNo)+''''
					
				IF @level IS NOT NULL
						SET @SQL=@SQL+' AND f.rowId = '''+@level+''''
					
				
				EXEC(@SQL)					
				EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

				SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
				UNION ALL
				SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value
				UNION ALL
				SELECT 'Level/Program' head,case when @level is null then 'All' else  (select name from schoolLevel with(nolock) where rowId= @level)end value
				UNION ALL
				SELECT 'Control No' head, isnull(@controlNo,'All') value
				
				SELECT 'School Fee Collection Report' title
	END	

	IF @flag = 'b'
	BEGIN				
		SELECT @schoolId = rowId FROM schoolMaster WITH(NOLOCK) WHERE agentId = @agentId
		SET @SQL ='
					SELECT 
						[S.N] = ROW_NUMBER() OVER (ORDER BY CONVERT(VARCHAR,a.createdDate,101)) , 
						[Control No] = dbo.FNADecryptString(controlNo),								
						[TXN Date] = CONVERT(VARCHAR,a.createdDate,101),
						[Amount] = pAmt,
						[Student Name] = b.stdName,
						[Reg. No./Roll No.] = b.stdRollRegNo,
						[Level/Class] = f.name,
						[Semester/Year] = b.stdSemYr,
						[Fee Type]	= d.feeType,
						[Sender Name] = ISNULL(c.firstName,'''')+'' ''+ISNULL(c.middleName,'''')+'' ''+ISNULL(c.lastName1,''''),
						[Receiver Name] = ISNULL(b.firstName,'''')+'' ''+ISNULL(b.middleName,'''')+'' ''+ISNULL(b.lastName1,''''),	
						[Sending Agent] = a.sBranchName,
						[Bank Name] = a.pBankName,
						[Account Number] = a.accountNo,							
						[Sender Contact No.] = c.mobile,
						[Status] = a.payStatus
						FROM remitTran a WITH(NOLOCK) 
						INNER JOIN tranReceivers b WITH(NOLOCK) ON a.id=b.tranId
						INNER JOIN tranSenders c WITH(NOLOCK) ON b.tranId=c.tranId
						LEFT JOIN schoolFee d WITH(NOLOCK) ON b.feeTypeId=d.rowId
						LEFT JOIN schoolLevel f WITH(NOLOCK) ON f.rowId = b.stdLevel
					WHERE 1=1 and b.stdCollegeId is not null and a.tranStatus <> ''Cancel'' '
			
		IF @controlNo IS NOT NULL
			SET @SQL=@SQL+' AND a.controlNo = '''+dbo.FNAEncryptString(@controlNo)+''''
		ELSE
		BEGIN		
			SET @SQL=@SQL+' AND a.createdDate between '''+@fromDate+''' and  '''+@toDate+''''

			IF @schoolId IS NOT NULL 
				SET @SQL=@SQL+' AND b.stdCollegeId= '''+@schoolId+''''

			IF @sAgentId IS NOT NULL 
				SET @SQL=@SQL+' AND a.sBranch= '''+@sAgentId+''''
					
			IF @level IS NOT NULL
					SET @SQL=@SQL+' AND f.rowId = '''+@level+''''

			IF @status = 'unpaid'
					SET @SQL=@SQL+' AND a.payStatus in (''Unpaid'',''Un-Paid'')'

			IF @status = 'paid'
					SET @SQL=@SQL+' AND a.payStatus in (''Paid'')'		
		END

		EXEC(@SQL)					
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL


		SELECT 'From Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
		UNION ALL
		SELECT 'To Date' head, CONVERT(VARCHAR(10), @toDate, 101) value
		UNION ALL
		SELECT 'College/School' head,case when @agentId is null then 'All' else  
					(select agentName from agentMaster with(nolock) where agentId= @agentId)end value
		UNION ALL
		SELECT 'Level/Program' head,case when @level is null then 'All' else  (select name from schoolLevel with(nolock) where rowId= @level)end value
		UNION ALL
		SELECT 'Status' head, isnull(@status,'All') value
		UNION ALL
		SELECT 'Control No' head, isnull(@controlNo,'All') value
				
		SELECT 'School Fee Collection Report' title
	END	
	
	
	
	



GO
