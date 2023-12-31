USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_TranHistory]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec [mobile_proc_TranHistory] @flag='tran-history', @userId='PRALHADS@GMEREMIT.com'

/****** Object:  StoredProcedure [dbo].[mobile_proc_paidTranHistory]    Script Date: 9/6/2018 11:41:36 AM ******/

CREATE PROCEDURE [dbo].[mobile_proc_TranHistory](
	 @flag			    VARCHAR(50)  = NULL
	,@userId		    VARCHAR(100) = NULL 
	,@fromDate			VARCHAR(50)   = NULL
	,@toDate			VARCHAR(50)   = NULL
	
)
AS 
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY	
	DECLARE 
		 @email VARCHAR(100)
		,@mobile VARCHAR(25)	
		,@customerId BIGINT	
		,@sql    VARCHAR(MAX)
BEGIN
	IF @flag='tran-history'
	BEGIN
		SELECT 
			 @email=cm.email
			,@mobile=cm.mobile
			,@customerId = cm.customerId
		FROM dbo.customerMaster(NOLOCK) cm
		WHERE cm.username=@userId 

		SET @sql=
		'SELECT 
			 errorCode      = ''0''
			,userId         = ReceiverName
			,tranId         = rt.id
			,controlNo      = dbo.FNADecryptString(rt.controlNo)
			,collAmount     = Cast(rt.cAmt as decimal) 
			,collCurr       = rt.collCurr
			,payoutAmt      = rt.pAmt 
			,pCurr          = rt.payoutCurr
			,payStatus      = CASE WHEN rt.tranStatus=''Cancel'' then ''Cancelled'' 
								WHEN rt.tranStatus=''Payment'' AND rt.payStatus=''Post'' AND rt.paymentMethod=''Cash Payment'' THEN ''Ready To Collect''
								WHEN rt.tranStatus=''Payment'' AND rt.payStatus=''Post'' AND rt.paymentMethod=''Bank Deposit'' THEN ''Processing'' 								
								 else rt.payStatus end
			,payoutMode     = rt.paymentMethod
			,sendDate       = CONVERT(varchar(10), rt.createdDate, 120)
			,paidDate       = CONVERT(varchar(10), rt.paidDate, 120)
			,PayoutAgent	= rt.pBankName
		FROM dbo.remitTran(NOLOCK) rt
		INNER JOIN dbo.tranSenders s(NOLOCK) on s.tranid = rt.id
		WHERE s.customerId='''+CAST(@customerId AS VARCHAR)+''''

		IF ISNULL(@fromDate,'') <> ''  AND ISNULL(@toDate,'') <> '' 
		BEGIN
			SET @sql=@sql + ' AND rt.createdDate BETWEEN '''+@fromDate+''' AND '''+ @toDate+' 23:59:59'''
		END
		ELSE
        BEGIN
			SET @sql = REPLACE(@sql,'SELECT','SELECT TOP 7 ') + ' ORDER BY rt.createdDate DESC'
		END

		PRINT(@sql)
		EXEC(@sql)
		
	END
END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage=ERROR_MESSAGE();
	SELECT '1' ErrorCode, @errorMessage Msg ,NULL ID
END CATCH
GO
