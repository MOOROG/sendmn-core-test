SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROC PROC_API_ROUTE_PARTNERS
(
	@FLAG					VARCHAR(20)
	--grid parameters
	,@user					VARCHAR(50)		= NULL
	,@pageSize				VARCHAR(50)		= NULL
	,@pageNumber			VARCHAR(50)		= NULL
	,@sortBy				VARCHAR(50)		= NULL
	,@sortOrder				VARCHAR(50)		= NULL
	,@agentID				BIGINT			= NULL
	,@PaymentMethod			INT				= NULL	
	,@CountryId				INT				= NULL	
	,@CountryName			VARCHAR(50)		= NULL	
	,@isActive				VARCHAR(10)		= NULL
	,@rowId					INT				= NULL
	,@isRealTime			BIT				= NULL 
	,@minTxnLimit			MONEY			= NULL 
	,@maxTxnLimit			MONEY			= NULL
	,@limitCurrency			varchar(3)	    = NULL	
	,@exRateCalcByPartner	BIT				= NULL	 
	,@isACValidateSupport	BIT				= NULL	 
	,@id					INT				= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE  @table				VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)

	IF @FLAG = 'I'
	BEGIN
		IF EXISTS (SELECT 1 FROM TblPartnerwiseCountry (NOLOCK) WHERE CountryId = @CountryId AND ISNULL(PaymentMethod, 0) = ISNULL(@PaymentMethod, 0) AND AgentId = @agentID)
		BEGIN 
			SELECT '0' ErrorCode , 'Record already exists, please use existing record.' Msg , NULL id	 
			RETURN
		END
		--IF EXISTS (SELECT 1 FROM TblPartnerwiseCountry (NOLOCK) WHERE CountryId = @CountryId AND ISNULL(PaymentMethod, @PaymentMethod) = @PaymentMethod AND AgentId = @agentID)
		-- new changes by anoj ISNULL(PaymentMethod, @PaymentMethod) = @PaymentMethod replace with PaymentMethod = @PaymentMethod
		IF EXISTS (SELECT 1 FROM TblPartnerwiseCountry (NOLOCK) WHERE CountryId = @CountryId AND PaymentMethod = @PaymentMethod AND AgentId = @agentID)
		BEGIN 
			SELECT '0' ErrorCode , 'Record already exists for all payment methods, please use existing record.' Msg , NULL id	 
			RETURN
		END

		INSERT INTO TblPartnerwiseCountry (CountryId, AgentId, IsActive, CreatedBy, CreatedDate, PaymentMethod,isRealTime,minTxnLimit,maxTxnLimit,LimitCurrency,exRateCalByPartner,isACValidateSupport)
		SELECT @CountryId, @agentID, @isActive, @user, GETDATE(), @PaymentMethod,@isRealTime,@minTxnLimit,@maxTxnLimit,@limitCurrency,@exRateCalcByPartner,@isACValidateSupport

		SELECT '0' ErrorCode , 'Record has been added successfully.' Msg , NULL id
	END
	IF @FLAG = 'u'
	BEGIN
		--INSERT INTO TblPartnerwiseCountryHistory (partnerWiseCountryRowId, CountryId, AgentId, IsActive, PaymentMethod, ModifiedBy, ModifiedDate,isRealTime,minTxnLimit,maxTxnLimit,LimitCurrency,exRateCalByPartner)
		--SELECT @rowId, CountryId, AgentId, IsActive, PaymentMethod, @user, GETDATE(),isRealTime,minTxnLimit,maxTxnLimit,LimitCurrency,exRateCalByPartner FROM TblPartnerwiseCountry (NOLOCK) WHERE id = @rowId
		IF exists(SELECT 1 FROM TblPartnerwiseCountryMod WHERE id = @rowId )
		BEGIN
			UPDATE TblPartnerwiseCountryMod SET CountryId = @CountryId, 
												IsActive = @isActive, 
												ModifiedBy = @user, 
												ModifiedDate = GETDATE(), 
												PaymentMethod = @PaymentMethod,
												AgentId = @agentID,
												isRealTime = @isRealTime,
												minTxnLimit = @minTxnLimit,
												maxTxnLimit = @maxTxnLimit,
												LimitCurrency = @limitCurrency,
												exRateCalByPartner  = @exRateCalcByPartner,
												isACValidateSupport = @isACValidateSupport
			WHERE id = @rowId
		END
		ELSE
		BEGIN
			INSERT INTO TblPartnerwiseCountryMod (id,CountryId, AgentId, IsActive, CreatedBy, CreatedDate, PaymentMethod,isRealTime,minTxnLimit,maxTxnLimit,LimitCurrency,exRateCalByPartner,isACValidateSupport,modType,ModifiedBy,ModifiedDate)
			SELECT @rowId,@CountryId, @agentID, @isActive, @user, GETDATE(), @PaymentMethod,@isRealTime,@minTxnLimit,@maxTxnLimit,@limitCurrency,@exRateCalcByPartner,@isACValidateSupport,'u',@user,getdate()
		END

		update TblPartnerwiseCountry set approvedDate = null, approvedby = null,ModifiedBy=@user,ModifiedDate=getdate() where id = @rowId

		SELECT '0' ErrorCode , 'Data has been edited successfully and is waiting for approval.' Msg , NULL id
	END
	ELSE IF @FLAG = 'select'
	BEGIN
		SELECT * FROM TblPartnerwiseCountry (NOLOCK) WHERE id = @rowId
	END
	ELSE IF @FLAG = 'S'
	BEGIN
		SET @sortBy = 'id'
		SET @sortOrder = 'desc'

		SET @table = '( SELECT  TP.id
								,AM.agentName
								,CM.countryName
								,[PAYOUT_METHOD] = ISNULL(SM.typeTitle, ''ALL'')
								,[IS_ACTIVE] = CASE WHEN TP.isActive = 1 THEN ''YES'' ELSE ''NO'' END
								,TP.countryId
								,TP.agentId
								,TP.PaymentMethod
								,TP.minTxnLimit
								,TP.maxTxnLimit
								,TP.LimitCurrency
								,exRateCalByPartner = CASE WHEN TP.exRateCalByPartner = 1 THEN ''YES'' ELSE ''NO'' END
								,isACValidateSupport = CASE WHEN TP.isACValidateSupport = 1 THEN ''YES'' ELSE ''NO'' END
								,isRealTime = CASE WHEN TP.isRealTime = 0 THEN ''NO'' ELSE ''YES'' END
								,hasChanged = CASE WHEN (TP.approvedBy IS NULL) THEN ''Y'' ELSE ''N'' END  
								,modifiedBy = CASE WHEN (TP.approvedBy IS NULL AND TP.modifiedBy IS NULL) THEN TP.createdBy ELSE TP.modifiedBy END  
								--,modifiedBy = CASE WHEN TP.approvedBy IS NULL THEN TP.modifiedBy ELSE AM.createdBy END  
						FROM TblPartnerwiseCountry TP(NOLOCK)
						INNER JOIN countryMaster CM(NOLOCK) ON CM.countryId = TP.CountryId
						INNER JOIN agentMaster AM(NOLOCK) ON AM.agentId = TP.AgentId
						LEFT JOIN serviceTypeMaster SM(NOLOCK) ON SM.serviceTypeId = TP.PaymentMethod '

		SET @sql_filter = ''
		SET @table = @table + ')x'
			
		IF @agentID <> 0
			SET @sql_filter = @sql_filter+' And agentId =  '''+CAST(@agentID AS VARCHAR)+''''

		IF @PaymentMethod <> 0
			SET @sql_filter = @sql_filter+' And PaymentMethod =  '''+CAST(@PaymentMethod AS VARCHAR)+''''

		IF @CountryId <> 0
			SET @sql_filter = @sql_filter+' And CountryId =  '''+CAST(@CountryId AS VARCHAR)+''''

		SET @select_field_list  = '
				 id,agentName,countryName,PAYOUT_METHOD,IS_ACTIVE,isRealTime,minTxnLimit,maxTxnLimit,LimitCurrency,exRateCalByPartner,isACValidateSupport,hasChanged,modifiedBy'
				 	
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list
				, @sortBy, @sortOrder, @pageSize, @pageNumber
	END
	ELSE IF @FLAG = 'country-list'
	BEGIN
		SELECT * FROM (
		SELECT '' [value], 'Select Country' [text]	UNION ALL

		SELECT 
			countryId [value],
			UPPER(countryName) [text]
		FROM countryMaster CM WITH (NOLOCK)
		INNER JOIN 
		(
			SELECT  receivingCountry,min(maxLimitAmt) maxLimitAmt
			FROM(
					SELECT   receivingCountry,max (maxLimitAmt) maxLimitAmt
					FROM sendTranLimit SL WITH (NOLOCK) 
					WHERE --countryId = @countryId
					--AND
					 ISNULL(isActive,'N')='Y'
					AND ISNULL(isDeleted,'N')='N'
					AND 1=1
					GROUP BY receivingCountry
              
					UNION ALL
               
					SELECT    receivingCountry,max (maxLimitAmt)maxLimitAmt
					FROM sendTranLimit SL WITH (NOLOCK) 
					WHERE 1=1
					AND ISNULL(isActive,'N')='Y'
					AND ISNULL(isDeleted,'N')='N'
					GROUP BY receivingCountry  
                 
			) x GROUP  BY receivingCountry
		) Y ON  Y.receivingCountry=CM.countryId
		WHERE ISNULL(isOperativeCountry,'') ='Y'
		AND Y.maxLimitAmt>0
		) X 
		ORDER BY X.[value] ASC
	END
	ELSE IF @FLAG = 'payout-list'
	BEGIN
		SELECT * FROM (
		SELECT '' [value], 'Select Payout Method' [text]	UNION ALL

		SELECT CAST(serviceTypeId AS VARCHAR) [value], typeTitle [text]
		FROM serviceTypeMaster (NOLOCK) 
		WHERE ISNULL(isActive, 'Y') = 'Y'
		)X
		ORDER BY X.[value] ASC
	END
	ELSE IF @FLAG = 'agent-list'
	BEGIN
		SELECT * FROM (
		SELECT '' [value], 'Select Partner' [text]	UNION ALL

		SELECT CAST(AM.AGENTID AS VARCHAR) [value], AM.AGENTNAME [text] FROM AGENTMASTER AM(NOLOCK)
		INNER JOIN (
			SELECT DISTINCT AGENTID
			FROM TblPartnerwiseCountry (NOLOCK)
		)X ON X.AGENTID = AM.AGENTID
		) X 
		ORDER BY X.[value] ASC
	END
	ELSE IF @FLAG = 'logType'
	BEGIN
		SELECT * FROM (
		SELECT '' [value], 'Select Log Type' [text]	UNION ALL
		SELECT 'sendTxn' [value], 'Send Transaction' [text]	UNION ALL
		SELECT 'exRate' [value], 'Exchange Rate' [text]	UNION ALL
		SELECT 'statusSync' [value], 'Status Sync' [text]	
		)x
	END
	ELSE IF @FLAG = 'enable-disable'
	BEGIN
		IF @isActive = 'YES'
		BEGIN
			update TblPartnerwiseCountry set  IsActive = 0 where id = @rowId

			SELECT '0' ErrorCode , 'Record has been disabled successfully.' Msg , @rowId id	 
		END
		ELSE
		BEGIN
			update TblPartnerwiseCountry set  IsActive = 1 where id = @rowId

			SELECT '0' ErrorCode , 'Record has been enabled successfully.' Msg , @rowId id	 
		END
	END
	ELSE IF @FLAG = 'payout-method'
	BEGIN
		SELECT SM.serviceTypeId, SM.typeTitle FROM countryReceivingMode CR(NOLOCK)
		INNER JOIN serviceTypeMaster SM(NOLOCK) ON SM.serviceTypeId = CR.receivingMode
		WHERE CR.countryId = @CountryId
	END
	ELSE IF @FLAG = 'partner'
	BEGIN
		SELECT agentId, agentName FROM agentMaster (NOLOCK) WHERE parentId = 0 AND agentId NOT IN (1001, 393877) 
	END
	ELSE IF @FLAG = 'payout-partner'
	BEGIN
		IF @CountryId IS NULL
			SELECT @CountryId = countryId FROM COUNTRYMASTER (NOLOCK) WHERE COUNTRYNAME = @CountryName

		IF @PaymentMethod IS NULL
		BEGIN	
			SELECT agentId,isRealTime, exRateCalByPartner, CM.COUNTRYCODE, AgentId
					, ChoosePayer = CASE WHEN AgentId IN (394130) AND @PaymentMethod = 2 THEN 'true' ELSE 'false' END
			FROM TblPartnerwiseCountry P(NOLOCK) 
			INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYID = P.COUNTRYID
			WHERE P.countryId = @CountryId 
			AND (PaymentMethod IS NULL OR PaymentMethod IS NOT NULL)
			AND P.IsActive = 1
		END
		ELSE
		BEGIN	
			SELECT agentId,isRealTime, exRateCalByPartner, CM.COUNTRYCODE, AgentId
					, ChoosePayer = CASE WHEN AgentId IN (394130) AND @PaymentMethod = 2 THEN 'true' ELSE 'false' END
			FROM TblPartnerwiseCountry P(NOLOCK) 
			INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYID = P.COUNTRYID
			WHERE P.countryId = @CountryId 
			AND ISNULL(PaymentMethod, @PaymentMethod) = @PaymentMethod
			AND P.IsActive = 1
		END
	END
	ELSE IF @FLAG = 'limit-currency'
	BEGIN
		SELECT CM.currencyCode,CM.currencyCode FROM countryCurrency CC(NOLOCK)
		INNER JOIN currencyMaster CM(NOLOCK) ON CM.currencyId = CC.currencyId
		WHERE CC.countryId=@CountryId
		AND ISNULL(CC.isActive, 'Y') = 'Y'
	END
	ELSE IF @FLAG = 'approve'
	BEGIN
		DECLARE @exRateCalByPartner BIT

		  INSERT INTO TblPartnerwiseCountryHistory(partnerWiseCountryRowId, CountryId, AgentId, IsActive, PaymentMethod, ModifiedBy, ModifiedDate,isRealTime,minTxnLimit,maxTxnLimit,LimitCurrency,exRateCalByPartner)
		  SELECT @id, CountryId, AgentId, IsActive, PaymentMethod, @user, GETDATE(),isRealTime,minTxnLimit,maxTxnLimit,LimitCurrency,exRateCalByPartner FROM TblPartnerwiseCountry (NOLOCK) WHERE id = @id

		  IF EXISTs(select 1 from TblPartnerwiseCountryMod where id = @id)
		  BEGIN
			select	     @CountryId = CountryId
						,@IsActive  = IsActive 
						,@PaymentMethod  = PaymentMethod 
						,@AgentId  = AgentId 
						,@isRealTime  = isRealTime 
						,@minTxnLimit = minTxnLimit
						,@maxTxnLimit  = maxTxnLimit 
						,@LimitCurrency  = LimitCurrency 
						,@exRateCalByPartner = exRateCalByPartner
						,@isACValidateSupport =isACValidateSupport
			from TblPartnerwiseCountryMod where id = @id

			UPDATE TblPartnerwiseCountry SET CountryId = @CountryId, 
												IsActive = @isActive, 
												PaymentMethod = @PaymentMethod,
												AgentId = @agentID,
												isRealTime = @isRealTime,
												minTxnLimit = @minTxnLimit,
												maxTxnLimit = @maxTxnLimit,
												LimitCurrency = @limitCurrency,
												exRateCalByPartner  = @exRateCalByPartner,
												isACValidateSupport =@isACValidateSupport,
												approvedBy = @user,  
												approvedDate = GETDATE()  
									where  id = @id

			DELETE FROM TblPartnerwiseCountryMod  where id = @id
		  END
		  ELSE
		  BEGIN
		  UPDATE TblPartnerwiseCountry SET 		approvedBy = @user,  
												approvedDate = GETDATE()  
									where  id = @id
		  END
		
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @user  
    
	END
	ELSE IF @FLAG = 'reject'
	BEGIN
		DELETE FROM TblPartnerwiseCountryMod  where id = @id  

		update TblPartnerwiseCountry set approveddate= getdate(),approvedby = @user where id = @id  

		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @user  
	END
	ELSE IF @FLAG = 'logType'
	BEGIN
		SELECT * FROM (
		SELECT '' [value], 'Select Log Type' [text]	UNION ALL
		SELECT 'sendTxn' [value], 'Send Transaction' [text]	UNION ALL
		SELECT 'exRate' [value], 'Exchange Rate' [text]	UNION ALL
		SELECT 'statusSync' [value], 'Status Sync' [text]	
		)x
	END
END

GO

