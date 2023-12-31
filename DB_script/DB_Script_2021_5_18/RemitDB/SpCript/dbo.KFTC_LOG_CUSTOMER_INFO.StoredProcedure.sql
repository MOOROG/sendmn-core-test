USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[KFTC_LOG_CUSTOMER_INFO]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[KFTC_LOG_CUSTOMER_INFO]
(
	@flag					VARCHAR(20)
	,@customerId			BIGINT			= NULL
	,@accessToken			VARCHAR(50) 	= NULL
	,@tokenType				VARCHAR(10) 	= NULL
	,@expiresIn				INT				= NULL
	,@refreshToken			VARCHAR(50)		= NULL
	,@scope					VARCHAR(30)		= NULL
	,@userName				NVARCHAR(100)	= NULL
	,@userInfo				VARCHAR(8)		= NULL
	,@userGender			CHAR(1)			= NULL
	,@userCellNo			VARCHAR(15)		= NULL
	,@userEmail				VARCHAR(100)	= NULL
	,@XML					XML				= NULL
	,@userCi				VARCHAR(4000)	= NULL
	,@fintechUseNo			VARCHAR(30)		= NULL
	,@userSeqNo				VARCHAR(10)		= NULL   
	,@apiTranDtm			VARCHAR(17)		= NULL    
	,@rspCode				VARCHAR(5)		= NULL    
	,@rspMessage			VARCHAR(10)		= NULL
	,@dpsBankCodeStd		VARCHAR(3)		= NULL   
	,@dpsAccountNumMasked	VARCHAR(20)		= NULL
	,@dpsPrintContent		NVARCHAR(20)    = NULL
	,@bankTranId			VARCHAR(20)		= NULL   
	,@bankTranDate			VARCHAR(8)		= NULL   
	,@bankCodeTran			VARCHAR(3)		= NULL   
	,@bankRspCode			VARCHAR(3)		= NULL    
	,@bankCodeStd			VARCHAR(3)		= NULL    
	,@accountNumMasked		VARCHAR(20)		= NULL
	,@printContent			NVARCHAR(20)	= NULL  
	,@accountName			NVARCHAR(20)	= NULL 
	,@tranAmt				VARCHAR(15)		= NULL		
	,@apiTranId				VARCHAR(20)		= NULL
	,@clientId				VARCHAR(50)		= NULL
	,@clientSecret			VARCHAR(50)		= NULL
	,@clientUseCode			VARCHAR(10)		= NULL
	,@rowId					BIGINT			= NULL
	,@errorCode				VARCHAR(10)		= NULL
	,@errorMsg				VARCHAR(500)	= NULL
	,@remittance_check		CHAR(1)			= NULL
	,@kftcLogId				BIGINT			= NULL
	,@accountNumber			VARCHAR(20)		= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN
		IF @flag = 'I'
		BEGIN
			DECLARE @accessTokenExpTime DATETIME, @msg VARCHAR(100)
			SET @accessTokenExpTime = DATEADD(SECOND, @expiresIn, GETDATE())

			IF EXISTS(SELECT 1 FROM KFTC_CUSTOMER_MASTER (NOLOCK) WHERE customerId = @customerId)
			BEGIN
				UPDATE KFTC_CUSTOMER_MASTER SET
						userSeqNo = @userSeqNo
						,accessToken = @accessToken
						,tokenType = @tokenType
						,expiresIn = @expiresIn
						,accessTokenRegTime = GETDATE()
						,accessTokenExpTime = @accessTokenExpTime
						,refreshToken = @refreshToken
						,scope = @scope
						,userCi = @userCi
						,userName = @userName
						,userInfo = @userInfo
						,userGender = @userGender
						,userCellNo = @userCellNo
						,userEmail = @userEmail
				WHERE customerId = @customerId

				SET @msg = 'Auto debit account refreshed successfully!'
			END 
			ELSE
			BEGIN
				DECLARE @accHolderInfoType VARCHAR(10), @accHolderInfo VARCHAR(30), @firstName VARCHAR(100)
				SELECT	@accHolderInfoType = idType, @accHolderInfo = idNumber, @firstName = firstName
				FROM CUSTOMERMASTER(NOLOCK)
				WHERE customerId = @customerId

				IF ( REPLACE(@firstName, ' ', '') = REPLACE(@userName, ' ', '') )
				BEGIN 
					INSERT INTO KFTC_CUSTOMER_MASTER (customerId, userSeqNo, accessToken, tokenType, expiresIn, accessTokenRegTime, accessTokenExpTime, refreshToken, scope, userCi
										,userName, userInfo, userGender, userCellNo, userEmail, approvedBy, approvedDate, accHolderInfoType, accHolderInfo)
				
					SELECT @customerId, @userSeqNo, @accessToken, @tokenType, @expiresIn, GETDATE(), @accessTokenExpTime, @refreshToken, @scope, @userCi
										,@userName, @userInfo, @userGender, @userCellNo, @userEmail, 'system', GETDATE(), @accHolderInfoType, @accHolderInfo
				END				
				ELSE
				BEGIN
					INSERT INTO KFTC_CUSTOMER_MASTER (customerId, userSeqNo, accessToken, tokenType, expiresIn, accessTokenRegTime, accessTokenExpTime, refreshToken, scope, userCi
										,userName, userInfo, userGender, userCellNo, userEmail, approvedBy, approvedDate, accHolderInfoType, accHolderInfo)
				
					SELECT @customerId, @userSeqNo, @accessToken, @tokenType, @expiresIn, GETDATE(), @accessTokenExpTime, @refreshToken, @scope, @userCi
										,@userName, @userInfo, @userGender, @userCellNo, @userEmail, null, null, @accHolderInfoType, @accHolderInfo
				END
				
				SET @msg = 'Auto debit account added successfully!'
			END
			
			--PARSING XML DATA
			DECLARE @hDoc AS INT, @SQL NVARCHAR (MAX)

			EXEC sp_xml_preparedocument @hDoc OUTPUT, @XML

			DECLARE @TEMPTABLE TABLE (fintechUseNo VARCHAR(30), accountAlias NVARCHAR(50), bankCodeStd VARCHAR(3), bankName NVARCHAR(20), accountNumMasked VARCHAR(20), accountState CHAR(2)
										,accountNum	VARCHAR(20), accountName NVARCHAR(100), accountType CHAR(1), inquiryAgreeYn	CHAR(1), transferAgreeYn VARCHAR(14), inquiryAgreeDtime	VARCHAR(14), transferAgreeDtime VARCHAR(14))
			
			INSERT INTO @TEMPTABLE(fintechUseNo, accountAlias, bankCodeStd, bankName, accountNum, accountNumMasked, accountName, accountType, inquiryAgreeYn, transferAgreeYn, accountState,
									inquiryAgreeDtime, transferAgreeDtime)

			SELECT fintechUseNo, accountAlias, bankCodeStd, bankName, accountNum, accountNumMasked, accountName, accountType, inquiryAgreeYn, transferAgreeYn, accountState,
									inquiryAgreeDtime, transferAgreeDtime
			FROM OPENXML(@hDoc, '/root/row')
			WITH 
			(
				fintechUseNo VARCHAR(30) '@fintechUseNo',
				accountAlias NVARCHAR(50) '@accountAlias',
				bankCodeStd VARCHAR(3) '@bankCodeStd',
				bankName NVARCHAR(20) '@bankName',
				accountNum VARCHAR(20) '@accountNum',
				accountNumMasked VARCHAR(20) '@accountNumMasked',
				accountName NVARCHAR(100) '@accountName',
				accountType CHAR(1) '@accountType',
				inquiryAgreeYn CHAR(1) '@inquiryAgreeYn',
				transferAgreeYn CHAR(1) '@transferAgreeYn',
				inquiryAgreeDtime VARCHAR(14) '@inquiryAgreeDtime',
				accountState CHAR(2) '@accountState',
				transferAgreeDtime VARCHAR(14) '@transferAgreeDtime'
			)

			DELETE T 
			FROM @TEMPTABLE T
			INNER JOIN KFTC_CUSTOMER_SUB S(NOLOCK) ON  S.customerId = @customerId AND userSeqNo = @userSeqNo AND S.fintechUseNo = T.fintechUseNo AND S.accountNum = T.accountNum

			INSERT INTO KFTC_CUSTOMER_SUB(customerId, userSeqNo, fintechUseNo, accountAlias, bankCodeStd, bankName, accountNum, accountNumMasked, accountName, accountType, inquiryAgreeYn, transferAgreeYn,
									inquiryAgreeDtime, transferAgreeDtime, accountState)
			SELECT @customerId, @userSeqNo, fintechUseNo, accountAlias, bankCodeStd, bankName, accountNum, accountNumMasked, accountName, accountType, inquiryAgreeYn, transferAgreeYn,
									inquiryAgreeDtime, transferAgreeDtime, accountState 
			FROM @TEMPTABLE
			
			EXEC sp_xml_removedocument @hDoc

			EXEC proc_errorHandler 0, @msg, @accessToken;
		END
		--max-20180615
		ELSE IF @flag = 'S'
		BEGIN
			DECLARE @LASTSYNC DATETIME = NULL

			SELECT	M.accessToken AS [access_token],	M.tokenType,	M.scope,			M.userCi,
					S.customerId,						S.userSeqNo,	S.fintechUseNo,		S.bankCodeStd,
					S.bankName,							S.accountNum,	S.accountNumMasked, S.accountName,
					DATEDIFF(DD, ISNULL(M.AccountSyncDT, GETDATE()), GETDATE()),
					IsSyncAccList = CASE WHEN DATEDIFF(DD, ISNULL(M.AccountSyncDT, GETDATE()), GETDATE()) > 1 THEN 'Y' ELSE 'N' END,
					IsShowRefresh = CASE WHEN DATEDIFF(MM, accessTokenRegTime, GETDATE()) >= 11 THEN 'Y' ELSE 'N' END
			FROM KFTC_CUSTOMER_SUB S(NOLOCK)
			INNER JOIN KFTC_CUSTOMER_MASTER M(NOLOCK) ON M.customerId = S.customerId 
			WHERE S.customerId = @customerId

			UPDATE KFTC_CUSTOMER_MASTER SET AccountSyncDT = GETDATE() WHERE customerId = @customerId
		END
		--max-20180726
		ELSE IF @flag = 's-send'
		BEGIN
			DECLARE @v_accHolderInfoType VARCHAR(100)
			DECLARE @v_accHolderInfo	VARCHAR(50)
			DECLARE @v_userInfo			VARCHAR(8)
			DECLARE @v_userGender		CHAR(1)
			DECLARE @v_combination		VARCHAR(50)
			DECLARE @v_national			CHAR(1)
			DECLARE @v_lastDigit		VARCHAR(5)

			SELECT	@v_userInfo = userInfo, 
					@v_userGender = CASE WHEN userGender = 'M' THEN '7' ELSE '8' END,
					@v_accHolderInfoType = accHolderInfoType,
					@v_accHolderInfo = accHolderInfo
			FROM	KFTC_CUSTOMER_MASTER(NOLOCK)
			WHERE   customerId = @customerId

			SELECT 	accountNo = '', accountNumMasked='KRW ' + CAST(availableBalance AS VARCHAR), autoDebit = '', walletName = 'GME Wallet', [type] = 'wallet', fintechUseNo = '', accountName = '', bankCode = ''
					, '' AS [isApproved], '' AS [accHolderInfoType], '' AS [accHolderInfo]
			FROM 	customerMaster (NOLOCK) 
			WHERE 	customerId = @customerId

			UNION ALL

			SELECT	S.accountNum AS [accountNo], 
					S.accountNumMasked, 
					'Auto Debit' AS [autoDebit],
					S.bankName AS [walletName], 
					'autodebit' AS [type], 
					S.fintechUseNo AS [fintechUseNo], 
					S.accountName AS [accountName], 
					S.bankCodeStd AS [bankCode],
					isApproved = CASE WHEN ApprovedBy IS NULL THEN 'N' ELSE 'Y' END,
					M.accHolderInfoType, M.accHolderInfo
			FROM KFTC_CUSTOMER_SUB S(NOLOCK)
			INNER JOIN KFTC_CUSTOMER_MASTER M(NOLOCK) ON M.customerId = S.customerId 
			WHERE S.customerId = @customerId	
		END
		ELSE IF @flag = 'DELETE'
		BEGIN
			-- 삭제하기전에 KFTC_CUSTOMER_SUB_DELETED 테이블에 삭제할 데이타를 저장			
			INSERT INTO KFTC_CUSTOMER_SUB_DELETED	(masterId, 			customerId, 	userSeqNo, 			fintechUseNo, 		accountAlias, 
													bankCodeStd, 		bankName, 		accountNum, 		accountNumMasked, 	accountName, 
													accountType, 		inquiryAgreeYn, transferAgreeYn, 	accountState, 		inquiryAgreeDtime, 
													transferAgreeDtime, RejectedBy, 	RejectedDate, 		RejectNote)

			SELECT 									0, 					customerId, 	userSeqNo, 			fintechUseNo, 		accountAlias, 
													bankCodeStd, 		bankName, 		accountNum, 		accountNumMasked, 	accountName, 
													accountType, 		inquiryAgreeYn, transferAgreeYn, 	accountState, 		inquiryAgreeDtime, 
													transferAgreeDtime, @customerId, 	GETDATE(), 			'Deleted by customer'
			FROM 		KFTC_CUSTOMER_SUB (NOLOCK) 
			WHERE 		customerId = @customerId 
			AND 		fintechUseNo = @fintechUseNo
			
			-- KFTC_CUSTOMER_SUB 데이타 삭제
			DELETE FROM	KFTC_CUSTOMER_SUB 
			WHERE 		customerId = @customerId 
			AND 		fintechUseNo = @fintechUseNo

			EXEC proc_errorHandler 0, 'Account deleted successfully!', @customerId;
		END
		ELSE IF @flag = 'DELETE_ACC'
		BEGIN
			-- 삭제하기전에 KFTC_CUSTOMER_SUB_DELETED 테이블에 삭제할 데이타를 저장
			INSERT INTO KFTC_CUSTOMER_SUB_DELETED	(masterId, 			customerId, 	userSeqNo, 			fintechUseNo, 		accountAlias, 
													bankCodeStd, 		bankName, 		accountNum, 		accountNumMasked, 	accountName, 
													accountType, 		inquiryAgreeYn, transferAgreeYn, 	accountState, 		inquiryAgreeDtime, 
													transferAgreeDtime, RejectedBy, 	RejectedDate, 		RejectNote)

			SELECT 									0, 					customerId, 	userSeqNo, 			fintechUseNo, 		accountAlias, 
													bankCodeStd, 		bankName, 		accountNum, 		accountNumMasked, 	accountName, 
													accountType, 		inquiryAgreeYn, transferAgreeYn, 	accountState, 		inquiryAgreeDtime, 
													transferAgreeDtime, @customerId, 	GETDATE(), 			'KFTC Auto Sync'
			FROM 		KFTC_CUSTOMER_SUB (NOLOCK) 
			WHERE 		customerId = @customerId 
			AND 		fintechUseNo = @fintechUseNo
			AND 		accountNum = @accountNumber
			
			-- KFTC_CUSTOMER_SUB 데이타 삭제
			DELETE FROM	KFTC_CUSTOMER_SUB 
			WHERE 		customerId = @customerId 
			AND 		fintechUseNo = @fintechUseNo 
			AND 		accountNum = @accountNumber

			EXEC proc_errorHandler 0, 'Account deleted successfully!', @customerId;
		END
		ELSE IF @flag = 'I-TRAN'
		BEGIN
			DECLARE @accountNum NVARCHAR(20)
			SELECT @accountNum = accountNum FROM KFTC_CUSTOMER_SUB (NOLOCK) WHERE CUSTOMERID = @customerId AND fintechUseNo = @fintechUseNo

			SET @dpsPrintContent = @accountNum + '_' + @dpsPrintContent

			INSERT INTO KFTC_CUSTOMER_TRANSFER(customerId, fintechUseNo, apiTranId, apiTranDtm, rspCode, dpsBankCodeStd, dpsAccountNumMasked, dpsPrintContent, bankTranId, 
												bankTranDate, bankCodeTran, bankRspCode, bankCodeStd, accountNumMasked, printContent, accountName, tranAmt, remittance_check, 
												errorCode, 
												errorMsg)

			SELECT @customerId, @fintechUseNo, @apiTranId, @apiTranDtm, @rspCode, @dpsBankCodeStd, @dpsAccountNumMasked, @dpsPrintContent, @bankTranId, 
												@bankTranDate, @bankCodeTran, @bankRspCode, @bankCodeStd, @accountNumMasked, @printContent, @accountName, @tranAmt, @remittance_check,
												CASE WHEN @remittance_check = 'Y' THEN '0' ELSE '1' END,
												CASE WHEN @remittance_check = 'Y' THEN 'SUCCESSFULLY VALIDATED!' ELSE 'ERROR WHILE KFTC CheckRemittant METHOD!' END

			DECLARE @TEMPID BIGINT = @@IDENTITY

			EXEC proc_errorHandler 0, 'Data Saved Successfully!', @TEMPID;
		END
		ELSE IF @flag = 'U-TRAN'
		BEGIN
			UPDATE KFTC_CUSTOMER_TRANSFER SET 
					errorCode = @errorCode
					,errorMsg = @errorMsg
			WHERE rowId = @rowId
		END
		ELSE IF @flag = 'SYNC-LIST-CUSTOMER'
		BEGIN
			SELECT @clientId = dbo.fnadecryptstring(clientId), @clientSecret = dbo.fnadecryptstring(clientSecret) FROM KFTC_GME_MASTER (NOLOCK) 

			SELECT clientId = @clientId, clientSecret = @clientSecret, refreshToken, scope, customerId
			FROM KFTC_CUSTOMER_MASTER (NOLOCK) 
			WHERE  accessTokenExpTime BETWEEN CAST(DATEADD(DAY, -1, GETDATE()) AS DATE) AND CAST(CAST(DATEADD(DAY, 1, GETDATE()) AS DATE) AS VARCHAR) + ' 23:59:59'
		END
		ELSE IF @flag = 'SYNC-LIST-GME'
		BEGIN
			SELECT 	clientId = dbo.fnadecryptstring(clientId), clientSecret  = dbo.fnadecryptstring(clientSecret)
			FROM 	KFTC_GME_MASTER (NOLOCK) 
			WHERE 	accessToken IS NULL OR accessToken = '' 
			OR    	accessTokenExpTime BETWEEN CAST(DATEADD(DAY, -1, GETDATE()) AS DATE) AND CAST(CAST(DATEADD(DAY, 1, GETDATE()) AS DATE) AS VARCHAR) + ' 23:59:59'
		END
		ELSE IF @flag = 'AUTO-SYNC-SUCCESS'
		BEGIN
			SET @accessTokenExpTime = DATEADD(SECOND, @expiresIn, GETDATE())

			UPDATE KFTC_CUSTOMER_MASTER SET
						accessToken = @accessToken
						,tokenType = @tokenType
						,expiresIn = @expiresIn
						,accessTokenExpTime = @accessTokenExpTime
						,refreshToken = @refreshToken
			WHERE customerId = @customerId
		END
		ELSE IF @flag = 'SYNC-SUCCESS-GME'
		BEGIN
			SET @accessTokenExpTime = DATEADD(SECOND, @expiresIn, GETDATE())

			UPDATE KFTC_GME_MASTER SET
						accessToken = @accessToken
						,expiresIn = @expiresIn
						,accessTokenExpTime = @accessTokenExpTime
						,clientUseCode = dbo.fnaencryptstring(@clientUseCode)
		END
		ELSE IF @flag = 's-refresh'
		BEGIN
			SELECT userSeqNo, userCi, userName, userInfo, userGender,
					UserCellNo, UserEmail, PhoneCarrier = ''
			FROM KFTC_CUSTOMER_MASTER (NOLOCK) 
			WHERE customerId = @customerId
		END
		ELSE IF @flag = 'txn-error'
		BEGIN
			UPDATE KFTC_CUSTOMER_TRANSFER SET errorCode = @errorCode, errorMsg = @errorMsg WHERE ROWID = @kftcLogId
		END
	END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT <> 0
        ROLLBACK TRANSACTION;
		
    DECLARE @errorMessage VARCHAR(MAX);
    SET @errorMessage = ERROR_MESSAGE();
	
    EXEC proc_errorHandler 1, @errorMessage, @userEmail;
	
END CATCH;
GO
