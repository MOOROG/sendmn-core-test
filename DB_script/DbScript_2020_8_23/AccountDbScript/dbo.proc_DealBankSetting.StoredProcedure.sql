USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_DealBankSetting]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC  [dbo].[proc_DealBankSetting] (
@Flag		 VARCHAR(30)  = NULL
,@BankName	 VARCHAR(100) = NULL
,@SellAccNo	 VARCHAR(15)  = NULL
,@BuyAccNo   VARCHAR(15)  = NULL
,@User		 VARCHAR(150) = NULL
,@rowID		 VARCHAR(25)  = NULL
,@sortBy     VARCHAR(50)  = NULL
,@sortOrder  VARCHAR(5)	  = NULL
,@pageSize   INT		  = NULL
,@pageNumber INT		  = NULL
,@nameOfPartner		VARCHAR(100) = NULL
,@receiveUSDNostro	VARCHAR(50)	= NULL
,@receiveUSDCorrespondent	VARCHAR(50)= NULL
,@Settle_PayCurr INT	 = NULL
)

AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE
		 @sql				VARCHAR(MAX)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)	
		
		

IF @Flag = 'i'
BEGIN
	INSERT INTO DealBankSetting(BankName,SellAcNo,BuyAcNo,CreatedBy,CreatedDate,Settle_PayCurr) 
	VALUES(@BankName,@SellAccNo,@BuyAccNo,@User,GETDATE(),@Settle_PayCurr)

	EXEC proc_errorHandler 0,'Record Saved Successfully', null  RETURN
END

ELSE IF @Flag = 'u'
BEGIN 
	UPDATE DealBankSetting SET BankName = @BankName, SellAcNo = @SellAccNo, BuyAcNo = @BuyAccNo
		, ModifyBy = @User, ModifyDate = GETDATE(),Settle_PayCurr = @Settle_PayCurr
	WHERE RowId = @rowID
	EXEC proc_errorHandler 0,'Record updated successfully.', @rowID
END

ELSE IF @Flag = 'u-payoutAcc'
BEGIN 
	UPDATE tblPayoutAgentAccount SET nameOfPartner = @nameOfPartner
		, receiveUSDNostro			= @receiveUSDNostro
		, receiveUSDCorrespondent	= @receiveUSDCorrespondent
	WHERE rowId = @rowID
	EXEC proc_errorHandler 0,'Record updated successfully.', @rowID
END

ELSE IF @Flag = 's-payoutAcc'
BEGIN 
	SELECT T.rowId, T.nameOfPartner, T.receiveUSDNostro, T.receiveUSDCorrespondent,
		ACC1 = A.acct_num + ' | ' + A.acct_name,
		ACC2 = B.acct_num + ' | ' + B.acct_name
	FROM tblPayoutAgentAccount T(NOLOCK)
	LEFT JOIN ac_master A(NOLOCK) ON A.acct_num = T.receiveUSDNostro
	LEFT JOIN ac_master B(NOLOCK) ON B.acct_num = T.receiveUSDCorrespondent
	WHERE rowId = @rowID
	EXEC proc_errorHandler 0,'Record updated successfully.', @rowID
END

ELSE IF @Flag = 's'
BEGIN
	SET @table = '(SELECT rowId,BankName,SellAcNo,BuyAcNo,CreatedBy,CreatedDate FROM DealBankSetting (nolock) WHERE 1=1)x'
	

	IF @sortBy IS NULL
		SET @sortBy = 'rowId'
	IF @sortOrder IS NULL
		SET @sortOrder = 'ASC'

	SET @sql_filter = ''

    IF @BankName IS NOT NULL
		SET @sql_filter = @sql_filter + ' AND BankName LIKE ''%' + @BankName + '%'''

	SET @select_field_list ='rowId,BankName,SellAcNo,BuyAcNo,CreatedBy,CreatedDate'
			
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

ELSE IF @Flag = 'sById'
BEGIN
	SELECT rowId,BankName, dbs.SellAcNo,dbs.BuyAcNo
	,dbs.SellAcNo +' | '+ s.acct_name AS SellAcName
	,dbs.BuyAcNo +' | '+ a.acct_name AS BuyAcName
	,dbs.Settle_PayCurr
	FROM DealBankSetting dbs (nolock)
	INNER JOIN ac_master a(nolock) ON a.acct_num = dbs.BuyAcNo
	INNER JOIN ac_master s(nolock) ON s.acct_num = dbs.SellAcNo
	WHERE dbs.RowId = @rowID
END 




GO
