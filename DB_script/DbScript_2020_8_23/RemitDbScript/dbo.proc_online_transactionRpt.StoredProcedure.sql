USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_transactionRpt]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[proc_online_transactionRpt] 
(
	@flag			VARCHAR(30)		=	NULL
   ,@user			VARCHAR(50)		=	NULL
   ,@fromDate		VARCHAR(50)		=	NULL
   ,@toDate			VARCHAR(50)		=	NULL
   ,@refNo			VARCHAR(50)		=   NULL
   ,@status			VARCHAR(50)		=	NULL
   ,@beneficiary	VARCHAR(200)	=	NULL
   ,@senderName		VARCHAR(100)	=	NULL
   ,@sortBy         VARCHAR(50)		=   NULL
   ,@sortOrder      VARCHAR(5)		=   NULL
   ,@pageSize       INT				=   NULL
   ,@pageNumber     INT				=   NULL		
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON ;	
BEGIN TRY
	
	 DECLARE 
		 @table					VARCHAR(MAX)		
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)
	 
	 IF @flag = 'tranRpt' 
	 BEGIN
			DECLARE @recieverName VARCHAR(150), @customerId BIGINT
			
			IF  @beneficiary IS NOT NULL
			BEGIN
				SELECT @recieverName = firstName + ISNULL(' '+ middleName,'') + ISNULL(' '+lastName1,'') + ISNULL(' '+lastName2,'')   
				FROM receiverInformation (NOLOCK)
				WHERE receiverid = @beneficiary
			END

			SELECT @customerId = customerId 
			FROM customerMaster (NOLOCK) 
			WHERE EMAIL = @user

			IF @sortBy IS NULL
		       SET @sortBy = 'TranDate'
			IF @sortOrder IS NULL
		        SET @sortOrder = 'DESC'
			
			 SET @table = 'SELECT 
				 ID = rt.id 
				,[ControlNo] = dbo.fnadecryptstring(controlNo)
				,[PaymentBy]= paymentMethod
				,[TranDate] = convert(varchar,rt.createdDate,103)
				,[SendAmount] = rt.cAmt
				,[Beneficiary] = rt.receiverName
				,[ReceivingCountry] = rt.pCountry
				,[TranStatus] = CASE WHEN (rt.payStatus = ''Unpaid'' AND rt.transtatus = ''Payment'') THEN ''Waiting''
							WHEN (rt.payStatus = ''Post'' AND rt.transtatus = ''Payment'') THEN ''Ready for Payment''
							WHEN (rt.payStatus = ''Paid'' OR rt.transtatus = ''Paid'') THEN ''Paid''
							WHEN (rt.payStatus = ''Unpaid'' AND rt.transtatus = ''Hold'') THEN ''Waiting for Approval''
							WHEN (rt.payStatus=''Unpaid'' AND rt.transtatus IN (''OFAC/Compliance'', ''Compliance'', ''OFAC'')) THEN ''Waiting for Approval'' 
							ELSE rt.payStatus 
							END
				--rt.payStatus
				,TranNo = isnull(rt.uploadLogId, rt.id)
				,pCountry
			FROM vwRemitTran rt with(nolock) 
			INNER JOIN vwTranSenders sen WITH(NOLOCK) ON sen.tranId = rt.id
			WHERE sen.customerId='''+CAST(@customerId AS VARCHAR)+'''
			AND transtatus <> ''Cancel'' '
			

			SET @sql_filter = '' 

			IF @refNo IS NULL
			BEGIN
				IF @fromDate IS NOT NULL and @todate IS NOT NULL
				SET @table = @table + ' and  rt.createdDate BETWEEN '''+@fromDate+''' AND '''+ @toDate+' 23:59:59''' 
			END
				
			IF @refNo IS NOT NULL
				SET @table = @table + ' and rt.controlNo = '''+dbo.fnaencryptstring(@refNo)+''''

			IF @status IS NOT NULL
				SET @table = @table + ' and rt.paystatus = '''+@status+''''
			
			IF @beneficiary IS NOT NULL
				SET @table = @table + ' and rt.receiverName ='''+ @recieverName +''''
				
			SET @table = @table + ' ORDER BY rt.createdDate DESC'
			
			EXEC(@table)
		
	END


END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
     PRINT ERROR_LINE()
END CATCH





GO
