USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_archiveLogs]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_archiveLogs]
AS

SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY

	DECLARE @cutOffDays INT = 5
	
	DECLARE @date DATETIME = CONVERT(VARCHAR, GETDATE()-@cutOffDays, 101)
	PRINT CONVERT(VARCHAR, GETDATE(), 109)
	
	EXEC proc_PrintLog 'Moving Data - Started', 'applicationLogs'

	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.applicationLogs(
			rowId,module,logType,tableName,dataId,oldData,newData,createdBy,createdDate
		)
		SELECT 
			rowId,module,logType,tableName,dataId,oldData,newData,createdBy,createdDate
		FROM applicationLogs WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM applicationLogs WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'applicationLogs', 'apiRequestLog'
	
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.apiRequestLog(
			rowId,AGENT_CODE,USER_ID,PASSWORD,AGENT_SESSION_ID,AGENT_TXN_ID,LOCATION_ID,SENDER_NAME,SENDER_GENDER,SENDER_ADDRESS
			,SENDER_MOBILE,SENDER_CITY,SENDER_COUNTRY,SENDER_ID_TYPE,SENDER_ID_NUMBER,SENDER_ID_ISSUE_DATE,SENDER_ID_EXPIRE_DATE
			,SENDER_DATE_OF_BIRTH,RECEIVER_NAME,RECEIVER_ADDRESS,RECEIVER_CONTACT_NUMBER,RECEIVER_CITY,RECEIVER_COUNTRY,TRANSFER_AMOUNT
			,COLLECT_AMT,PAYOUTAMT,PAYMENT_MODE,BANK_ID,BANK_NAME,BANK_BRANCH_NAME,BANK_ACCOUNT_NUMBER,CALC_BY,AUTHORIZED_REQUIRED
			,OUR_SERVICE_CHARGE,EXT_BANK_BRANCH_ID,RECEIVER_IDENTITY_TYPE,RECEIVER_IDENTITY_NUMBER,RECEIVER_RELATION,PAYOUT_AGENT_ID
			,REQUESTED_DATE,TRNDATE,SETTLE_USD_AMT,SETTLE_RATE,CUSTOMER_ID,SOURCE_OF_INCOME,REASON_FOR_REMITTANCE,SENDER_OCCUPATION
			,controlNo,errorCode,errorMsg
		)
		SELECT 
			rowId,AGENT_CODE,USER_ID,PASSWORD,AGENT_SESSION_ID,AGENT_TXN_ID,LOCATION_ID,SENDER_NAME,SENDER_GENDER,SENDER_ADDRESS
			,SENDER_MOBILE,SENDER_CITY,SENDER_COUNTRY,SENDER_ID_TYPE,SENDER_ID_NUMBER,SENDER_ID_ISSUE_DATE,SENDER_ID_EXPIRE_DATE
			,SENDER_DATE_OF_BIRTH,RECEIVER_NAME,RECEIVER_ADDRESS,RECEIVER_CONTACT_NUMBER,RECEIVER_CITY,RECEIVER_COUNTRY,TRANSFER_AMOUNT
			,COLLECT_AMT,PAYOUTAMT,PAYMENT_MODE,BANK_ID,BANK_NAME,BANK_BRANCH_NAME,BANK_ACCOUNT_NUMBER,CALC_BY,AUTHORIZED_REQUIRED
			,OUR_SERVICE_CHARGE,EXT_BANK_BRANCH_ID,RECEIVER_IDENTITY_TYPE,RECEIVER_IDENTITY_NUMBER,RECEIVER_RELATION,PAYOUT_AGENT_ID
			,REQUESTED_DATE,TRNDATE,SETTLE_USD_AMT,SETTLE_RATE,CUSTOMER_ID,SOURCE_OF_INCOME,REASON_FOR_REMITTANCE,SENDER_OCCUPATION
			,controlNo,errorCode,errorMsg
		FROM apiRequestLog WITH(NOLOCK) WHERE REQUESTED_DATE < @date
		
		
		
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM apiRequestLog WHERE REQUESTED_DATE < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'apiRequestLog', 'siteAccessLog'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.siteAccessLog(
			rowId,dcId,dcUserName,ipAddress,accessDate
		)
		SELECT 
			rowId,dcId,dcUserName,ipAddress,accessDate
		FROM siteAccessLog WITH(NOLOCK) WHERE accessDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM siteAccessLog WHERE accessDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'siteAccessLog', 'ceAcDepositDownloadLogs'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.ceAcDepositDownloadLogs(
			rowId,createdDate,createdBy
		)
		SELECT 
			rowId,createdDate,createdBy
		FROM ceAcDepositDownloadLogs WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM ceAcDepositDownloadLogs WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'ceAcDepositDownloadLogs', 'apiRequestLogSMA'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.apiRequestLogSMA(
			rowId,AGENT_CODE,USER_ID,PASSWORD,AGENT_SESSION_ID,AGENT_TXNID,LOCATION_ID,SENDER_NAME,SENDER_GENDER,SENDER_ADDRESS
			,SENDER_MOBILE,SENDER_CITY,SENDER_COUNTRY,SENDER_ID_TYPE,SENDER_ID_NUMBER,SENDER_ID_ISSUE_DATE,SENDER_ID_EXPIRE_DATE
			,SENDER_DATE_OF_BIRTH,RECEIVER_NAME,RECEIVER_ADDRESS,RECEIVER_CONTACT_NUMBER,RECEIVER_CITY,RECEIVER_COUNTRY,PAYOUT_AMOUNT
			,PAYMENTMODE,BANKID,BANK_ACCOUNT_NUMBER,OUR_SERVICE_CHARGE,EXT_BANK_BRANCH_ID,SETTLE_USD_AMT,SETTLE_RATE,CUSTOMER_ID
			,RECEIVER_RELATION,SOURCE_OF_INCOME,REASON_FOR_REMITTANCE,SENDER_OCCUPATION,REQUEST_DATE,errorCode,errorMsg,controlNo
		)
		SELECT 
			rowId,AGENT_CODE,USER_ID,PASSWORD,AGENT_SESSION_ID,AGENT_TXNID,LOCATION_ID,SENDER_NAME,SENDER_GENDER,SENDER_ADDRESS
			,SENDER_MOBILE,SENDER_CITY,SENDER_COUNTRY,SENDER_ID_TYPE,SENDER_ID_NUMBER,SENDER_ID_ISSUE_DATE,SENDER_ID_EXPIRE_DATE
			,SENDER_DATE_OF_BIRTH,RECEIVER_NAME,RECEIVER_ADDRESS,RECEIVER_CONTACT_NUMBER,RECEIVER_CITY,RECEIVER_COUNTRY,PAYOUT_AMOUNT
			,PAYMENTMODE,BANKID,BANK_ACCOUNT_NUMBER,OUR_SERVICE_CHARGE,EXT_BANK_BRANCH_ID,SETTLE_USD_AMT,SETTLE_RATE,CUSTOMER_ID
			,RECEIVER_RELATION,SOURCE_OF_INCOME,REASON_FOR_REMITTANCE,SENDER_OCCUPATION,REQUEST_DATE,errorCode,errorMsg,controlNo
		FROM apiRequestLogSMA WITH(NOLOCK) WHERE REQUEST_DATE < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM apiRequestLogSMA WHERE REQUEST_DATE < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'apiRequestLogSMA', 'requestApiLogOther'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.requestApiLogOther(
			rowId,AGENT_CODE,USER_ID,PASSWORD,AGENT_SESSION_ID,AGENT_TXN_REF_ID,PAYMENTTYPE,PAYOUT_COUNTRY,PAYOUT_AGENT_ID,REMIT_AMOUNT
			,CALC_BY,REPORT_TYPE,FROM_DATE,TO_DATE,REFNO,CANCEL_REASON,SHOW_INCREMENTAL,REQUEST_DATE,errorCode,errorMsg,METHOD_NAME
		)
		SELECT 
			rowId,AGENT_CODE,USER_ID,PASSWORD,AGENT_SESSION_ID,AGENT_TXN_REF_ID,PAYMENTTYPE,PAYOUT_COUNTRY,PAYOUT_AGENT_ID,REMIT_AMOUNT
			,CALC_BY,REPORT_TYPE,FROM_DATE,TO_DATE,REFNO,CANCEL_REASON,SHOW_INCREMENTAL,REQUEST_DATE,errorCode,errorMsg,METHOD_NAME
		FROM requestApiLogOther WITH(NOLOCK) WHERE REQUEST_DATE < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM requestApiLogOther WHERE REQUEST_DATE < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'requestApiLogOther', 'soaMonthlyLog'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.soaMonthlyLog(
			id,agentId,branchId,fromDate,toDate,soaType,createdDate,message,logType,npMonth,npYear,createdBy
		)
		SELECT 
			id,agentId,branchId,fromDate,toDate,soaType,createdDate,message,logType,npMonth,npYear,createdBy
		FROM soaMonthlyLog WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM soaMonthlyLog WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'soaMonthlyLog', 'IpAccessLogs'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.IpAccessLogs(
			id,ip,fieldValue,createdDate
		)
		SELECT 
			id,ip,fieldValue,createdDate
		FROM IpAccessLogs WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM IpAccessLogs WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'IpAccessLogs', 'apiRequestLog_GetExRate'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.apiRequestLog_GetExRate(
			rowId,AGENT_CODE,USER_ID,PASSWORD,AGENT_SESSION_ID,TRANSFERAMOUNT,PAYMENTMODE,CALC_BY,LOCATION_ID,PAYOUT_COUNTRY
			,errorCode,errorMsg,requestedDate
		)
		SELECT 
			rowId,AGENT_CODE,USER_ID,PASSWORD,AGENT_SESSION_ID,TRANSFERAMOUNT,PAYMENTMODE,CALC_BY,LOCATION_ID,PAYOUT_COUNTRY
			,errorCode,errorMsg,requestedDate
		FROM apiRequestLog_GetExRate WITH(NOLOCK) WHERE requestedDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM apiRequestLog_GetExRate WHERE requestedDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'apiRequestLog_GetExRate', 'apiRequestLogPay'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.apiRequestLogPay(
			rowId,ACCESSCODE,USERNAME,PASSWORD,REFNO,AGENT_SESSION_ID,PAY_TOKEN_ID,requestedDate,errorCode,errorMsg,remarks
		)
		SELECT 
			rowId,ACCESSCODE,USERNAME,PASSWORD,REFNO,AGENT_SESSION_ID,PAY_TOKEN_ID,requestedDate,errorCode,errorMsg,remarks
		FROM apiRequestLogPay WITH(NOLOCK) WHERE requestedDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM apiRequestLogPay WHERE requestedDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'apiRequestLogPay', 'LoginLogs'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.LoginLogs(
			rowId,logType,IP,Reason,fieldValue,createdBy,createdDate,UserData,agentId,dcSerialNumber,dcUserName
		)
		SELECT 
			rowId,logType,IP,Reason,fieldValue,createdBy,createdDate,UserData,agentId,dcSerialNumber,dcUserName
		FROM LoginLogs WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM LoginLogs WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'LoginLogs', 'Logs'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.Logs(
			id,errorPage,errorMsg,errorDetails,createdBy,createdDate
		)
		SELECT 
			id,errorPage,errorMsg,errorDetails,createdBy,createdDate
		FROM Logs WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM Logs WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'Logs', 'txnUploadLog'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.txnUploadLog(
			logId,xmlData,xmlErrorData,uploadedBy,uploadedDate,logType,receivingMode,pAgent,pAgentName,pBranch,pBranchName
		)
		SELECT 
			logId,xmlData,xmlErrorData,uploadedBy,uploadedDate,logType,receivingMode,pAgent,pAgentName,pBranch,pBranchName
		FROM txnUploadLog WITH(NOLOCK) WHERE uploadedDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM txnUploadLog WHERE uploadedDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'txnUploadLog', 'blacklistLog'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.blacklistLog(
			rowId,totalRecord,dataSource,createdBy,createdDate,ofacDate
		)
		SELECT 
			rowId,totalRecord,dataSource,createdBy,createdDate,ofacDate
		FROM blacklistLog WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM blacklistLog WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'blacklistLog', 'cePayHistory'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.cePayHistory(
			rowId,agentId,agentRequestId,beneAddress,beneBankAccountNumber,beneBankBranchCode,beneBankBranchName,beneBankCode
			,beneBankName,beneIdNo,beneName,benePhone,custAddress,custIdDate,custIdNo,custIdType,custName,custNationality,custPhone
			,description,destinationAmount,destinationCurrency,gitNo,paymentMode,purpose,responseCode,settlementCurrency,apiStatus
			,payResponseCode,payResponseMsg,recordStatus,tranPayProcess,createdDate,createdBy,paidDate,paidBy,rContactNo,nativeCountry
			,pBranch,rIdType,rIdNumber,rValidDate,rDob,rAddress,rCity,rOccupation,remarks,rIdPlaceOfIssue,relationType,relativeName
		)
		SELECT 
			rowId,agentId,agentRequestId,beneAddress,beneBankAccountNumber,beneBankBranchCode,beneBankBranchName,beneBankCode
			,beneBankName,beneIdNo,beneName,benePhone,custAddress,custIdDate,custIdNo,custIdType,custName,custNationality,custPhone
			,description,destinationAmount,destinationCurrency,gitNo,paymentMode,purpose,responseCode,settlementCurrency,apiStatus
			,payResponseCode,payResponseMsg,recordStatus,tranPayProcess,createdDate,createdBy,paidDate,paidBy,rContactNo,nativeCountry
			,pBranch,rIdType,rIdNumber,rValidDate,rDob,rAddress,rCity,rOccupation,remarks,rIdPlaceOfIssue,relationType,relativeName
		FROM cePayHistory WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM cePayHistory WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'cePayHistory', 'ezPayHistory'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.ezPayHistory(
			id,TransactionNumber,SecurityNumber,TransactionDate,TypeOfTransaction,TransactionStatus,scCustomerName,scCustomerArabicName
			,scCustomerAddress,scCustomerCardNumber,scCustID,scCustIDType,scCustTelephoneNumber,scCustMobileNumber,scCustNationality
			,scCustEmail,sccustDOB,scCustMessage,scCustOccupation,scRelationship,scCustBankcode,scCustBankShortname,scCustBankName
			,scCustBankBranchcode,scCustBankBranchshortname,scCustBankBranchName,scBranchAddress,scContactPerson,scContactTelephoneNo
			,scCustCountryCode,scCustCountry,tbName,tbArabicName,tbAddress,tbAccountNumber,tbIdNumber,tbIdtype,tbBenBankName
			,tbBenBankBranchName,tbBankShortName,tbBankName,tbBranchShortName,tbBranchName,tbBranchAddress,tbContactPerson
			,tbContactTelephoneNo,tbIBBank,tbIBBranch,tbIBAddress,tbIBBankAccountno,tbIBBankDiffernt,tbIBClearingNumber
			,tbIBClearingType,tbIBSwiftCode,tbTelephoneNumber,tbMobileNumber,tbNationality,tbBenCountry,tbFundSource,tbPin,tbPurpose
			,tbSwiftCode,tbPaymentAgentCode,tbPaymentAgentCountryCode,tbPaymentAgentLocationCode,tbRecipientName,tbRecipientAddress
			,tbRecipientTelephone,tbRecipientMessage,tbReceiverComm,tbTypeOfTransaction,tdFxAmount,tdRate,tdMktRate,tdLocalAmount
			,tdTotalLocalAmount,tdCommissionAmount,tdLocalCurrencyCode,tdFxCurrencyCode,apiStatus,payResponseCode,payResponseMsg
			,recordStatus,tranPayProcess,createdDate,createdBy,paidDate,paidBy,rContactNo,nativeCountry,pBranch,rIdType,rIdNumber
			,rIdPlaceOfIssue,rValidDate,rDob,rAddress,rCity,rOccupation,relationType,relativeName,remarks
		)
		SELECT 
			id,TransactionNumber,SecurityNumber,TransactionDate,TypeOfTransaction,TransactionStatus,scCustomerName,scCustomerArabicName
			,scCustomerAddress,scCustomerCardNumber,scCustID,scCustIDType,scCustTelephoneNumber,scCustMobileNumber,scCustNationality
			,scCustEmail,sccustDOB,scCustMessage,scCustOccupation,scRelationship,scCustBankcode,scCustBankShortname,scCustBankName
			,scCustBankBranchcode,scCustBankBranchshortname,scCustBankBranchName,scBranchAddress,scContactPerson,scContactTelephoneNo
			,scCustCountryCode,scCustCountry,tbName,tbArabicName,tbAddress,tbAccountNumber,tbIdNumber,tbIdtype,tbBenBankName
			,tbBenBankBranchName,tbBankShortName,tbBankName,tbBranchShortName,tbBranchName,tbBranchAddress,tbContactPerson
			,tbContactTelephoneNo,tbIBBank,tbIBBranch,tbIBAddress,tbIBBankAccountno,tbIBBankDiffernt,tbIBClearingNumber
			,tbIBClearingType,tbIBSwiftCode,tbTelephoneNumber,tbMobileNumber,tbNationality,tbBenCountry,tbFundSource,tbPin,tbPurpose
			,tbSwiftCode,tbPaymentAgentCode,tbPaymentAgentCountryCode,tbPaymentAgentLocationCode,tbRecipientName,tbRecipientAddress
			,tbRecipientTelephone,tbRecipientMessage,tbReceiverComm,tbTypeOfTransaction,tdFxAmount,tdRate,tdMktRate,tdLocalAmount
			,tdTotalLocalAmount,tdCommissionAmount,tdLocalCurrencyCode,tdFxCurrencyCode,apiStatus,payResponseCode,payResponseMsg
			,recordStatus,tranPayProcess,createdDate,createdBy,paidDate,paidBy,rContactNo,nativeCountry,pBranch,rIdType,rIdNumber
			,rIdPlaceOfIssue,rValidDate,rDob,rAddress,rCity,rOccupation,relationType,relativeName,remarks
		FROM ezPayHistory WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM ezPayHistory WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'ezPayHistory', 'globalBankPayHistory'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.globalBankPayHistory(
			rowId,radNo,tokenId,benefName,benefTel,benefMobile,benefAddress,benefAccIdNo,benefIdType,senderName,senderAddress,senderTel
			,senderMobile,senderIdType,senderIdNo,remittanceEntryDt,remittanceAuthorizedDt,remitType,rCurrency,pCurrency,pCommission
			,amount,localAmount,exchangeRate,dollarRate,confirmationNo,apiStatus,payResponseCode,payResponseMsg,recordStatus
			,tranPayProcess,createdDate,createdBy,paidDate,paidBy,rContactNo,nativeCountry,pBranch,rIdType,rIdNumber,rValidDate,rDob
			,rAddress,rCity,rOccupation,remarks,rIdPlaceOfIssue,relationType,relativeName
		)
		SELECT 
			rowId,radNo,tokenId,benefName,benefTel,benefMobile,benefAddress,benefAccIdNo,benefIdType,senderName,senderAddress,senderTel
			,senderMobile,senderIdType,senderIdNo,remittanceEntryDt,remittanceAuthorizedDt,remitType,rCurrency,pCurrency,pCommission
			,amount,localAmount,exchangeRate,dollarRate,confirmationNo,apiStatus,payResponseCode,payResponseMsg,recordStatus
			,tranPayProcess,createdDate,createdBy,paidDate,paidBy,rContactNo,nativeCountry,pBranch,rIdType,rIdNumber,rValidDate,rDob
			,rAddress,rCity,rOccupation,remarks,rIdPlaceOfIssue,relationType,relativeName
		FROM globalBankPayHistory WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM globalBankPayHistory WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'globalBankPayHistory', 'mgPayHistory'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.mgPayHistory(
			id,mgiTransactionSessionID,referenceNumber,senderFirstName,senderMiddleName,senderLastName,senderLastName2,senderHomePhone
			,senderAddress,senderCity,senderZipCode,senderCountry,receiverFirstName,receiverMiddleName,receiverLastName,receiverLastName2
			,agentCheckNumber,agentCheckAmount,agentCheckAuthorizationNumber,customerCheckNumber,customerCheckAmount,okForAgent
			,deliveryOption,transactionStatus,dateTimeSent,receiveCurrency,receiveAmount,receiverCountry,originatingCountry
			,validIndicator,indicativeReceiveAmount,indicativeExchangeRate,originalSendAmount,originalSendCurrency,originalSendFee
			,originalExchangeRate,redirectIndicator,originalReceiveAmount,originalReceiveCurrency,originalReceiveCountry,newSendFee
			,newExchangeRate,newReceiveAmount,newReceiveCurrency,feeDifference,redirectType,notOkForPickupReasonCode
			,minutesUntilOkForPickup,notOkForPickupReasonDescription,message1,message2,receiverIdType,receiverIdNumber
			,receiverValidDate,receiverDob,receiverOccupation,receiverNativeCountry,receiverAddress,receiverCity,receiverZipCode
			,receiverContactNo,recordStatus,tranStatus,createdBy,createdDate,payResponseCode,payResponseMsg,superAgent,superAgentName
			,agent,agentName,branch,branchName,idIssueDate,dynamicFields,remarks,receiverIdIssueCountry,receiverIdIssueState
			,receiverNativeState,pCountry,CreatedDateLocal,relationType,relativeName,rIdPlaceOfIssue,rCountry,rState,rIdCountry
			,rIdState,rAddress,rCity,rIdType,rIdNumber,rDob,rMobile,tranPayProcess
		)
		SELECT 
			id,mgiTransactionSessionID,referenceNumber,senderFirstName,senderMiddleName,senderLastName,senderLastName2,senderHomePhone
			,senderAddress,senderCity,senderZipCode,senderCountry,receiverFirstName,receiverMiddleName,receiverLastName,receiverLastName2
			,agentCheckNumber,agentCheckAmount,agentCheckAuthorizationNumber,customerCheckNumber,customerCheckAmount,okForAgent
			,deliveryOption,transactionStatus,dateTimeSent,receiveCurrency,receiveAmount,receiverCountry,originatingCountry
			,validIndicator,indicativeReceiveAmount,indicativeExchangeRate,originalSendAmount,originalSendCurrency,originalSendFee
			,originalExchangeRate,redirectIndicator,originalReceiveAmount,originalReceiveCurrency,originalReceiveCountry,newSendFee
			,newExchangeRate,newReceiveAmount,newReceiveCurrency,feeDifference,redirectType,notOkForPickupReasonCode
			,minutesUntilOkForPickup,notOkForPickupReasonDescription,message1,message2,receiverIdType,receiverIdNumber
			,receiverValidDate,receiverDob,receiverOccupation,receiverNativeCountry,receiverAddress,receiverCity,receiverZipCode
			,receiverContactNo,recordStatus,tranStatus,createdBy,createdDate,payResponseCode,payResponseMsg,superAgent,superAgentName
			,agent,agentName,branch,branchName,idIssueDate,dynamicFields,remarks,receiverIdIssueCountry,receiverIdIssueState
			,receiverNativeState,pCountry,CreatedDateLocal,relationType,relativeName,rIdPlaceOfIssue,rCountry,rState,rIdCountry
			,rIdState,rAddress,rCity,rIdType,rIdNumber,rDob,rMobile,tranPayProcess
		FROM mgPayHistory WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM mgPayHistory WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'mgPayHistory', 'riaRemitPayHistory'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.riaRemitPayHistory(
			rowId,transRefID,orderFound,pin,orderNo,seqIDRA,orderDate,custNameFirst,custNameLast1,custNameLast2,custAddress,custCity
			,custState,custCountry,custZip,custTelNo,beneNameFirst,beneNameLast1,beneNameLast2,beneAddress,beneCity,beneState,beneCountry
			,beneZip,beneTelNo,beneCurrency,beneAmount,responseDateTimeUTC,confirmationNo,apiStatus,payResponseCode,payResponseMsg
			,recordStatus,tranPayProcess,createdDate,createdBy,paidDate,paidBy,rContactNo,nativeCountry,pBranch,rIdType,rIdNumber
			,rValidDate,rDob,rAddress,rCity,rOccupation,remarks,rIdPlaceOfIssue,relationType,relativeName,PCCommissionCurrency
			,PCCommissionAmount,SeqIDPA,sCountry, rBank, rBankBranch, rAccountNo, rChequeNo, customerId, membershipId, topupMobileNo
		)
		SELECT 
			rowId,transRefID,orderFound,pin,orderNo,seqIDRA,orderDate,custNameFirst,custNameLast1,custNameLast2,custAddress,custCity
			,custState,custCountry,custZip,custTelNo,beneNameFirst,beneNameLast1,beneNameLast2,beneAddress,beneCity,beneState,beneCountry
			,beneZip,beneTelNo,beneCurrency,beneAmount,responseDateTimeUTC,confirmationNo,apiStatus,payResponseCode,payResponseMsg
			,recordStatus,tranPayProcess,createdDate,createdBy,paidDate,paidBy,rContactNo,nativeCountry,pBranch,rIdType,rIdNumber
			,rValidDate,rDob,rAddress,rCity,rOccupation,remarks,rIdPlaceOfIssue,relationType,relativeName,PCCommissionCurrency
			,PCCommissionAmount,SeqIDPA,sCountry, rBank, rBankBranch, rAccountNo, rChequeNo, customerId, membershipId, topupMobileNo
		FROM riaRemitPayHistory WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM riaRemitPayHistory WHERE createdDate < @date
	COMMIT TRANSACTION
 
	EXEC proc_PrintLog 'riaRemitPayHistory', 'xPressTranHistory'
	BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.xPressTranHistory(
			rowId,xmwsSessionID,xpin,customerFirstName,customerMiddleName,customerLastName,customerPOBox,customerAddress1
			,customerAddress2,customerAddressCity,customerAddressState,customerAddressCountry,customerAddressZip,customerPhone
			,customerMobile,customerFax,customerEmail,customerDescription,customerOtherInfo,beneficiaryFirstName,beneficiaryMiddleName
			,beneficiaryLastName,beneficiaryIDOtherType,beneficiaryID,beneficiaryPOBox,beneficiaryAddress1,beneficiaryAddress2
			,beneficiaryAddressCity,beneficiaryAddressState,beneficiaryAddressCountry,beneficiaryAddressZip,beneficiaryPhone
			,beneficiaryMobile,beneficiaryFax,beneficiaryEmail,beneficiaryTestQuestion,beneficiaryTestAnswer,messageToBeneficiary
			,beneficiaryDescription,beneficiaryOtherInfo,purposeOfTxn,sourceOfIncome,payoutAmount,payInAmount,commission,tax
			,agentXchgRate,payoutCcyCode,payInCcyCode,payoutDate,payinDate,sendingAgentCode,sendingAgentName,receivingAgentCode
			,receivingAgentName,sendingCountry,receiveCountry,transactionMode,accountName,accountNo,bankName,bankBranchName,returnCode
			,returnMsg,recordStatus,tranPayProcess,createdBy,createdDate,txnByHo,branchId,payResponseCode,payResponseMsg,rIdType
			,rIdNumber,rPlaceOfIssue,rRelationType,rRelativeName,rContactNo,rIssuedDate,rValidDate,membershipId,customerId
		)
		SELECT 
			rowId,xmwsSessionID,xpin,customerFirstName,customerMiddleName,customerLastName,customerPOBox,customerAddress1
			,customerAddress2,customerAddressCity,customerAddressState,customerAddressCountry,customerAddressZip,customerPhone
			,customerMobile,customerFax,customerEmail,customerDescription,customerOtherInfo,beneficiaryFirstName,beneficiaryMiddleName
			,beneficiaryLastName,beneficiaryIDOtherType,beneficiaryID,beneficiaryPOBox,beneficiaryAddress1,beneficiaryAddress2
			,beneficiaryAddressCity,beneficiaryAddressState,beneficiaryAddressCountry,beneficiaryAddressZip,beneficiaryPhone
			,beneficiaryMobile,beneficiaryFax,beneficiaryEmail,beneficiaryTestQuestion,beneficiaryTestAnswer,messageToBeneficiary
			,beneficiaryDescription,beneficiaryOtherInfo,purposeOfTxn,sourceOfIncome,payoutAmount,payInAmount,commission,tax
			,agentXchgRate,payoutCcyCode,payInCcyCode,payoutDate,payinDate,sendingAgentCode,sendingAgentName,receivingAgentCode
			,receivingAgentName,sendingCountry,receiveCountry,transactionMode,accountName,accountNo,bankName,bankBranchName,returnCode
			,returnMsg,recordStatus,tranPayProcess,createdBy,createdDate,txnByHo,branchId,payResponseCode,payResponseMsg,rIdType
			,rIdNumber,rPlaceOfIssue,rRelationType,rRelativeName,rContactNo,rIssuedDate,rValidDate,membershipId,customerId
		FROM xPressTranHistory WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM xPressTranHistory WHERE createdDate < @date
		
		COMMIT TRANSACTION

		EXEC proc_PrintLog 'xPressTranHistory', 'exRateCalcHistory'

		BEGIN TRANSACTION
		SET IDENTITY_INSERT FastMoneyPro_remit_Archive.dbo.[exRateCalcHistory] ON 
		INSERT INTO FastMoneyPro_remit_Archive.dbo.[exRateCalcHistory](
			FOREX_SESSION_ID, AGENT_TXN_REF_ID, AGENT_CODE, [USER_ID], serviceCharge, pAmt, customerRate, sCurrCostRate
			,sCurrHoMargin, sCurrAgentMargin, pCurrCostRate, pCurrHoMargin, pCurrAgentMargin, agentCrossSettRate
			,treasuryTolerance, customerPremium, sharingValue, sharingType, createdDate, isExpired, rowId,msrepl_tran_version
		)
		SELECT
			FOREX_SESSION_ID, AGENT_TXN_REF_ID, AGENT_CODE, [USER_ID], serviceCharge, pAmt, customerRate, sCurrCostRate
			,sCurrHoMargin, sCurrAgentMargin, pCurrCostRate, pCurrHoMargin, pCurrAgentMargin, agentCrossSettRate
			,treasuryTolerance, customerPremium, sharingValue, sharingType, createdDate, isExpired, rowId,msrepl_tran_version
		FROM [exRateCalcHistory] (NOLOCK)
		WHERE createdDate < @date		
		PRINT @@ROWCOUNT
		SET IDENTITY_INSERT FastMoneyPro_remit_Archive.dbo.[exRateCalcHistory] OFF
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM [exRateCalcHistory] WHERE createdDate < @date
		COMMIT TRANSACTION

		EXEC proc_PrintLog 'exRateCalcHistory', 'icPayHistory'
		BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.icPayHistory(
			rowId, ICTC_Number, Agent_OrderNumber, Remitter_Name, Remitter_Address, Remitter_IDType, Remitter_IDDtl, Originating_Country
			,Delivery_Mode, Paying_Amount, PayingAgent_CommShare, Paying_Currency, Paying_Agent, Paying_AgentName, Beneficiary_Name
			,Beneficiary_Address, Beneficiary_City, Destination_Country, Beneficiary_TelNo, Beneficiary_MobileNo, Expected_BenefID
			,Bank_Address, Bank_Account_Number, Bank_Name, Purpose_Remit, Message_PayeeBranch, Bank_BranchCode, Settlement_Rate
			,PrinSettlement_Amount, Transaction_SentDate, apiStatus, payResponseCode, payResponseMsg, recordStatus, tranPayProcess
			,createdDate, createdBy, paidDate, paidBy, rContactNo, nativeCountry, pBranch, rIdType, rIdNumber, rValidDate, rDob
			,rAddress, rCity, rOccupation, remarks, relationship, rIdPlaceOfIssue, relationType, relativeName, rBank, rBankBranch
			,rAccountNo, rChequeNo, topupMobileNo, customerId, membershipId
		)
		SELECT 
			rowId, ICTC_Number, Agent_OrderNumber, Remitter_Name, Remitter_Address, Remitter_IDType, Remitter_IDDtl, Originating_Country
			,Delivery_Mode, Paying_Amount, PayingAgent_CommShare, Paying_Currency, Paying_Agent, Paying_AgentName, Beneficiary_Name
			,Beneficiary_Address, Beneficiary_City, Destination_Country, Beneficiary_TelNo, Beneficiary_MobileNo, Expected_BenefID
			,Bank_Address, Bank_Account_Number, Bank_Name, Purpose_Remit, Message_PayeeBranch, Bank_BranchCode, Settlement_Rate
			,PrinSettlement_Amount, Transaction_SentDate, apiStatus, payResponseCode, payResponseMsg, recordStatus, tranPayProcess
			,createdDate, createdBy, paidDate, paidBy, rContactNo, nativeCountry, pBranch, rIdType, rIdNumber, rValidDate, rDob
			,rAddress, rCity, rOccupation, remarks, relationship, rIdPlaceOfIssue, relationType, relativeName, rBank, rBankBranch
			,rAccountNo, rChequeNo, topupMobileNo, customerId, membershipId
		FROM icPayHistory WITH(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT
		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM icPayHistory WHERE createdDate < @date		
		COMMIT TRANSACTION


		EXEC proc_PrintLog 'icPayHistory', 'cePayHistory_v2'		
		BEGIN TRANSACTION
		INSERT INTO RemittanceLogData.np.cePayHistory_v2(
			rowId, ceNumber, originatingAgentRefNum, senderName, senderCountry, senderAgentCode, senderAgentName, senderMobileNumber
			,senderMessageToBeneficiary, txnCreatedDate, receiverName, receiverMobile, payoutCurrencyCode, payoutCurrencyName
			,sentAmount, charges, finalPayoutAmount, receiverAccountNumber, receiverIbanNumber, senderAddress, receiverAddress
			,senderIdType, senderIdNumber, senderIdDateType, senderIdDate, districtId, districtName, serviceId, benBankCode
			,benBankName, benBranchCode, benBranchName, benAccountType, benEftCode, agentCode, responseCode, responseDesc
			,userId, recordStatus, tranPayProcess, createdDate, createdBy, paidBy, paidDate, pBranch, rIdType, rIdNumber
			,rIdPlaceOfIssue, rValidDate, rDob, rAddress, rCity, rOccupation, rContactNo, nativeCountry, relationType, relativeName
			,remarks, payResponseCode, payResponseMsg, rBank, rBankBranch, rAccountNo, rChequeNo, topupMobileNo, customerId
			,membershipId
		)
		SELECT 
			rowId, ceNumber, originatingAgentRefNum, senderName, senderCountry, senderAgentCode, senderAgentName, senderMobileNumber
			,senderMessageToBeneficiary, txnCreatedDate, receiverName, receiverMobile, payoutCurrencyCode, payoutCurrencyName
			,sentAmount, charges, finalPayoutAmount, receiverAccountNumber, receiverIbanNumber, senderAddress, receiverAddress
			,senderIdType, senderIdNumber, senderIdDateType, senderIdDate, districtId, districtName, serviceId, benBankCode
			,benBankName, benBranchCode, benBranchName, benAccountType, benEftCode, agentCode, responseCode, responseDesc
			,userId, recordStatus, tranPayProcess, createdDate, createdBy, paidBy, paidDate, pBranch, rIdType, rIdNumber
			,rIdPlaceOfIssue, rValidDate, rDob, rAddress, rCity, rOccupation, rContactNo, nativeCountry, relationType, relativeName
			,remarks, payResponseCode, payResponseMsg, rBank, rBankBranch, rAccountNo, rChequeNo, topupMobileNo, customerId
			,membershipId
		FROM cePayHistory_v2(NOLOCK) WHERE createdDate < @date
		PRINT @@ROWCOUNT

		EXEC proc_PrintLog 'Deleting...',NULL
		DELETE FROM cePayHistory_v2 WHERE createdDate < @date		
		COMMIT TRANSACTION

		EXEC proc_PrintLog NULL, 'Moving Data - Completed'


	SELECT '0' errorCode, 'Log(s) archived successfully' msg, NULL id
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT '1' rrrorCode, ERROR_MESSAGE() msg, NULL id
END CATCH





GO
