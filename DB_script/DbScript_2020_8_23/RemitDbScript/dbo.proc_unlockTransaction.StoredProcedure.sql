USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_unlockTransaction]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_unlockTransaction] 	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@tranIds			VARCHAR(MAX)	= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
AS

/*
EXEC proc_unlockTransaction @flag = 'dom_unpaid_ac',@controlNo=null
*/

DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @controlNoEncrypted VARCHAR(100)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(UPPER(@controlNo))
	

IF @flag = 's'  --Select Locked Transactions
BEGIN	
	SET @table = '(
				SELECT 
					 trn.id
					,controlNo = ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.FNADecryptString(trn.controlNo) + '''''')">'' + dbo.FNADecryptString(trn.controlNo) + ''</a>''
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
					,trn.pAmt
					,trn.lockedDate
					,trn.lockedBy
					,lockedDuration = DATEDIFF(MI, trn.lockedDate, GETDATE())
				FROM remitTran trn WITH(NOLOCK)
				LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
				LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
				WHERE trn.tranStatus = ''Lock''
					AND DATEDIFF(MI, trn.lockedDate, GETDATE()) > 1
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
				,pAmt
				,lockedDate
				,lockedBy
				,lockedDuration			
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

IF @flag = 'u'
BEGIN
	
	DECLARE @sql VARCHAR(MAX) 
	SET @sql = 'UPDATE remitTran SET 
					 tranStatus = ''Payment''
					,payTokenId = NULL
				WHERE id IN (' + @tranIds + ')
				'	
	EXEC(@sql)	
	
	EXEC proc_errorHandler 0, 'Transaction(s) unlocked successfully', NULL
END

IF @flag = 'ut'	--Unlock By Transaction
BEGIN
	UPDATE remitTran SET
		 tranStatus = 'Payment'
		,payTokenId = NULL
	WHERE controlNo = dbo.FNAEncryptString(UPPER(@controlNo))
	
	EXEC proc_errorHandler 0, 'Transaction unlocked successfully', NULL
END

IF @flag = 'dom_unpaid_ac'  --Domestic Unpaid Transaction
BEGIN	

	SET @table = '
				SELECT 
					 [Tran Id] = trn.id
					,[Control No] = ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.FNADecryptString(trn.controlNo) + '''''')">'' + dbo.FNADecryptString(trn.controlNo) + ''</a>''
					,[Payout Amount] = trn.pAmt
					,[Sending Country] = sen.country
					,[Sender Name] = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')
					,[Receiver Name] = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
					,[Locked Date] = trn.lockedDate
					,[Locked By] = trn.lockedBy
					,[Locked </br> Duration] = DATEDIFF(MI, trn.lockedDate, GETDATE())
				FROM remitTran trn WITH(NOLOCK)
				LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
				LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
				WHERE trn.tranStatus = ''Lock'' and trn.tranType = ''D''
				--AND DATEDIFF(MI, trn.lockedDate, GETDATE()) > 1
			'
	
	Exec(@table)		
	
END

IF @flag = 'unlock'	--Unlock By Transaction
BEGIN
	IF RIGHT(@controlNo, 1) = 'D'
	BEGIN
		UPDATE remitTran SET
			 tranStatus		= 'Payment'
			,payTokenId		= NULL
		WHERE controlNo = @controlNoEncrypted
	END
	ELSE
	BEGIN
		UPDATE dbo.remitTran SET
			 lockStatus		= 'unlocked'
		WHERE controlNo = @controlNoEncrypted
	END	
	EXEC proc_errorHandler 0, 'Transaction unlocked successfully', NULL
END

IF @flag = 'lockIntl'  --International Lock Transaction
BEGIN	

	SET @table = '
				SELECT 
					 [Tran Id] = trn.id
					,[Control No] = ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + dbo.FNADecryptString(trn.controlNo) + '''''')">'' + dbo.FNADecryptString(trn.controlNo) + ''</a>''
					,[Payout Amount] = trn.pAmt
					,[Sending Country] = sen.country
					,[Sender Name] = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')
					,[Receiver Name] = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
					,[Locked Date] = trn.lockedDate
					,[Locked By] = trn.lockedBy
					,[Locked </br> Duration] = DATEDIFF(MI, trn.lockedDate, GETDATE())
				FROM remitTran trn WITH(NOLOCK)
				LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
				LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
				WHERE trn.lockStatus = ''Lock'' 
			'	
	Exec(@table)		
	
END




GO
