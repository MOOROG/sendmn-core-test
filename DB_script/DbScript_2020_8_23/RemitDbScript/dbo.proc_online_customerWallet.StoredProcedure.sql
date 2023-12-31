USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_customerWallet]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[proc_online_customerWallet]  
  @flag			VARCHAR(50)  = NULL  
 ,@customerId	VARCHAR(30)  = NULL  
 ,@amount		VARCHAR(15)  = NULL
 ,@remarks		VARCHAR(150) = NULL
 ,@fromDate		VARCHAR(20)  = NULL
 ,@toDate		VARCHAR(20)	 = NULL

AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  

BEGIN TRY 	

IF @flag = 'i'  
BEGIN
	DECLARE 
		 @walletTxnId		BIGINT
		,@bankId			INT
		,@remBalance		VARCHAR(20)
		,@withDrawalCharge	VARCHAR(20)
		,@availableBal		VARCHAR(20)

	SELECT @withDrawalCharge = 1000
	SELECT @bankId = bankName, @availableBal = availableBalance FROM customerMaster(NOLOCK) WHERE customerId = @customerId

	SELECT '1' ErrorCode, 'Sorry, you can not perform withfrawal. Please contact GME HO for any assistance'  Msg, '' Id
	RETURN

	IF ISNULL(@amount,0) <=0
	BEGIN
		SELECT '1' ErrorCode, 'Invalid Operation withdraw amount not sufficient.'  Msg, '' Id	
		RETURN	
	END

	IF CAST(@availableBal AS MONEY) <= 0
	BEGIN
		SELECT '1' ErrorCode,'Invalid Operation available balance not sufficient.' Msg, '' Id	
		RETURN
	END
	IF CAST(@availableBal AS MONEY) < @amount
	BEGIN
		SELECT '1' ErrorCode,'Invalid Operation available balance not sufficient.' Msg, '' Id	
		RETURN
	END

	INSERT INTO WalletTransactions(
		 createdDate
		,customerId
		,bankId
		,controlNo
		,tranId
		,remarks
		,amount
		,approvedDate
		,approvedBy
		,status
	)
	SELECT GETDATE(), @customerId, @bankId, NULL, NULL, 'Customer Withdrawal', @amount, NULL, NULL, 1

	SELECT @walletTxnId = SCOPE_IDENTITY()
	INSERT INTO WithdrawalLogs(
		 WalletTransactionId
		,createdDate
		,customerId
		,bankId
		,remarks
		,amount
		,approvedDate
		,approvedBy
		,status
	)

	SELECT @walletTxnId, GETDATE(), @customerId, @bankId, @remarks, @amount, NULL, NULL, 1

	SELECT @remBalance = ISNULL(CAST(@availableBal AS MONEY), 0.00) - CAST(@withDrawalCharge AS MONEY) - CAST(@amount AS MONEY)

	UPDATE customerMaster SET availableBalance = @remBalance WHERE customerId = @customerId

	SELECT '0' ErrorCode, 'Your request for withdrawal of amount ' + @amount + ' has been successful.' Msg, '' Id, @remBalance Extra

END

IF @flag = 's'
BEGIN
	
	SELECT Debit = '' , Credit = '', [Date] = '', Particular = 'Opening Balance', Balance = ISNULL(SUM(amount),'0.00')
	FROM WalletTransactions(NOLOCK) 
	WHERE customerId = @customerId AND createdDate < @fromDate

	UNION ALL
	SELECT	Debit  =  CASE WHEN amount > 0 THEN amount ELSE '0.00' END, 
			Credit =  CASE WHEN amount < 0 THEN amount ELSE '0.00' END,
			[Date] = CONVERT(VARCHAR(10), wt.createdDate, 103),
			Particular = remarks,
			Balance = ''
	FROM WalletTransactions(NOLOCK) wt INNER JOIN customerMaster cm ON wt.customerId = cm.customerId
	WHERE wt.customerId = @customerId AND wt.createdDate BETWEEN CAST(@fromDate AS DATETIME) AND CAST(@toDate AS DATETIME) + '23:59:59'
END

END TRY  
BEGIN CATCH  
     IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     DECLARE @errorMessage VARCHAR(MAX)  
     SET @errorMessage = ERROR_MESSAGE() 
     EXEC proc_errorHandler 1, @errorMessage, @customerId  
END CATCH 

GO
