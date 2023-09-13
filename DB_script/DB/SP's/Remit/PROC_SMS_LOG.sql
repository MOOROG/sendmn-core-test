
--[PROC_SMS_LOG] @flag='s'  ,@pageNumber='1', @pageSize='10', @sortBy='ROW_ID', @sortOrder='ASC', @user = 'raman'
--EXEC PROC_SMS_LOG @FLAG = 'I', @USER = 'raman', @CONTROL_NO = '211904957', @MSG_BODY = 'Dear PARIYAR, your money sent to account of JANAK in bank SANIMA... Bank. Amount sent: JPY 194,000, Deposit Amount NPR 215,388. Thank you-JME.', @MOBILE_NUMBER = '123213213', @PROCESS_ID = 'd65ba67f45634e788a2b0238e76d3b74::sendSms', @MT_ID = '2004230031231', @IS_SUCCESS = '1'
ALTER PROC PROC_SMS_LOG
(
	@FLAG VARCHAR(10)
	,@USER VARCHAR(50) = NULL
	,@ROW_ID BIGINT = NULL
	,@MOBILE_NUMBER VARCHAR(20) = NULL
	,@CONTROL_NO VARCHAR(30) = NULL
	,@PROCESS_ID VARCHAR(50) = NULL
	,@MSG_BODY NVARCHAR(700) = NULL
	,@STATUS VARCHAR(20) = NULL
	,@STATUS_DETAIL VARCHAR(100) = NULL
	,@MT_ID VARCHAR(50) = NULL
	,@CREATED_BY VARCHAR(50) = NULL
	,@IS_SUCCESS BIT = NULL
	,@sortBy VARCHAR(50) = NULL
	,@sortOrder	VARCHAR(5) = NULL
	,@pageSize INT = NULL
	,@pageNumber INT	= NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @errorMessage VARCHAR(MAX),
		@sql    VARCHAR(MAX)  
		,@table    VARCHAR(MAX)  
		,@select_field_list VARCHAR(MAX)  
		,@extra_field_list VARCHAR(MAX)  
		,@sql_filter  VARCHAR(MAX)  

	IF @FLAG = 'I'
	BEGIN
		INSERT INTO TBL_SMS_SEND_LOGS
		SELECT @MOBILE_NUMBER, @CONTROL_NO, @PROCESS_ID, @MSG_BODY, @USER, GETDATE(), @IS_SUCCESS, 'Pending', 'Status not sync', @MT_ID
	END
	ELSE IF @FLAG = 'U'
	BEGIN
		UPDATE TBL_SMS_SEND_LOGS SET [STATUS] = @STATUS, STATUS_DETAIL = @STATUS_DETAIL
		WHERE ROW_ID = @ROW_ID
	END
	ELSE IF @FLAG = 'CHECK'
	BEGIN
		IF NOT EXISTS (SELECT TOP 1 * FROM TBL_SMS_SEND_LOGS (NOLOCK) WHERE CONTROL_NO = @CONTROL_NO)
		BEGIN
			EXEC PROC_ERRORHANDLER 0, 'Success', NULL
			RETURN;
		END
		EXEC PROC_ERRORHANDLER 1, 'You can not send message more than once, please contact HQ!', NULL
	END
	ELSE IF @FLAG = 'S'
	BEGIN
		IF @sortBy IS NULL
		   SET @sortBy = 'CREATED_DATE'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'DESC'

		 SET @table = '(
						SELECT ROW_ID
							,MOBILE_NUMBER
							,CONTROL_NO
							,PROCESS_ID
							,MSG_BODY
							,CREATED_BY
							,CREATED_DATE
							,IS_SEND_SUCCESS = CASE WHEN IS_SEND_SUCCESS = 1 THEN ''Yes'' ELSE ''No'' END
							,[STATUS]
							,STATUS_DETAIL
							,MT_ID
					FROM TBL_SMS_SEND_LOGS (NOLOCK)
					WHERE 1 = 1
				)x'
	
		SET @sql_filter = ''

		IF @CONTROL_NO IS NOT NULL
			SET @sql_Filter += ' AND CONTROL_NO = '''+@CONTROL_NO+''''

		IF @CREATED_BY IS NOT NULL
			SET @sql_Filter += ' AND CREATED_BY = '''+@CREATED_BY+''''

		IF @MOBILE_NUMBER IS NOT NULL
			SET @sql_Filter += ' AND MOBILE_NUMBER = '''+@MOBILE_NUMBER+''''

		SET @select_field_list ='ROW_ID
							,MOBILE_NUMBER
							,CONTROL_NO
							,PROCESS_ID
							,MSG_BODY
							,CREATED_BY
							,CREATED_DATE
							,IS_SEND_SUCCESS
							,[STATUS]
							,STATUS_DETAIL
							,MT_ID'

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
	ELSE IF @FLAG = 'SMS'
	BEGIN
		SELECT 
			controlNo = dbo.FNADecryptString(trn.controlNo)
			,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
			,sContactNo = isnull(sen.mobile, cm.mobile)
		
			,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
		
			,trn.tAmt
			,trn.cAmt
			,trn.pAmt
			,trn.paymentMethod
			,pBankName = ISNULL(trn.pBankName, '[ANY WHERE] - ' + trn.pCountry)
			,trn.payoutCurr
		FROM vwRemitTran trn WITH(NOLOCK)
		INNER JOIN vwTranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		LEFT JOIN CUSTOMERMASTER CM(NOLOCK) ON CM.CUSTOMERID = SEN.CUSTOMERID
		INNER JOIN vwTranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
		WHERE trn.controlNo = dbo.fnaencryptstring(@CONTROL_NO)
	END
END 



