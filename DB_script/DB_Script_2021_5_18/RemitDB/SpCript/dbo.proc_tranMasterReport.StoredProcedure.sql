USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tranMasterReport]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_tranMasterReport] (
	 @flag					VARCHAR(50)
	,@user					VARCHAR(50)		= NULL
	,@sHub					BIGINT			= NULL
	,@ssAgent				BIGINT			= NULL
	,@sCountry				VARCHAR(200)	= NULL
	,@sAgent				BIGINT			= NULL
	,@sBranch				BIGINT			= NULL
	,@sUser					varchar(50)		= NULL
	,@sZone					BIGINT			= NULL
	,@sDistrict				BIGINT			= NULL
	,@sLocation				BIGINT			= NULL
	,@sFirstName			VARCHAR(50)		= NULL
	,@sMiddleName			VARCHAR(50)		= NULL
	,@sLastName1			VARCHAR(50)		= NULL
	,@sLastName2			VARCHAR(50)		= NULL
	,@sMobile				VARCHAR(20)		= NULL
	,@sEmail				VARCHAR(50)		= NULL
	,@sIDNumber				VARCHAR(20)		= NULL
	,@rHub					BIGINT			= NULL
	,@rsAgent				BIGINT			= NULL
	,@rCountry				VARCHAR(200)	= NULL
	,@rAgent				BIGINT			= NULL
	,@rBranch				BIGINT			= NULL
	,@rUser					varchar(50)		= NULL
	,@rZone					BIGINT			= NULL
	,@rDistrict				BIGINT			= NULL
	,@rLocation				BIGINT			= NULL
	,@rFirstName			VARCHAR(50)		= NULL
	,@rMiddleName			VARCHAR(50)		= NULL
	,@rLastName1			VARCHAR(50)		= NULL
	,@rLastName2			VARCHAR(50)		= NULL
	,@rMobile				VARCHAR(20)		= NULL
	,@rEmail				VARCHAR(50)		= NULL
	,@rIDNumber				VARCHAR(20)		= NULL
	,@controlNumber			VARCHAR(50)		= NULL
	,@tranType				INT				= NULL
	,@orderBy				VARCHAR(100)	= NULL
	,@sendDateFrom			VARCHAR(20)		= NULL
	,@sendDateTo			VARCHAR(20)		= NULL
	,@paidDateFrom			VARCHAR(20)		= NULL
	,@paidDateTo			VARCHAR(20)		= NULL
	,@cancelledDateFrom		VARCHAR(20)		= NULL
	,@cancelledDateTo		VARCHAR(20)		= NULL
	,@approvedDateFrom		VARCHAR(20)		= NULL
	,@approvedDateTo		VARCHAR(20)		= NULL
	,@collectionAmountFrom	MONEY			= NULL
	,@collectionAmountTo	MONEY			= NULL
	,@payoutAmountFrom		MONEY			= NULL
	,@payoutAmountTo		MONEY			= NULL
	,@tranStatus			VARCHAR(50)				= NULL
	,@tranSendList				VARCHAR(MAX)	= NULL
	,@senderList				VARCHAR(MAX)	= NULL
	,@tranPayList				VARCHAR(MAX)	= NULL
	,@receiverList				VARCHAR(MAX)	= NULL
	,@pageSize					VARCHAR(50)	= NULL
	,@pageNumber				VARCHAR(50) = NULL
)
AS	
	SET NOCOUNT ON
	
	declare @rZoneName varchar(200),@sZoneName varchar(200),@rDistrictName as varchar(200),@sDistrictName as varchar(200)
	if @rZone is not null
		select @rZoneName=stateName from countryStateMaster where stateId=@rZone
	if @sZone is not null
	select @sZoneName=stateName from countryStateMaster where stateId=@sZone
	if @rDistrict is not null
		select @rDistrictName=districtName from zoneDistrictMap where districtId=@rDistrict
	if @sDistrict is not null
	select @sDistrictName=districtName from zoneDistrictMap where districtId=@sDistrict
	DECLARE @rptFilter TABLE (
		 head	VARCHAR(50)
		,value	VARCHAR(200)
	)
	DECLARE @tranSend TABLE (
		 id		INT IDENTITY(1, 1)
		,title	VARCHAR(50)
		,alias	VARCHAR(50)
	)
	
	INSERT @tranSend (title, alias)
		SELECT '[Transaction Send_Agent]', 'Agent'								UNION ALL
		SELECT '[Transaction Send_Control No]', 'Control No'					UNION ALL
		SELECT '[Transaction Send_Collection Amount]', 'Collection Amount'		UNION ALL
		SELECT '[Transaction Send_USD Amount]', 'USD Amount'					UNION ALL
		SELECT '[Transaction Send_USD Rate]', 'USD Rate'						UNION ALL
		SELECT '[Transaction Send_Collection Currency]', 'Collection Currency'	UNION ALL
		SELECT '[Transaction Send_Service Charge]', 'Service Charge'			UNION ALL
		SELECT '[Transaction Send_Agent Commission]', 'Agent Commission'		UNION ALL		
		SELECT '[Transaction Send_Country]', 'Agent Country'					UNION ALL
		SELECT '[Transaction Send_State]', 'Agent State'						UNION ALL
		SELECT '[Transaction Send_District]', 'Agent District'					UNION ALL
		SELECT '[Transaction Send_Location]', 'Agent Location'					UNION ALL		
		SELECT '[Transaction Send_City]', 'Agent City'							UNION ALL
		SELECT '[Transaction Send_Address]', 'Agent Address'					UNION ALL		
		SELECT '[Transaction Send_Payment Method]', 'Payment Method'			
			
	DECLARE @sender TABLE (
		 id		INT IDENTITY(1, 1)
		,title	VARCHAR(50)
		,alias	VARCHAR(50)
	)
	
	INSERT @sender (title, alias)
	SELECT '[Sender Information_Name]', 'Name'								UNION ALL
	SELECT '[Sender Information_Address]', 'Address'						UNION ALL
	SELECT '[Sender Information_Contact Number]', 'Contact Number'

	DECLARE @tranPay TABLE (
		 id		INT IDENTITY(1, 1)
		,title	VARCHAR(50)
		,alias	VARCHAR(50)
	)
	
	INSERT @tranPay (title, alias)
	SELECT '[Transaction Pay_Agent]', 'Agent'						UNION ALL
	SELECT '[Transaction Pay_Payout Amount]', 'Payout Amount'		UNION ALL
	SELECT '[Transaction Pay_Agent Commission]', 'Agent Commission'	UNION ALL
	SELECT '[Transaction Pay_Payout Currency]', 'Payout Currency'	UNION ALL
	SELECT '[Transaction Pay_Country]', 'Agent Country'				UNION ALL
	SELECT '[Transaction Pay_State]', 'Agent State'					UNION ALL
	SELECT '[Transaction Pay_District]', 'Agent District'			UNION ALL
	SELECT '[Transaction Pay_Location]', 'Agent Location'			UNION ALL
	SELECT '[Transaction Pay_City]', 'Agent City'					UNION ALL
	SELECT '[Transaction Pay_Address]', 'Agent Address'				UNION ALL
	SELECT '[Transaction Pay_Tran Status]', 'Tran Status'			UNION ALL	
	SELECT '[Transaction Pay_Paid By]', 'Paid By'					UNION ALL
	SELECT '[Transaction Pay_Paid Date]', 'Paid Date'				UNION ALL	
	SELECT '[Transaction Pay_Approved Date]', 'Approved Date'		UNION ALL
	SELECT '[Transaction Pay_Requested Date]', 'Requested Date'		UNION ALL
	SELECT '[Transaction Pay_Requested Time]', 'Requested Time'		
				 
	DECLARE @receiver TABLE (
		 id		INT IDENTITY(1, 1)
		,title	VARCHAR(50)
		,alias	VARCHAR(50)
	)
	
	INSERT @receiver (title, alias)
	SELECT '[Receiver Information_Name]', 'Name' UNION ALL
	SELECT '[Receiver Information_Address]', 'Address' UNION ALL
	SELECT '[Receiver Information_Contact No]', 'Contact Number'
				
	IF @flag = 'l'
	BEGIN
		SELECT * FROM @tranSend
		
		SELECT * FROM @sender
		SELECT * FROM @tranPay
		SELECT * FROM @receiver
		RETURN
	END
	
	IF @flag = 'l2'
	BEGIN
		SELECT title, case when alias like '%agent%' then 'Sending '+alias  else alias end as alias FROM @tranSend
		union all
		SELECT title, 'Sender '+ alias FROM @sender
		union all
		SELECT title, case when alias like '%agent%' then 'Payout '+alias  else alias end as alias FROM @tranPay
		union all
		SELECT title, 'Receiver '+alias FROM @receiver
		RETURN
	END

	IF @flag = 'r'
	BEGIN
		DECLARE 
			 @sql VARCHAR(MAX)
			,@table VARCHAR(MAX)
			,@selectList VARCHAR(MAX)
			,@SQL1		VARCHAR(MAX)
			
		SET @table = '
			SELECT
			
				  [Transaction Pay_Approved Date] = FORMAT(trn.approvedDate,''yyyyMMdd'')
				 ,[Transaction Pay_Requested Date] = FORMAT(trn.createdDate,''yyyyMMdd'')
				 ,[Transaction Pay_Requested Time] = FORMAT(trn.createdDate,''HHmmss'')
				 ,[Transaction Send_Tran ID] =  trn.id
				 ,[Transaction Send_Control No] = dbo.FNADecryptString(trn.controlNo)
				 ,[Transaction Send_Agent] = ISNULL(trn.sBranchName, ''-'')
				 ,[Transaction Send_Collection Amount]=trn.cAmt
				 ,[Transaction Send_USD Amount]=ROUND(trn.tAmt/(trn.sCurrCostRate + trn.sCurrHoMargin), 2)		
				 ,[Transaction Send_USD Rate]=trn.sCurrCostRate + trn.sCurrHoMargin
				 ,[Transaction Send_Collection Currency]=trn.collCurr
				 ,[Transaction Send_Transaction Amount]=trn.tAmt
				 ,[Transaction Send_Service Charge]=trn.serviceCharge
				 ,[Transaction Send_Handling Fee] = ISNULL(trn.handlingFee, 0)
				 ,[Transaction Send_Agent Commission]=trn.sAgentComm
				 ,[Transaction Send_Country] = sa.agentCountry
				 ,[Transaction Send_State] = sa.agentState
				 ,[Transaction Send_District] = sa.agentDistrict
				 ,[Transaction Send_Location] = sLoc.districtName
				 ,[Transaction Send_City] = sa.agentCity
				 ,[Transaction Send_Address] = sa.agentAddress
                 ,[Transaction Send_Purpose Of Remit] = ISNULL(trn.purposeOfRemit, ''-'')
                 ,[Transaction Send_Source Of Fund] = ISNULL(trn.purposeOfRemit, ''-'')
                 ,[Transaction Send_Collection Mode] = trn.collMode
                 ,[Transaction Send_Payment Method] = trn.paymentMethod

				 ,[Sender Information_Member ID] = sen.membershipId
				 ,[Sender Information_Customer ID] = sen.customerId
				 ,[Sender Information_Name] = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')
				 ,[Sender Information_Country] = sen.country
				 ,[Sender Information_State] = sen.state
				 ,[Sender Information_District] = sen.district
				 ,[Sender Information_City] = sen.city
				 ,[Sender Information_Address] = sen.address
				 ,[Sender Information_Contact Number] = COALESCE(sen.mobile, sen.homephone, sen.workphone)
				 ,[Sender Information_ID Type] = sen.idType
				 ,[Sender Information_ID Number] = sen.idNumber
				 ,[Sender Information_Valid Date] = sen.validDate
				 ,[Sender Information_Email] = sen.email
				                
				 ,[Transaction Pay_Agent] = ISNULL(trn.pBranchName, ''-'')
				 ,[Transaction Pay_Payout Amount] = trn.pAmt
				 ,[Transaction Pay_Agent Commission]=trn.pAgentComm		
				 ,[Transaction Pay_Payout Currency] = trn.payoutCurr
				 ,[Transaction Pay_Country] = trn.pCountry
				 ,[Transaction Pay_State] = trn.pState
				 ,[Transaction Pay_District] = trn.pDistrict
				 ,[Transaction Pay_Location] = pLoc.districtName
				 ,[Transaction Pay_City] = pa.agentCity
				 ,[Transaction Pay_Address] = pa.agentAddress                         
				 ,[Transaction Pay_Relationship With Sender] = ISNULL(trn.relWithSender, ''-'')
				 ,[Transaction Pay_Tran Status]=trn.tranStatus
				 ,[Transaction Pay_Pay Status]=trn.payStatus	
				 ,[Transaction Pay_Payout Message] = ISNULL(trn.pMessage, ''-'')
				 ,[Transaction Pay_Paid By] = ISNULL(trn.paidBy, ''-'')
				 ,[Transaction Pay_Paid Date] = ISNULL(cast(trn.paidDate as varchar), ''-'')

				 ,[Receiver Information_Member ID] = rec.membershipId
				 ,[Receiver Information_Customer ID] = rec.customerId
				 ,[Receiver Information_Name] = rec.firstName + ISNULL( '''' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '' '')
				 ,[Receiver Information_Country] = rec.country
				 ,[Receiver Information_State] = rec.state
				 ,[Receiver Information_District] = rec.district
				 ,[Receiver Information_City] = rec.city
				 ,[Receiver Information_Address] = rec.address
				 ,[Receiver Information_Contact No] = COALESCE(rec.mobile, rec.homephone, rec.workphone)
				 ,[Receiver Information_ID Type] = rec.idType
				 ,[Receiver Information_ID Number] = rec.idNumber
                        		
			 FROM remitTran trn WITH(NOLOCK)

			  LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
			  LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
			  LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
			  LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
			  LEFT JOIN api_districtList pLoc WITH(NOLOCK) ON trn.pLocation = pLoc.districtCode
			  LEFT JOIN api_districtList sLoc WITH(NOLOCK) ON sa.agentLocation = sLoc.districtCode
            			
			WHERE 1 = 1 		
		'
		
		SELECT
			@selectList = ISNULL(@selectList + ', ', '') + title + ' ' + ISNULL(NULLIF(title, ''), title) + '' + CHAR(13)
		FROM @tranSend WHERE id IN(SELECT value FROM dbo.Split(',', @tranSendList) x)
		
		SELECT
			@selectList = ISNULL(@selectList + ', ', '') + title + ' ' + ISNULL(NULLIF(title, ''), title) + '' + CHAR(13)
		FROM @sender WHERE id IN(SELECT value FROM dbo.Split(',', @senderList) x)
		
		SELECT
			@selectList = ISNULL(@selectList + ', ', '') + title + ' ' + ISNULL(NULLIF(title, ''), title) + '' + CHAR(13)
		FROM @tranPay WHERE id IN(SELECT value FROM dbo.Split(',', @tranPayList) x)
		
		SELECT
			@selectList = ISNULL(@selectList + ', ', '') + title + ' ' + ISNULL(NULLIF(title, ''), title) + '' + CHAR(13)
		FROM @receiver WHERE id IN(SELECT value FROM dbo.Split(',', @receiverList) x)		

		SET @sql = ''		
		
		IF @controlNumber IS NULL
		BEGIN
			-- ### TRAN FILTER 
			
				-- ## SENDING TRAN
			IF @ssAgent IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.sSuperAgent = ' + CAST(@ssAgent AS VARCHAR)
				INSERT INTO @rptFilter(head,value)
				select 'Sending Super Agent',agentName from agentMaster where agentId=@ssAgent
			END
				
			IF @sCountry IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.sCountry =  ''' + CAST(@sCountry AS VARCHAR) + ''''
				INSERT INTO @rptFilter(head,value)
				select 'Sending Country',@sCountry 
			END
			
			IF @sAgent IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.sAgent = ' + CAST(@sAgent AS VARCHAR)
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending Agent',agentName from agentMaster  where agentId=@sAgent 
			END
				
			IF @sBranch IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.sBranch = ' + CAST(@sBranch AS VARCHAR)
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending Branch',agentName from agentMaster  where agentId=@sBranch 
			END
				
			IF @tranType IS NOT NULL
			begin
				declare @tranTypeName as varchar(20)
				select @tranTypeName=typeTitle from serviceTypeMaster where serviceTypeId=@tranType
				SET @sql = @sql + ' AND trn.paymentMethod =  ''' + CAST(@tranTypeName AS VARCHAR) + ''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Transaction Type',@tranTypeName
			end
				
			IF @sUser IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.createdBy = ''' + CAST(@sUser AS VARCHAR) + ''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Send/Created By',@sUser
			END	
				--- PAYOUT BRANCH
			IF @rsAgent IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.pSuperAgent = ' + CAST(@rsAgent AS VARCHAR)
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Super Agent',agentName from agentMaster  where agentId=@rsAgent 
			END
				
			IF @rCountry IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.pCountry =  ''' + CAST(@rCountry AS VARCHAR) + ''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Country',@rCountry 
			END
		
			IF @rAgent IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.pAgent = ' + CAST(@rAgent AS VARCHAR)
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Agent',agentName from agentMaster  where agentId=@rAgent 				
			END
				
			IF @rBranch IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.pBranch = ' + CAST(@rBranch AS VARCHAR)
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Branch',agentName from agentMaster  where agentId=@rBranch 		
			END
			
			IF @rUser IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.paidBy = ''' + CAST(@rUser AS VARCHAR) + ''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Paid By',@rUser 	
			END

			IF @sendDateFrom IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.createdDate >= ''' + @sendDateFrom  + ''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Send Date From',@sendDateFrom 	
			END
			
			IF @sendDateTo IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.createdDate <= ''' + @sendDateTo + ' 23:59:59'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Send Date To',@sendDateTo 	
			END
		
			IF @paidDateFrom IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.paidDate >= ''' + @paidDateFrom + ''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Paid Date From',@paidDateFrom 	
			END
				
			IF @paidDateTo IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.paidDate <= ''' + @paidDateTo + ' 23:59:59'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Paid Date To',@paidDateFrom 	
			END

			IF @cancelledDateFrom IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.cancelApprovedDate >= ''' + @cancelledDateFrom + ''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Cancel Date From',@cancelledDateFrom 	
			END

			IF @cancelledDateTo IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.cancelApprovedDate <= ''' + @cancelledDateTo + ' 23:59:59'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Cancel Date To',@cancelledDateTo 
			END

			IF @approvedDateFrom IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.approvedDate >= ''' + @approvedDateFrom + ''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Approved Date From',@approvedDateFrom 
			END

			IF @approvedDateTo IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.approvedDate <= ''' + @approvedDateTo + ' 23:59:59'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Approved Date To',@approvedDateTo 
			END

			IF @collectionAmountFrom IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.cAmt >= ' + CAST(@collectionAmountFrom AS VARCHAR)	
				INSERT INTO @rptFilter(head,value)
				SELECT 'Collection Amount From ',@collectionAmountFrom 					
			END

			IF @collectionAmountTo IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.cAmt <= ' + CAST(@collectionAmountTo AS VARCHAR)
				INSERT INTO @rptFilter(head,value)
				SELECT 'Collection Amount To ',@collectionAmountTo 	
			END
			
			IF @payoutAmountFrom IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.pAmt >= ' + CAST(@payoutAmountFrom AS VARCHAR)	
				INSERT INTO @rptFilter(head,value)
				SELECT 'Payout Amount From ',@payoutAmountFrom 	
			END
			
			IF @payoutAmountTo IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.cAmt <= ' + CAST(@payoutAmountTo AS VARCHAR)
				INSERT INTO @rptFilter(head,value)
				SELECT 'Payout Amount To ',@payoutAmountTo 
			END	

			IF @tranStatus IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND trn.tranStatus = ''' + CAST(@tranStatus AS VARCHAR)+''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Transaction Status',@tranStatus 
			END
				
			-- ### SENDING AGENT FILTER
			IF @sZone IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sa.agentState = ''' + CAST(@sZoneName AS VARCHAR)+''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending Zone',@sZone 
			END
			
			IF @sDistrict IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sa.agentDistrict =''' + CAST(@sDistrictName AS VARCHAR)+''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending District',@sDistrict 
			END
				
			
			IF @sLocation IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sa.agentLocation = ' + CAST(@sLocation AS VARCHAR)
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending Location',@sLocation 
			END
			
			/* Sender Filter*/
			IF @sFirstName IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sen.FirstName LIKE ''' + @sFirstName  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending First Name',@sFirstName 
			END
			
			IF @sMiddleName IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sen.MiddleName LIKE ''' + @sMiddleName  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending Middle Name',@sFirstName 
			END
				
			IF @sLastName1 IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sen.lastName1 LIKE ''' + @sLastName1  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending Last Name',@sLastName1 
			END
			
			IF @sLastName2 IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sen.LastName2 LIKE ''' + @sLastName2  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending Second Last Name',@sLastName2 
			END
			
			IF @sMobile IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sen.mobile LIKE ''' + @sMobile  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending Mobile',@sMobile 
			END
				
			IF @sEmail IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sen.email LIKE ''' + @sEmail  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending Email',@sEmail 
			END
								
			IF @sIDNumber IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND sen.membershipId LIKE ''' + @sIDNumber  + '%'''	
				INSERT INTO @rptFilter(head,value)
				SELECT 'Sending ID Number',@sIDNumber 					
			END
			
				
			-- ### PAYOUT AGENT FILTER
				
			IF @rZone IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND pa.agentState = ''' + CAST(@rZoneName AS VARCHAR)+''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Zone',@rZone 	
			END
				
			IF @rDistrict IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND pa.agentDistrict = ''' + CAST(@rDistrictName AS VARCHAR)+''''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving District',@rDistrict 	
			END
				
			IF @rLocation IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND pa.agentLocation = ' + CAST(@rLocation AS VARCHAR)
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Location',@rLocation 	
			END
		
			-- ## RECEIVER FILTER
			IF @rFirstName IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND rec.FirstName LIKE ''' + @rFirstName  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving First Name',@rFirstName 	
			END
					
			IF @rMiddleName IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND rec.MiddleName LIKE ''' + @rMiddleName  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Middle Name',@rMiddleName 	
			END
				
			IF @rLastName1 IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND rec.lastName1 LIKE ''' + @rLastName1  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Last Name',@rLastName1 	
			END
			
			IF @rLastName2 IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND rec.sLastName2 LIKE ''' + @rLastName2  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Second Last Name',@rLastName2 	
			END
			
			IF @rMobile IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND rec.mobile LIKE ''' + @rMobile  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Mobile',@rMobile 	
			END
				
			IF @rEmail IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND rec.email LIKE ''' + @rEmail  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving Email',@rEmail 	
			END
				
			IF @rIDNumber IS NOT NULL
			BEGIN
				SET @sql = @sql + ' AND rec.membershipId LIKE ''' + @rIDNumber  + '%'''
				INSERT INTO @rptFilter(head,value)
				SELECT 'Receiving ID Number',@rIDNumber 	
			END
		END
		ELSE 
		BEGIN
			SET @controlNumber = dbo.FNAEncryptString(@controlNumber)
			SET @sql = @sql + ' AND trn.controlNo = ''' + CAST(@controlNumber AS VARCHAR) + ''''
			INSERT INTO @rptFilter(head,value)
			SELECT 'Control Number',@controlNumber 				
		END

		IF @orderBy IS NULL
		BEGIN
			SET @orderBy = '[Transaction Send_Tran ID]';	
		END	
		ELSE 
		BEGIN
			INSERT INTO @rptFilter(head,value)
			SELECT 'Order By',@orderBy 		
		END
		
		IF @selectList IS NULL
		BEGIN
			SET @sql1 = 'SELECT '
							+ 
							ISNULL(@selectList, ' * ') + '
						 FROM  ( 
						 '	
						 
								+ @table + @sql +
						
						' ) x '
		END
		ELSE		
		BEGIN	
			SET @sql1 = 'SELECT [Transaction Send_Tran ID] ,'
							+ 
							ISNULL(@selectList, ' * ') + '
						 FROM  ( 
						 '	
						 
								+ @table + @sql +
						
						' ) x '
					
		END	
		DECLARE @SQL2 AS VARCHAR(MAX)	
		
		SET @SQL2='
		SELECT COUNT(''a'') AS TXNCOUNT,'+@pageSize+' PAGESIZE,'+@pageNumber+' PAGENUMBER FROM ('+ @sql1+') AS tmp;

		SELECT * FROM 
		(
			SELECT ROW_NUMBER() OVER (ORDER BY '+@orderBy+' DESC) AS [Transaction Send_S.N.],* 
			FROM 
			(
				'+ @sql1 +'
			) A
		) B WHERE 1 = 1 AND  B.[Transaction Send_S.N.] BETWEEN (('+@pageNumber+' - 1) * '+@pageSize+' + 1) AND '+@pageNumber+' * '+@pageSize+'
		'
		
		PRINT(@SQL2)
		EXEC(@SQL2)
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT * FROM @rptFilter
		
		SELECT 'Transaction Master Report' title
	END 







GO
