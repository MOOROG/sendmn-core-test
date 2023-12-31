USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_RBA]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 /* EXEC proc_RBA @flag='rba',@customerId=2405263,@cAmt=20000.00  */
CREATE PROC [dbo].[proc_RBA]
	@flag				VARCHAR(10)		= NULL
	,@rowId				INT				= NULL
	,@customerId		BIGINT			= NULL
	,@cAmt				MONEY			= NULL
	,@user				VARCHAR(50)		= NULL
	,@countryCode		INT				= NULL
	,@countryName		VARCHAR(100)	= NULL
	,@isBlocked			BIT				= NULL
	,@agentRefId		VARCHAR(20)		= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
	,@noReturnMsg		BIT				= NULL
		
AS
BEGIN TRY
	DECLARE 
		 @customerRisk			VARCHAR(20)
		,@customerRiskValue 	MONEY
		,@transactionRisk		VARCHAR(20)		
		,@ECDDRequired			CHAR(1)
		,@ComplianceHold		CHAR(1)
		,@errorCode				INT = 0
		,@table					VARCHAR(MAX)
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)
		,@hasRight				CHAR(1)
		 
IF @flag = 'rba'
BEGIN
	
	IF EXISTS(SELECT 'X' FROM dbo.RBAHighRiskCountry WITH(NOLOCK) WHERE countryName=@countryName)
	BEGIN
			SELECT @isBlocked = isBlocked FROM dbo.RBAHighRiskCountry WITH(NOLOCK) WHERE countryName = @countryName

			IF @isBlocked=1
				BEGIN
					EXEC proc_errorHandler 11, '<div style="color: Red !important;">Sorry, Transaction cannot be processed, As Customer is from blocked country. Please contact compliance.</div>', @rowId
					RETURN
				END
			ELSE
				BEGIN
					SELECT @customerRisk = 'High', @customerRiskValue = 100 
				END
	END

	ELSE IF ISNULL(@customerId,'') = ''
		BEGIN
			SELECT @customerRisk = 'MEDIUM RISK', @customerRiskValue = 50 
		END
	ELSE
		BEGIN
			DECLARE @RBAStatus VARCHAR(25)
			
			SELECT @customerRisk		= [TYPE]+' RISK' 
				  ,@customerRiskValue	= ISNULL(RBA,50)
				  ,@RBAStatus			= RBAStatus 
				FROM CUSTOMERS C, RBAScoreMaster R
				WHERE ISNULL(RBA,50) BETWEEN rFrom AND rTo AND customerId = @customerid	
				
				IF ISNULL(@RBAStatus,'')<>''
				 SELECT @customerRisk  = @RBAStatus+' RISK' 
				,@customerRiskValue = 100		
						
		END


IF OBJECT_ID(N'tempdb..#trnTemp') IS NOT NULL
   DROP TABLE #trnTemp
         CREATE TABLE #trnTemp(tranId BIGINT, cAmt MONEY)

DECLARE @matchTranIds VARCHAR(MAX)
	IF @customerId IS NOT NULL
	BEGIN
		
		INSERT INTO #trnTemp(tranId, cAmt)
		SELECT trn.id, cAmt FROM dbo.vwRemitTran trn WITH(NOLOCK)
		INNER JOIN dbo.vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		WHERE sen.customerId = @customerId
		AND cancelApprovedDate IS NULL AND createdDate BETWEEN
		CAST(DATEPART(MONTH, GETDATE()) AS VARCHAR) + '/01/' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR) AND CONVERT(VARCHAR, GETDATE(), 101) + ' 23:59:59:998'

		SELECT @cAmt = @cAmt + ISNULL(SUM(cAmt), 0) FROM #trnTemp

		SELECT @matchTranIds = COALESCE(ISNULL(@matchTranIds + ',', ''), '') + CAST(tranId AS VARCHAR) FROM #trnTemp
	END

	SELECT  @transactionRisk	= transactionRisk
		   ,@ECDDRequired		= ECDDRequired
		   ,@ComplianceHold		= ComplianceHold
	FROM RBACriteriaTransaction
	WHERE customerRisk = @customerRisk
	AND @camt BETWEEN amountFrom AND amountTo

	IF @transactionRisk = 'High Risk' OR @transactionRisk = 'Very High Risk' OR ISNULL(@customerRisk, 'LOW') = 'HIGH' SET @errorCode = 3
	ELSE IF @transactionRisk = 'Medium Risk' OR ISNULL(@customerRisk,'LOW') = 'MEDIUM' SET @errorCode = 2
	ELSE IF @transactionRisk = 'Low Risk' AND  ISNULL(@customerRisk,'LOW') = 'LOW' SET @errorCode = 0

	DECLARE @spanMsg VARCHAR(500) = ''
	IF @transactionRisk = 'Very High Risk'
	BEGIN
		SET @spanMsg = 'Please note that this transaction requires <u>Enhance Customer Due Diligence</u>, please provide an explanation 
                            below about the customer activity and source of funds. Please upload supporting documents to justify the source of funds to process this transaction. Once provided the transaction will be available for payment. Please contact C
