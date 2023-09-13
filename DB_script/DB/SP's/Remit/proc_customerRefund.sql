SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER  PROCEDURE [dbo].[proc_customerRefund]
	 @flag VARCHAR(50)
	,@user VARCHAR(30) 
	,@customerId VARCHAR(15)				= NULL
	,@refundAmount VARCHAR(25)				= NULL
	,@refundCharge VARCHAR(25)				= NULL 
	,@refundRemarks VARCHAR(300)			= NULL 
	,@redfundChargeRemarks VARCHAR(300)		= NULL 
	,@pageSize INT							= NULL
	,@pageNumber	INT						= NULL
	,@sortBy VARCHAR(50)					 = NULL
	,@sortOrder	VARCHAR(5)					 = NULL
	,@rowId varchar(20)						= NULL
	,@approvedOrNot varchar(2)				=NULL 
	,@countryId VARCHAR(20)					=NULL 
	,@agentId VARCHAR(20)					=NULL 
	,@collMode VARCHAR(20)					=NULL 
	,@bankId VARCHAR(25)					=Null
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY

        CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE @errorMessage VARCHAR(MAX),
	   @sql    VARCHAR(MAX)  
	  ,@table    VARCHAR(MAX)  
	  ,@select_field_list VARCHAR(MAX)  
	  ,@extra_field_list VARCHAR(MAX)  
	  ,@sql_filter  VARCHAR(MAX)  
	  ,@modType			VARCHAR(6)
	IF @flag = 'i'
		BEGIN
			DECLARE @AVAILABLE_BALANCE MONEY
			SELECT @AVAILABLE_BALANCE = DBO.FNAGetCustomerAvailableBalance(@customerId) 

			IF ISNULL(@AVAILABLE_BALANCE, 0) < (CAST(@refundAmount AS MONEY) + CAST(ISNULL(@refundCharge, 0) AS MONEY))
			BEGIN
				EXEC dbo.proc_errorHandler 1, 'Insufficient balance!', NULL 
				RETURN
			END

			INSERT INTO CUSTOMER_REFUND (customerId,refundAmount,refundCharge,refundRemarks,refundChargeRemarks,createdBy,createdDate,collMode,bankId)
			VALUES (@customerId,@refundAmount,@refundCharge,@refundRemarks,@redfundChargeRemarks,@user,GETDATE(),@collMode,@bankId);

			EXEC dbo.proc_errorHandler '0', 'Customer Refund saved successfully', NULL 
			RETURN
		END
	IF @flag = 's'
	BEGIN	
		IF @sortBy IS NULL
		   SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'DESC'
		 SET @table = '(
							SELECT CM.fullName
							,CM.mobile
							,refundAmount
							,refundCharge
							,refundRemarks
							,CR.approvedBy
							,refundChargeRemarks
							,CR.createdDate
							,CR.rowId
							,hasChanged = CASE WHEN (CR.approvedBy IS NULL) THEN ''Y'' ELSE ''N'' END
							,modifiedBy = CASE WHEN CR.approvedBy IS NULL THEN CR.createdBy ELSE CM.createdBy END
					FROM CUSTOMER_REFUND CR (NOLOCK)
					INNER JOIN dbo.customerMaster CM (NOLOCK) ON CM.customerId = CR.customerId
					WHERE ISNULL(CR.isDeleted, 0) = 0
				)x'
	
		SET @sql_filter = ''
		
		IF @approvedOrNot='Y'
		BEGIN
			SET @sql_Filter=@sql_Filter + ' AND approvedBy IS NOT NULL '
		END
		ELSE IF @approvedOrNot='N'
		BEGIN
			SET @sql_Filter=@sql_Filter + ' AND approvedBy IS NULL '
		END	
		
		SET @select_field_list ='fullName,mobile,refundAmount,refundCharge,refundRemarks,
									refundChargeRemarks,createdDate,rowId,hasChanged,modifiedBy'
		EXEC dbo.proc_paging
                @table
               ,@sql_filter
               ,@select_field_list
               ,@extra_field_list
               ,@sortBy
               ,@sortOrder
               ,@pageSize
               ,@pageNumber
			
	END
	IF @flag = 'd'
	BEGIN	
		UPDATE CUSTOMER_REFUND SET isDeleted = 1, deletedBy = @user, deletedDate = GETDATE() 
		WHERE rowId = @rowId
		
		--DELETE FROM dbo.TBL_CUSTOMER_KYC WHERE rowId = @rowId
		EXEC dbo.proc_errorHandler '0', 'Customer Refund deleted successfully', NULL 
		RETURN
	END
	IF @flag = 'approve'
	BEGIN
		BEGIN TRAN
			IF EXISTS(SELECT TOP 1 'A' FROM dbo.CUSTOMER_REFUND (NOLOCK) WHERE rowId = @rowId AND approvedDate IS NOT NULL)
			BEGIN
				EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @user
				RETURN
			END
			DECLARE @REFUNDAMOUNTTOTAL MONEY

			SELECT @customerId = customerId, @REFUNDAMOUNTTOTAL = refundAmount + ISNULL(refundCharge, 0)
			FROM CUSTOMER_REFUND (NOLOCK)
			WHERE ROWID = @ROWID
		
			SELECT @AVAILABLE_BALANCE = DBO.FNAGetCustomerAvailableBalance_Refund(@customerId) 

		
			IF ISNULL(@AVAILABLE_BALANCE, 0) < @REFUNDAMOUNTTOTAL
			BEGIN
				EXEC dbo.proc_errorHandler 1, 'Insufficient balance!', NULL 
				RETURN
			END
		
			SELECT @refundAmount = refundAmount,@refundCharge = refundCharge FROM CUSTOMER_REFUND (NOLOCK)
			WHERE ROWID = @rowId

			UPDATE dbo.CUSTOMER_REFUND 
			SET approvedBy = @user,
				approvedDate = GETDATE()
			WHERE rowId=@rowId

			--INSERT INTO TRANSACTION TABLE\
			INSERT INTO CUSTOMER_TRANSACTIONS (customerId, tranDate, particulars, deposit, withdraw, refereceId, head, createdBy, createdDate, bankId)
			SELECT	customerId, GETDATE(), 'Customer Refund', 0, refundAmount, ROWID, 'Customer Refund', @user, GETDATE(), null
			FROM CUSTOMER_REFUND
			WHERE ROWID = @rowId
		
			UPDATE CUSTOMERMASTER SET AVAILABLEBALANCE = AVAILABLEBALANCE - ISNULL(@refundAmount, 0) - ISNULL(@refundCharge,0)
			WHERE CUSTOMERID = @customerId

			EXEC proc_errorHandler 0, 'Changes approved successfully.', @user
			
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION

		EXEC SendMnPro_Account.dbo.PROC_DEPOSIT_REFUND_VOUCHER_ENTRY @flag = 'W', @user = @user, @rowId = @rowId
	END
	IF @flag = 'reject'
	BEGIN
	DECLARE	 @logIdentifier		VARCHAR(100)
			,@logParamMain		VARCHAR(100)
			,@tableAlias		VARCHAR(100)
			,@oldValue			VARCHAR(MAX)
     SELECT
		 @logIdentifier = 'rowId'
		,@logParamMain = 'customerRefund'
		,@tableAlias = 'Customer Refund'
		IF EXISTS(SELECT TOP 1 'A' FROM dbo.CUSTOMER_REFUND (NOLOCK) WHERE rowId = @rowId AND approvedDate IS NOT NULL)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @user
			RETURN
		END
		
		IF EXISTS (SELECT 'X' FROM dbo.CUSTOMER_REFUND WHERE rowId = @rowId AND approvedDate IS NULL)
		BEGIN --New record
			BEGIN TRANSACTION
				UPDATE dbo.CUSTOMER_REFUND SET isDeleted = 1 where rowId = @rowId			
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @rowId
	END
	IF @flag = 'customerdetail'
	BEGIN
		SELECT  firstName ,
			[address]=cm.address,
			mobile ,
			fullName,
			nativeCoun.countryName nativeCountry,
			sv.detailTitle idType,
			cm.idNumber,
			AvailableBalance = ISNULL(DBO.FNAGetCustomerAvailableBalance(customerId), 0)
		FROM    dbo.customerMaster cm (NOLOCK)
		LEFT JOIN dbo.countryStateMaster csm (NOLOCK) ON csm.stateId=cm.state
		INNER JOIN dbo.countryMaster country (NOLOCK) ON country.countryId =cm.country
		INNER JOIN dbo.countryMaster nativeCoun (NOLOCK) ON nativeCoun.countryId =cm.nativeCountry
		INNER JOIN dbo.staticDataValue sv(NOLOCK) ON sv.valueId=cm.idType
		WHERE   customerId = @customerId;
		RETURN;
	END;
	IF @Flag='dropdownListApprovedUnapproved'
	BEGIN
		SELECT 'All' [text],'' [value]
		UNION ALL
		SELECT 'Approved' [text],'Y' [value]
		UNION ALL
        SELECT 'Unapproved' ,'N'  
		RETURN
	END
	IF @flag = 'collMode'
	BEGIN
		SELECT SD.detailTitle, CC.COLLMODE, ISDEFAULT = 0 INTO #TEMP
		FROM countryCollectionMode CC(NOLOCK) 
		INNER JOIN staticDataValue SD(NOLOCK) ON SD.VALUEID = CC.COLLMODE
		WHERE ISNULL(SD.isActive, 'Y') = 'Y'
		AND ISNULL(SD.IS_DELETE, 'N') = 'N'
		AND CC.countryId = 113

		UPDATE #TEMP SET ISDEFAULT = 1 WHERE collMode = 11062

		SELECT * FROM #TEMP
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     SET @errorMessage = ERROR_MESSAGE() 
	 EXEC dbo.proc_errorHandler 1, @errorMessage, NULL
END CATCH
GO