USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_LockUnlockTransaction]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC proc_loclUnlockTransaction @flag = 'st', @controlNo = '91598256530'
SELECT * FROM remitTran where controlNo = '91181462426'


select * from staticDataValue where typeid in (5400, 5500)

*/

CREATE PROC [dbo].[proc_LockUnlockTransaction] 	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@tranId			INT				= NULL
	,@comments			VARCHAR(MAX)	= NULL	
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
AS

	DECLARE 
		 @select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)

	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @controlNoEncrypted VARCHAR(100)
	SET @controlNo = UPPER(LTRIM(RTRIM(@controlNo)))
	SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

	--EXEC proc_LockUnlockTransaction @flag = 'b'  ,@pageNumber='1', @pageSize='10', @sortBy='controlNo', @sortOrder='ASC', @user = 'admin'

IF @flag = 'b'
BEGIN	
	SET @table = '(
				SELECT 
					 trn.id
					 , controlNo = dbo.FNADecryptString(controlNo)
					, controlNo1 = ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId=''+CAST(trn.id AS VARCHAR)+'''''')">''+dbo.FNADecryptString(controlNo)+''</a>''
					,sCustomerId = sen.customerId
					,senderName = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')
					,sCountryName = sen.country
					,sStateName = sen.state
					,sCity = sen.city
					,sAddress = sen.address
					,rCustomerId = rec.customerId
					,receiverName = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
					,rCountryName = rec.country
					,rStateName = rec.state
					,rCity = rec.city
					,rAddress = rec.address
					,sAgentName = trn.sAgentName
				FROM remitTran trn WITH(NOLOCK)
				LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
				LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
				WHERE trn.tranStatus = ''Block'' 
			'
	
	SET @sql_filter = ''
	
	IF @controlNo IS NOT NULL
		SET @table = @table + ' AND trn.controlNo = ''' + @controlNoEncrypted + '''' 
	
			
	SET @select_field_list ='
				 id
				,controlNo
				,sCustomerId
				,senderName
				,sCountryName
				,sStateName
				,sCity
				,sAddress
				,rCustomerId
				,receiverName
				,rCountryName
				,rStateName
				,rCity
				,rAddress	
				,sAgentName		
				,controlNo1	
			   '
	SET @table = @table + ') x'
			
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

ELSE IF @flag = 'lt'
BEGIN

     IF NOT EXISTS (SELECT 'X' FROM remitTran WITH (NOLOCK)
			  WHERE controlNo = @controlNoEncrypted)
    BEGIN
	   
			 EXEC proc_errorHandler 1, 'Transaction not found', @controlNo
			 IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
			 RETURN;
    END
    IF @comments IS NULL
    BEGIN	   
		EXEC proc_errorHandler 1, 'Comment can not be blank.', @tranId
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
		RETURN;
    END
    
BEGIN TRANSACTION


    UPDATE remitTran SET
		 blockedBy = @user
		,tranStatus = 'Block'
		,blockedDate = GETDATE()
	WHERE controlNo = @controlNoEncrypted
    
     --comments
     SELECT @tranId = id FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
     EXEC proc_transactionLogs @flag='i', @user=@user, @tranId=@tranId, @message=@comments,@controlNo=@controlNoEncrypted
		

	COMMIT TRANSACTION	
	EXEC proc_errorHandler 0, 'Transaction blocked successfully.', @tranId   
	
	EXEC proc_addCommentAPI @flag = 'i', @controlNo = @controlNo, @user = @user, @message = @comments, @agentRefId = NULL 



END
ELSE IF @flag = 'ut'
BEGIN

    IF NOT EXISTS (SELECT 'X' FROM remitTran WITH (NOLOCK)
			  WHERE controlNo = @controlNoEncrypted and tranStatus='Block' and payStatus='Unpaid')
    BEGIN	   
		EXEC proc_errorHandler 1, 'Blocked Transaction not found', @controlNo
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
		 RETURN;
    END
    
    IF @comments IS NULL
    BEGIN	  
		EXEC proc_errorHandler 1, 'Comment can not be blank.', @tranId
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
		RETURN;
    END

BEGIN TRANSACTION

	UPDATE remitTran SET 
		 modifiedBy = @user
		,tranStatus = 'Payment'
		,modifiedDate = GETDATE()
		,modifiedDateLocal = DBO.FNADateFormatTZ(GETDATE(), @user)
	WHERE controlNo = @controlNoEncrypted
	AND tranStatus='Block' AND payStatus='Unpaid'

	 --comments
	 SELECT @tranId = id FROM remitTran WITH(NOLOCK) WHERE controlNo = @controlNoEncrypted
	 EXEC proc_transactionLogs @flag='i', @user=@user, @tranId=@tranId, @message=@comments, @controlNo=@controlNoEncrypted
	 
	COMMIT TRANSACTION
	
	EXEC proc_errorHandler 0, 'Transaction unlocked successfully.', @tranId   

END




GO
