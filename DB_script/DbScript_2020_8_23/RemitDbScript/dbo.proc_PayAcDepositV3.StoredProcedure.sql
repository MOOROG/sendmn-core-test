ALTER    proc [dbo].[proc_PayAcDepositV3]
	 @flag			VARCHAR(50)
	,@pAgent		INT				= NULL
	,@mapCodeInt	VARCHAR(100)	= NULL
	,@tranIds		VARCHAR(MAX)	= NULL
	,@fromDate		VARCHAR(20)		= NULL
	,@toDate		VARCHAR(20)		= NULL
	,@user			VARCHAR(50)		= NULL
	,@fromTime		VARCHAR(20)		= NULL
	,@toTime		VARCHAR(20)		= NULL
	,@isHOPaid		CHAR(1)			= NULL
	,@requestFrom	VARCHAR(60)			= NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE  @pAgentName varchar(200)
		,@pBranch int
		,@pBranchName varchar(200)
		,@pState varchar(200)
		,@pDistrict	varchar(200)
		,@pLocation	varchar(50)
		,@tranNos VARCHAR(MAX)
		,@sql VARCHAR(MAX)
		,@pSuperAgent varchar(10)
		,@pSuperAgentName varchar(200)

	IF @fromTime IS NOT NULL
		SET @fromDate = @fromDate+' '+@fromTime
	ELSE 
		SET @fromDate = @fromDate+' 00:00:00'
	IF @toTime IS NOT NULL
		SET @toDate = @toDate+' '+@toTime 
	ELSE
		SET @toDate = @toDate+' 23:59:59'
		
	IF @flag = 'pending'
	BEGIN
		SET @sql =
		'SELECT
			 pAgent			= pAgent
			,pAgentName		= pAgentName
			,txnCount		= COUNT(*)
			,amt			= SUM(pAmt)
		FROM remitTran rt WITH(NOLOCK)
		WHERE 1=1'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		SET @sql = @sql +' AND rt.postedDate between '''+@fromDate+''' and '''+@toDate+''''
		SET @sql = @sql +'
			AND paymentMethod in (''Bank Deposit'' ,''Relief Fund'')
			AND tranStatus = ''Payment'' 
			AND payStatus = ''Post'' 
			AND tranType = ''I''
			GROUP BY pAgent, pAgentName'

		EXEC(@sql)
		RETURN
	END

	IF @flag = 'pendingIntl'				
	BEGIN
		SET @sql =
		'SELECT
			 [isApi]			= ''N''
			,rowId = ''''
			,[Control No]		= dbo.FNADecryptString(rt.controlNo)
			,[Tran No]			= rt.id
			,[Sending Country]	= rt.sCountry
			,[Sending Agent]	= rt.sAgentName
			,[Bank Name]		= rt.pBankName
			,[Branch Name]		= rt.pBankBranchName								
			,[Receiver Name]	= rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
			,[Bank A/C No]		= rt.accountNo
			,[Confirm Date]		= rt.approvedDate
			,[Payout Amount]	= rt.pAmt
			,[Unpaid Days]		= DATEDIFF(D,rt.approvedDate,GETDATE())
			
		FROM [dbo].remitTran rt WITH(NOLOCK)
		inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
		WHERE 1=1'
		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		SET @sql = @sql +' AND rt.postedDate between '''+@fromDate+''' and '''+@toDate+''''
		SET @sql = @sql +'
		AND pAgent = '''+CAST(@pAgent AS VARCHAR)+'''
		AND tranStatus = ''Payment''
		AND paymentMethod IN (''Bank Deposit'' ,''Relief Fund'')
		AND payStatus = ''Post'' 
		AND rt.sCountry <> ''Nepal''
		AND rt.tranType = ''I''
		--AND ISNULL(expectedPayoutAgent,'''') <> ''iso''
		ORDER BY [Unpaid Days] DESC'

		EXEC(@sql)
		RETURN
		
	END

	IF @flag = 'payIntl'
	BEGIN
		DECLARE @tranDetail TABLE(id INT IDENTITY(1,1), tranId VARCHAR(50), controlNo VARCHAR(50), sRouteId VARCHAR(5))
		SET @sql = 'SELECT id, controlNo, sRouteId FROM dbo.remitTran WITH(NOLOCK) WHERE id IN (' + @tranIds + ') 
		AND tranStatus = ''Payment'' 
		AND payStatus = ''Post'' '
		
		INSERT INTO @tranDetail
		EXEC (@sql)

		IF NOT EXISTS(SELECT 'X' FROM @tranDetail)
		BEGIN
			EXEC proc_errorHandler 1, 'No Transaction Found.', NULL
			RETURN
		END
		
		SELECT 
			@pSuperAgent = p.AgentId
			,@pSuperAgentName = p.AgentName
			,@pAgentName = c.agentName	
			,@pAgent = c.agentId
			,@pBranch = c.agentId
			,@pBranchName = c.agentName
			,@isHOPaid = 'Y'
			,@pState			= c.agentState
			,@pDistrict			= c.agentDistrict
			,@pLocation			= c.agentLocation
		FROM AGENTMASTER(NOLOCK) p 
		INNER JOIN AGENTMASTER(NOLOCK) c  ON p.agentId = c.parentId
		WHERE c.agentId = 394419

		BEGIN TRAN
			UPDATE remitTran SET
				  pSuperAgent				=@pSuperAgent
				 ,pSuperAgentName			=@pSuperAgentName
			     ,pAgent					= @pAgent
				 ,pAgentName				= @pAgentName
				,pBranch					= @pBranch
				,pBranchName				= @pBranchName
				,pState						= @pState
				,pDistrict					= @pDistrict
				,pAgentComm					=0
				,pAgentCommCurrency			= 'MNT'
				,pSuperAgentComm			= 0
				,pSuperAgentCommCurrency	= 'MNT'
				,tranStatus					= 'Paid'
				,payStatus					= 'Paid'
				,paidBy						= @user
				,paidDate					= dbo.FNAGetDateInNepalTZ()
				,paidDateLocal				= GETDATE()	
				,customerRate = dbo.FNAGetCustomerRate(countryId, sAgent, sBranch, collcurr, '142',@pAgent, 'MNT', '2')
			FROM remitTran rt WITH(NOLOCK)
			INNER JOIN @tranDetail td on rt.id = td.tranId
			INNER JOIN countryMaster(NOLOCK) cm ON rt.scountry = cm.countryName

			DECLARE @controlNO VARCHAR(20) , @count INT  = 0


			SELECT * INTO #TEMPTRAN FROM @tranDetail

			SELECT @count = count('x') from #TEMPTRAN 

		    WHILE ( @count > 0)
			BEGIN
				SELECT top 1  @controlNO = dbo.decryptDb(controlNo) from #TEMPTRAN
				exec SendMnPro_Account.dbo.Proc_BankDepositVoucher @controlNo =@controlNO ,@refNum= NULL 
				
				DELETE FROM  #TEMPTRAN WHERE controlNo = dbo.encryptDb(@controlNO)
				SET @count = @count -1
			END 
			-- ## Queue Table for Data Integration
			INSERT INTO payQueue2(controlNo, pAgent, pAgentName, pBranch, pBranchName, paidBy, paidDate, paidBenIdType, paidBenIdNumber, routeId)
			SELECT controlNo, @pAgent, @pAgentName, @pBranch, @pBranchName, @user, dbo.FNAGetDateInNepalTZ(), NULL, NULL, sRouteId
			FROM @tranDetail WHERE sRouteId IS NOT NULL
						
		COMMIT TRAN
			IF @requestFrom ='api'
				return
			EXEC proc_errorHandler 0, 'Transaction(s) paid successfully', NULL
		RETURN
	END








GO