ompliance Department for further information +603 2261 4030 ext : 241'
	END
	
	IF ISNULL(@noReturnMsg, 0) <> 1
	BEGIN
		SELECT 'errorCode'			= @errorCode
			   ,'TransactionRisk'	= @transactionRisk
			   ,'CustomerRisk'		= @customerRisk
			   ,'customerRiskValue' = @customerRiskValue
			   ,'ECDDRequired'		= @ECDDRequired
			   ,'ComplianceHold'	= @ComplianceHold
			   ,'spanMsg'			= @spanMsg
	END

	IF @ComplianceHold = 'Y'
	BEGIN
		IF EXISTS(SELECT TOP 1 'X' FROM #trnTemp)
		BEGIN
			INSERT INTO remitTranComplianceTemp(csDetailTranId, matchTranId, agentRefId, reason)
			SELECT 0, @matchTranIds, @agentRefId, 'TXN under RBA parameters. Customer : ' + ISNULL(@customerRisk, '') + ', TXN : ' + ISNULL(@transactionRisk, '')
		END
		ELSE
		BEGIN
			INSERT INTO remitTranComplianceTemp(csDetailTranId, matchTranId, agentRefId, reason)
			SELECT 0, NULL, @agentRefId, 'TXN under RBA parameters. Customer : ' + ISNULL(@customerRisk, '') + ', TXN : ' + ISNULL(@transactionRisk, '')
		END
	END
END

ELSE IF @flag = 'criteria'
BEGIN
	--TXN ASSESSMENT---
	SELECT 'Customer Risk' = customerRisk,'Amount From' = amountFrom,'Amount To' = amountTo,'Transaction Risk' = transactionRisk
	,'ECDD Required' = CASE ECDDRequired WHEN 'M' THEN 'Mandatory' ELSE 'Optional' END
	,'Compliance Hold' = CASE complianceHold WHEN 'Y' THEN 'Yes' ELSE 'No' END
	FROM dbo.RBACriteriaTransaction [Transaction Criteria]

	--PERIODIC ASSESSMENT--
	SELECT 'Parameter' = parameter,'Criteria' = criteria,'Score' = score FROM dbo.RBAcriteriaCustomer [Customer Criteria]

	--Trigger Criteria--
	SELECT Parameter,[From],[To],Score FROM dbo.RBAcriteriaTrigger

	---RATING---
	SELECT  rFrom [Range From],  rTo [Range To] ,TYPE Rating from RBAScoreMaster [Rating]
END

ELSE IF @flag='i-hrc' -- INSERT High Risk Country (hrc)
BEGIN
	
	IF NOT EXISTS(SELECT 'X' FROM RBAHighRiskCountry WITH(NOLOCK) WHERE countryId=@countryCode)
	BEGIN

		INSERT INTO RBAHighRiskCountry(countryId,countryName,isBlocked,createdDate,createdBy)
			VALUES (@countryCode,@countryName,@isBlocked,GETDATE(),@user)

		EXEC proc_errorHandler 0, 'Country added successfully.', @countryCode

	END
	ELSE
	BEGIN
		EXEC proc_errorHandler 1, 'Country already exists in the list.', @countryCode
	END
END

ELSE IF @flag='s-hrc'
BEGIN
		-------
		SET @hasRight = dbo.FNAHasRight(@user, '20191310')			--Add Edit
	

		IF @sortBy IS NULL
			SET @sortBy = 'countryName'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
			
		SET @table = '(
				SELECT DISTINCT
					rowId
					,countryId
					,countryName
					,blocked= CASE WHEN isBlocked=1 THEN ''Yes'' ELSE ''No'' END					
					,customlink = 						
							CASE WHEN '''+@hasRight+'''=''Y'' THEN
							''<a href="AddHighRiskCountry.aspx?type=edit&Id=''+CAST(main.rowId AS VARCHAR)								
								+''">Edit</a>&nbsp;|&nbsp;''
							+''<a onclick="return confirm(''''Are you sure you want to delete?'''');" href="AddHighRiskCountry.aspx?type=delete&Id=''+CAST(main.rowId AS VARCHAR)+''">Delete</a>&nbsp;''
							ELSE '''' END
				FROM RBAHighRiskCountry main WITH(NOLOCK)				
				WHERE 1 = 1 
					) x'
					
		SET @sql_filter = ''
						
		IF @countryName IS NOT NULL 
		BEGIN
			SET @sql_filter = @sql_filter + ' AND countryName LIKE '''+@countryName+'%'''
		END 	
		
		PRINT @table+' '+@sql_filter
		
		SET @select_field_list ='
			rowId,
			countryId,
			countryName,
			blocked,
			customlink
			'
			
			
		EXEC dbo.proc_paging
			@table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
					
		
		RETURN
END

ELSE IF @flag='s-hrc-id'
BEGIN
	SELECT TOP 1 rowid,countryId,countryName,isBlocked FROM RBAHighRiskCountry WITH(NOLOCK) WHERE rowId=@rowId
END

ELSE IF @flag='u-hrc'
BEGIN

	IF NOT EXISTS(SELECT 'X' FROM RBAHighRiskCountry WITH(NOLOCK) WHERE rowId=@rowId)
	BEGIN
		EXEC proc_errorHandler 1, 'Country not exists.', @rowId
	END

	INSERT INTO RBAHighRiskCountryHistory(rowId,countryId,countryName,isBlocked,createdDate,createdBy,modifiedDate,modifiedBy)
		SELECT rowId,countryId,countryName,isBlocked,createdDate,createdBy,GETDATE(),@user FROM RBAHighRiskCountry WITH(NOLOCK) WHERE rowId=@rowId

		UPDATE RBAHighRiskCountry SET countryId=@countryCode,countryName=@countryName,isBlocked=@isBlocked WHERE rowId=@rowId

		EXEC proc_errorHandler 0, 'Country updated successfully.', @rowId
END

ELSE IF @flag='d-hrc'
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM RBAHighRiskCountry WITH(NOLOCK) WHERE rowId=@rowId)
	BEGIN
		EXEC proc_errorHandler 1, 'Country not exists.', @rowId
	END

	INSERT INTO RBAHighRiskCountryHistory(rowId,countryId,countryName,isBlocked,createdDate,createdBy,modifiedDate,modifiedBy)
		SELECT rowId,countryId,countryName,isBlocked,createdDate,createdBy,GETDATE(),@user FROM RBAHighRiskCountry WITH(NOLOCK) WHERE rowId=@rowId

	DELETE FROM RBAHighRiskCountry WHERE rowId=@rowId
	EXEC proc_errorHandler 0, 'Country removed successfully from the list.', @rowId
