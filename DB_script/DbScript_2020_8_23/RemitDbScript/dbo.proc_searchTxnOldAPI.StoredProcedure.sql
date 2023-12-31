USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_searchTxnOldAPI]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC proc_searchTxnOldAPI @flag='Search',@user='admin',@controlNo='91519884184'
EXEC proc_searchTxnOldAPI @flag='SearchTicket',@user='admin',@controlNo='91519884184'
EXEC proc_searchTxnOldAPI @flag='Search', @user = 'admin', @criteria = 'customerId', @value = '224659'
*/
CREATE proc [dbo].[proc_searchTxnOldAPI]
	 @flag VARCHAR(50)
	,@user VARCHAR(50)			= NULL
	,@controlNo VARCHAR(50)		= NULL
	,@criteria	VARCHAR(50)		= NULL
	,@value		VARCHAR(200)	= NULL
	
AS

SET NOCOUNT ON

DECLARE
	 @code						VARCHAR(50)
	,@userName					VARCHAR(50)
	,@password					VARCHAR(50)
	
EXEC proc_GetAPI @user OUTPUT,@code OUTPUT, @userName OUTPUT, @password OUTPUT

IF @flag = 'Search'
BEGIN
	
	IF @criteria='controlNo'
		SET @controlNo=@value
		
	IF @criteria='customerId'
	BEGIN
		select @controlNo=dbo.decryptDb(refno)	
		from ime_plus_01.dbo.AccountTransaction where CustomerId = @value AND STATUS='Un-Paid'
		IF @controlNo IS NULL
		BEGIN		
			SELECT 1 Code, 'Customer ID not matched!' [Message]
			return;		
		END
	END

	IF @criteria='TranId'
	BEGIN
		select @controlNo=dbo.decryptDb(refno) 
		from ime_plus_01.dbo.AccountTransaction where Tranno = @value
		IF @controlNo IS NULL
		BEGIN		
			SELECT 1 Code, 'Transaction ID not matched!' [Message]
			return;		
		END
	END	
	
	Exec ime_plus_01.dbo.spa_SOAP_Domestic_TransactionStatus
	@code,@userName,@password,'1234',@controlNo
	
	/*

-- ## Search Transaction Old System ## --
EXEC proc_searchTxnOldAPI @flag='Search' , @user = 'admin', @controlNo = '98117283086'
select dbo.decryptDb(refno) refNo,agentname,SenderName,SenderAddress,sender_mobile,SenderCountry,ReceiverName,ReceiverAddress,ReceiverCountry,
receiveAmt,receiveCType,paymentType,confirmDate,status,paidDate,paidBy,Tranno 
from ime_plus_01.dbo.AccountTransaction where refno=dbo.encryptDb('98117283086')
	*/
	
END

IF @flag = 'SearchTicket'
BEGIN
	EXEC ime_plus_01.[dbo].[spa_SOAP_Domestic_CheckTickets]
		@code,@userName,@password,'177123',@controlNo
END


GO
