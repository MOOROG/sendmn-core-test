USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_KFTC_APPROVE_REJECT]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC [PROC_KFTC_APPROVE_REJECT] @flag = 'S'   ,@pageNumber='1', @pageSize='10', @sortBy='CUSTOMERID', @sortOrder='ASC', @user = 'admin'

CREATE PROC [dbo].[PROC_KFTC_APPROVE_REJECT]
(
	@FLAG						VARCHAR(50)		= NULL
	,@user						VARCHAR(50)		= NULL
	,@email						VARCHAR(100)	= NULL
	,@idNumber					VARCHAR(30)		= NULL
	,@type						VARCHAR(20)		= NULL
	,@customerId				BIGINT			= NULL
	--grid parameters
	,@pageSize					VARCHAR(50)		= NULL
	,@pageNumber				VARCHAR(50)		= NULL
	,@sortBy					VARCHAR(50)		= NULL
	,@sortOrder					VARCHAR(50)		= NULL
	,@virtualAccountNo			VARCHAR(50)		= NULL
	,@primaryAccountNo			VARCHAR(50)		= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE  @table				VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)

	IF @FLAG = 'S'
	BEGIN
		SET @sortBy = 'CUSTOMERID'
		SET @sortOrder = 'desc'

		SET @table ='(
			SELECT CM.CUSTOMERID,cm.firstName, K.userName, C.COUNTRYNAME, CM.IDNUMBER, CM.EMAIL
			FROM customerMaster cm(NOLOCK)
			INNER JOIN COUNTRYMASTER C(NOLOCK) ON C.COUNTRYID = CM.NATIVECOUNTRY
			INNER JOIN KFTC_CUSTOMER_MASTER K(NOLOCK) ON K.customerId = CM.customerId
			WHERE cm.approvedDate IS NOT NULL AND K.ApprovedDate IS NULL)X'

			SET @sql_filter = ''

			IF ISNULL(@email,'') <> ''
				SET @sql_Filter = @sql_Filter + ' AND email = ''' +@email+''''

			IF ISNULL(@idNumber, '') <> ''
				SET @sql_Filter = @sql_Filter + ' AND REPLACE(idNumber, ''-'', '''') = ''' +REPLACE(@idNumber, '-', '')+''''
			
			SET @select_field_list ='
				 firstName,userName,email,COUNTRYNAME,IDNUMBER,CUSTOMERID
				'	
			EXEC dbo.proc_paging
					@table,@sql_filter,@select_field_list,@extra_field_list
					,@sortBy,@sortOrder,@pageSize,@pageNumber
	END
	ELSE IF @FLAG = 'approve-reject'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM customerMaster (NOLOCK) WHERE customerId = @customerId AND approvedDate IS NOT NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid account details!', null
			RETURN
		END

		IF @type = 'approve'
		BEGIN
			UPDATE KFTC_CUSTOMER_MASTER SET ApprovedBy = @user, ApprovedDate = GETDATE() WHERE customerId = @customerId

			EXEC proc_errorHandler 0, 'Customer auto debit account approved successfylly!', null
		END
		ELSE IF @type = 'reject'
		BEGIN
			DECLARE @ROWID BIGINT
			--UPDATE KFTC_CUSTOMER_MASTER SET RejectedBy = @user, RejectedDate = GETDATE(), 
			--								userName = NULL, userInfo = NULL, userGender = NULL, 
			--								userCellNo = NULL, userEmail = NULL 
			--WHERE customerId = @customerId

			EXEC proc_errorHandler 0, 'Customer auto debit account rejected successfylly!', null

			SELECT M.accessToken access_token, S.fintechUseNo fintech_use_num, M.customerId 
			FROM KFTC_CUSTOMER_MASTER M(NOLOCK)
			INNER JOIN KFTC_CUSTOMER_SUB S(NOLOCK) ON S.customerId = M.customerId
			WHERE M.customerId = @customerId

			INSERT INTO KFTC_CUSTOMER_MASTER_DELETED(customerId, userSeqNo, accessToken, tokenType, expiresIn, accessTokenRegTime, accessTokenExpTime, refreshToken, scope, userCi, userName, userInfo,
														userGender, userCellNo, userEmail, RejectedBy, RejectedDate, RejectNote)

			SELECT customerId, userSeqNo, accessToken, tokenType, expiresIn, accessTokenRegTime, accessTokenExpTime, refreshToken, scope, userCi, userName, userInfo,
														userGender, userCellNo, userEmail, @user, GETDATE(), 'Rejected by user: ' + @user
			FROM KFTC_CUSTOMER_MASTER (NOLOCK) WHERE customerId = @customerId

			SET @ROWID = @@IDENTITY



			INSERT INTO KFTC_CUSTOMER_SUB_DELETED(masterId, customerId, userSeqNo, fintechUseNo, accountAlias, bankCodeStd, bankName, accountNum, accountNumMasked, accountName, accountType, inquiryAgreeYn, 
													transferAgreeYn, accountState, inquiryAgreeDtime, transferAgreeDtime, RejectedBy, RejectedDate, RejectNote)

			SELECT @ROWID, customerId, userSeqNo, fintechUseNo, accountAlias, bankCodeStd, bankName, accountNum, accountNumMasked, accountName, accountType, inquiryAgreeYn, 
													transferAgreeYn, accountState, inquiryAgreeDtime, transferAgreeDtime, @user, GETDATE(), 'Rejected by user: ' + @user
			FROM KFTC_CUSTOMER_SUB (NOLOCK) WHERE customerId = @customerId

			
			DELETE FROM KFTC_CUSTOMER_MASTER WHERE customerId = @customerId
			DELETE FROM KFTC_CUSTOMER_SUB WHERE customerId = @customerId
		END
	END
	ELSE IF @FLAG='ApprovedList'
	BEGIN
		SET @sortBy = 'CUSTOMERID'
		SET @sortOrder = 'desc'

		SET @table ='(
			SELECT CM.CUSTOMERID,cm.firstName, K.userName, C.COUNTRYNAME, CM.IDNUMBER, CM.EMAIL,K.ApprovedDate
			FROM customerMaster cm(NOLOCK)
			INNER JOIN COUNTRYMASTER C(NOLOCK) ON C.COUNTRYID = CM.NATIVECOUNTRY
			INNER JOIN KFTC_CUSTOMER_MASTER K(NOLOCK) ON K.customerId = CM.customerId
			WHERE cm.approvedDate IS NOT NULL AND K.ApprovedDate IS NOT NULL)X'

			SET @sql_filter = ''

			IF ISNULL(@email,'') <> ''
				SET @sql_Filter = @sql_Filter + ' AND email = ''' +@email+''''

			IF ISNULL(@idNumber, '') <> ''
				SET @sql_Filter = @sql_Filter + ' AND REPLACE(idNumber, ''-'', '''') = ''' +REPLACE(@idNumber, '-', '')+''''
			
			SET @select_field_list ='
				 firstName,userName,email,COUNTRYNAME,IDNUMBER,CUSTOMERID,ApprovedDate
				'	
			EXEC dbo.proc_paging
					@table,@sql_filter,@select_field_list,@extra_field_list
					,@sortBy,@sortOrder,@pageSize,@pageNumber
	END
END


GO