END

/*
ELSE IF @flag = 'updateRBA'
BEGIN

	IF @ComplianceHold='Y'
	BEGIN
	UPDATE REMITTRANTEMP SET  TRANSTATUS= CASE WHEN  TRANSTATUS='HOLD' THEN 'Compliance Hold' WHEN        TRANSTATUS='OFAC Hold' THEN 'OFAC/Compliance Hold' ELSE TRANSTATUS END

	 INSERT INTO remittrancompliance ( TranId,	csDetailTranId,	reason)
	 SELECT  @tranId,0,'TXN under RBA parameters. Customer '+ @customerRisk + ' TXN '+@transactionRisk
	END

	 ---UPDATE IN TRANSENDERS----
	 UPDATE   transenders SET
	 RBA= CASE WHEN @transactionRisk='LOW RISK' THEN 40 WHEN @transactionRisk='MEDIUM RISK' THEN 50 WHEN @transactionRisk='HIGH RISK' THEN 51 ELSE 100 END
	 ,customerRiskPoint=@customerRiskValue
	 WHERE tranId=@tranId
END
*/
END TRY
BEGIN CATCH    
     SELECT 1 errorCode, ERROR_MESSAGE() msg, NULL id
	 
	 INSERT INTO dbErrorLog(spName, flag, errorMsg, errorLine, createdBy, createdDate)
	SELECT ERROR_PROCEDURE(), @flag, ERROR_MESSAGE(), ERROR_LINE(), @user, GETDATE()	
END CATCH


GO
