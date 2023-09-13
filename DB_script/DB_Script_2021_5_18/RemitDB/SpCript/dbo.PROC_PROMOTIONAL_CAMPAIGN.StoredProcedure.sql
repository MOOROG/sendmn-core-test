USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_PROMOTIONAL_CAMPAIGN]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PROC_PROMOTIONAL_CAMPAIGN]
(
	@FLAG				VARCHAR(20)
	--grid parameters
	,@user				VARCHAR(50)		= NULL
	,@pageSize			VARCHAR(50)		= NULL
	,@pageNumber		VARCHAR(50)		= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(50)		= NULL
	,@PROMOTIONAL_CODE	VARCHAR(20)		= NULL
	,@PROMOTIONAL_MSG	VARCHAR(250)	= NULL	
	,@PROMOTION_TYPE	INT				= NULL	
	,@COUNTRY_ID		INT				= NULL	
	,@PAYMENT_METHOD	INT				= NULL
	,@ROW_ID			INT				= NULL
	,@IS_ACTIVE			BIT				= NULL 
	,@START_DT			VARCHAR(20)		= NULL 
	,@END_DT			VARCHAR(20)		= NULL 
	,@PROMOTION_VALUE	MONEY			= NULL
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
		IF EXISTS (SELECT 1 FROM TBL_PROMOTIONAL_CAMAPAIGN (NOLOCK) 
					WHERE COUNTRY_ID = @COUNTRY_ID 
					AND ISNULL(PAYMENT_METHOD, 0) = ISNULL(@PAYMENT_METHOD, 0) 
					AND IS_ACTIVE = 1)
		BEGIN 
			SELECT '0' ErrorCode , 'Record already exists, please use existing record or disable it first.' Msg , NULL id	 
			RETURN
		END
		IF EXISTS (SELECT 1 FROM TBL_PROMOTIONAL_CAMAPAIGN (NOLOCK) 
					WHERE COUNTRY_ID = @COUNTRY_ID 
					AND ISNULL(PAYMENT_METHOD, @PAYMENT_METHOD) = @PAYMENT_METHOD 
					AND IS_ACTIVE = 1)
		BEGIN 
			SELECT '0' ErrorCode , 'Record already exists for all payment methods, please use existing record.' Msg , NULL id	 
			RETURN
		END

		INSERT INTO TBL_PROMOTIONAL_CAMAPAIGN (PROMOTIONAL_CODE, PROMOTIONAL_MSG, PROMOTION_TYPE, COUNTRY_ID, PAYMENT_METHOD, IS_ACTIVE
													, createdBy, createdDate, START_DT, END_DT, PROMOTION_VALUE)
		SELECT @PROMOTIONAL_CODE, @PROMOTIONAL_MSG, @PROMOTION_TYPE, @COUNTRY_ID, @PAYMENT_METHOD, @IS_ACTIVE
													, @USER, GETDATE(), @START_DT, @END_DT, @PROMOTION_VALUE

		SELECT '0' ErrorCode , 'Record has been added successfully.' Msg , NULL id
	END
	IF @FLAG = 'u'
	BEGIN
		--INSERT INTO TblPartnerwiseCountryHistory (partnerWiseCountryRowId, CountryId, AgentId, IsActive, PaymentMethod, ModifiedBy, ModifiedDate,isRealTime,minTxnLimit,maxTxnLimit,LimitCurrency,exRateCalByPartner)
		--SELECT @rowId, CountryId, AgentId, IsActive, PaymentMethod, @user, GETDATE(),isRealTime,minTxnLimit,maxTxnLimit,LimitCurrency,exRateCalByPartner FROM TblPartnerwiseCountry (NOLOCK) WHERE id = @rowId
		IF exists(SELECT 1 FROM TBL_PROMOTIONAL_CAMAPAIGN_MOD WHERE ROW_ID = @ROW_ID )
		BEGIN
			UPDATE TBL_PROMOTIONAL_CAMAPAIGN_MOD SET PROMOTIONAL_CODE = @PROMOTIONAL_CODE, 
												PROMOTIONAL_MSG = @PROMOTIONAL_MSG, 
												PROMOTION_TYPE = @PROMOTION_TYPE, 
												COUNTRY_ID = @COUNTRY_ID, 
												PAYMENT_METHOD = @PAYMENT_METHOD,
												IS_ACTIVE = @IS_ACTIVE,
												modifiedBy = @USER,
												modifiedDate = GETDATE(),
												START_DT = @START_DT,
												PROMOTION_VALUE = @PROMOTION_VALUE,
												END_DT = @END_DT
			WHERE ROW_ID = @ROW_ID
		END
		ELSE
		BEGIN
			INSERT INTO TBL_PROMOTIONAL_CAMAPAIGN_MOD (ROW_ID, PROMOTIONAL_CODE, PROMOTIONAL_MSG, PROMOTION_TYPE, COUNTRY_ID, PAYMENT_METHOD, IS_ACTIVE
													, modifiedBy, modifiedDate, START_DT, END_DT, PROMOTION_VALUE, modType)
			SELECT @ROW_ID, @PROMOTIONAL_CODE, @PROMOTIONAL_MSG, @PROMOTION_TYPE, @COUNTRY_ID, @PAYMENT_METHOD, @IS_ACTIVE, @USER, GETDATE(), @START_DT, @END_DT, @PROMOTION_VALUE, 'U'
		END

		UPDATE TBL_PROMOTIONAL_CAMAPAIGN set approvedDate = null, approvedBy = null,modifiedBy=@user,modifiedDate=GETDATE() 
		WHERE ROW_ID = @ROW_ID

		SELECT '0' ErrorCode , 'Data has been edited successfully and is waiting for approval.' Msg , NULL id
	END
	ELSE IF @FLAG = 'select'
	BEGIN
		SELECT *, START_DATE = CONVERT(VARCHAR(10), START_DT, 121), END_DATE = CONVERT(VARCHAR(10), END_DT, 121) 
		FROM TBL_PROMOTIONAL_CAMAPAIGN (NOLOCK) WHERE ROW_ID = @ROW_ID
	END
	ELSE IF @FLAG = 'S'
	BEGIN
		SET @sortBy = 'ROW_ID'
		SET @sortOrder = 'desc'
		
		SET @table = '( SELECT  TP.ROW_ID
								,PROMOTION_TYPE = S.detailTitle
								,[PAYOUT_METHOD] = ISNULL(SM.typeTitle, ''ALL'')
								,TP.PROMOTIONAL_CODE
								,TP.PROMOTIONAL_MSG
								,TP.START_DT
								,TP.END_DT
								,TP.PROMOTION_VALUE
								,CM.COUNTRYNAME
								,TP.COUNTRY_ID
								,IS_ACTIVE = CASE WHEN TP.IS_ACTIVE = 0 THEN ''NO'' ELSE ''YES'' END
								,hasChanged = CASE WHEN (TP.approvedBy IS NULL) THEN ''Y'' ELSE ''N'' END  
								,modifiedBy = CASE WHEN TP.approvedBy IS NULL AND TP.modifiedBy IS NULL THEN TP.createdBy ELSE TP.modifiedBy END  
						FROM TBL_PROMOTIONAL_CAMAPAIGN TP(NOLOCK)
						INNER JOIN countryMaster CM(NOLOCK) ON CM.countryId = TP.COUNTRY_ID
						INNER JOIN STATICDATAVALUE S(NOLOCK) ON S.VALUEID = TP.PROMOTION_TYPE
						LEFT JOIN serviceTypeMaster SM(NOLOCK) ON SM.serviceTypeId = TP.PAYMENT_METHOD '

		SET @sql_filter = ''
		SET @table = @table + ')x'
			
		IF @COUNTRY_ID <> 0
			SET @sql_filter = @sql_filter+' And COUNTRY_ID =  '''+CAST(@COUNTRY_ID AS VARCHAR)+''''

		SET @select_field_list  = '
				 ROW_ID,PROMOTION_TYPE,PAYOUT_METHOD,PROMOTION_VALUE,PROMOTIONAL_CODE,PROMOTIONAL_MSG,START_DT,END_DT,COUNTRYNAME,IS_ACTIVE,hasChanged,modifiedBy'
				 	
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list
				, @sortBy, @sortOrder, @pageSize, @pageNumber
	END
	ELSE IF @FLAG = 'enable-disable'
	BEGIN
		IF @IS_ACTIVE = 'YES'
		BEGIN
			update TBL_PROMOTIONAL_CAMAPAIGN set  IS_ACTIVE = 0 where ROW_ID = @ROW_ID

			SELECT '0' ErrorCode , 'Record has been disabled successfully.' Msg , @ROW_ID id	 
		END
		ELSE
		BEGIN
			update TBL_PROMOTIONAL_CAMAPAIGN set  IS_ACTIVE = 1 where ROW_ID = @ROW_ID

			SELECT '0' ErrorCode , 'Record has been enabled successfully.' Msg , @ROW_ID id	 
		END
	END
	ELSE IF @FLAG = 'approve'
	BEGIN
		INSERT INTO TBL_PROMOTIONAL_CAMAPAIGNHISTORY (ROW_ID, PROMOTIONAL_CODE, PROMOTIONAL_MSG, PROMOTION_TYPE, COUNTRY_ID, PAYMENT_METHOD, IS_ACTIVE
													, modifiedBy, modifiedDate, START_DT, END_DT, PROMOTION_VALUE)
		SELECT @ROW_ID, @PROMOTIONAL_CODE, @PROMOTIONAL_MSG, @PROMOTION_TYPE, @COUNTRY_ID, @PAYMENT_METHOD, @IS_ACTIVE, @USER, GETDATE(), @START_DT, @END_DT, @PROMOTION_VALUE


		IF EXISTS(SELECT 1 FROM TBL_PROMOTIONAL_CAMAPAIGN_MOD (NOLOCK) WHERE ROW_ID = @ROW_ID)
		BEGIN
			select	     @PROMOTIONAL_CODE = PROMOTIONAL_CODE
						,@PROMOTIONAL_MSG  = PROMOTIONAL_MSG 
						,@PROMOTION_TYPE  = PROMOTION_TYPE 
						,@START_DT  = START_DT 
						,@END_DT  = END_DT 
						,@COUNTRY_ID = COUNTRY_ID
						,@PAYMENT_METHOD  = PAYMENT_METHOD 
						,@IS_ACTIVE  = IS_ACTIVE 
						,@PROMOTION_VALUE = PROMOTION_VALUE
			from TBL_PROMOTIONAL_CAMAPAIGN_MOD (NOLOCK) 
			WHERE ROW_ID = @ROW_ID


			UPDATE TBL_PROMOTIONAL_CAMAPAIGN SET PROMOTIONAL_CODE = @PROMOTIONAL_CODE, 
												PROMOTIONAL_MSG = @PROMOTIONAL_MSG, 
												PROMOTION_TYPE = @PROMOTION_TYPE,
												START_DT = @START_DT,
												END_DT = @END_DT,
												COUNTRY_ID = @COUNTRY_ID,
												PAYMENT_METHOD = @PAYMENT_METHOD,
												IS_ACTIVE = @IS_ACTIVE,
												approvedBy = @user,  
												approvedDate = GETDATE() ,
												PROMOTION_VALUE = @PROMOTION_VALUE 
			where  ROW_ID = @ROW_ID

			DELETE FROM TBL_PROMOTIONAL_CAMAPAIGN_MOD  where ROW_ID = @ROW_ID
		  END
		  ELSE
		  BEGIN
			  UPDATE TBL_PROMOTIONAL_CAMAPAIGN SET 		approvedBy = @user,  
													approvedDate = GETDATE()  
										where  ROW_ID = @ROW_ID
		  END
		
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @user  
    
	END
	ELSE IF @FLAG = 'reject'
	BEGIN
		IF EXISTS(SELECT * FROM TBL_PROMOTIONAL_CAMAPAIGN_MOD (NOLOCK) WHERE ROW_ID = @ROW_ID)
		BEGIN
			DELETE FROM TBL_PROMOTIONAL_CAMAPAIGN_MOD  where ROW_ID = @ROW_ID

			UPDATE TBL_PROMOTIONAL_CAMAPAIGN set approvedDate= GETDATE(),approvedBy = @user WHERE ROW_ID = @ROW_ID
		END
		ELSE
		BEGIN
			INSERT INTO TBL_PROMOTIONAL_CAMAPAIGNHISTORY (ROW_ID, PROMOTIONAL_CODE, PROMOTIONAL_MSG, PROMOTION_TYPE, COUNTRY_ID, PAYMENT_METHOD, IS_ACTIVE
													, createdBy, createdDate, START_DT, END_DT, PROMOTION_VALUE)
			SELECT @ROW_ID, @PROMOTIONAL_CODE, @PROMOTIONAL_MSG, @PROMOTION_TYPE, @COUNTRY_ID, @PAYMENT_METHOD, @IS_ACTIVE, @USER, GETDATE(), @START_DT, @END_DT, @PROMOTION_VALUE

			DELETE FROM TBL_PROMOTIONAL_CAMAPAIGN WHERE ROW_ID = @ROW_ID
		END

		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @user  
	END
END	
GO
