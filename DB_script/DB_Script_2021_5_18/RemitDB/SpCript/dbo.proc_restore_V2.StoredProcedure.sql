USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_restore_V2]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_restore_V2]
	 @flag			VARCHAR(50)
	,@user			VARCHAR(50) 
	,@provider		INT				= NULL
	,@agentName		VARCHAR(200)	= NULL
	,@agentNamee	INT = NULL
	,@xpin			VARCHAR(50)	= NULL
	,@sortBy		VARCHAR(50)= NULL
	,@sortOrder		VARCHAR(5)= NULL
	,@pageSize		INT	= NULL
	,@pageNumber	INT	= NULL
	
	
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE
	 @xpinEnc			VARCHAR(50) 
	,@sql				VARCHAR(MAX)	
	,@table				VARCHAR(MAX)
	,@select_field_list	VARCHAR(MAX)
	,@extra_field_list	VARCHAR(MAX)
	,@sql_filter		VARCHAR(MAX)
	,@xPressMoneyMapID INT = 25100000
	,@xPressMoneyMapID_Branch INT = 25100100 --Branch - Head office

IF @provider IS NULL AND @flag = 'S'
BEGIN
	IF @sortBy IS NULL SET @sortBy = 'provider'
	SET @table = '
		(
			SELECT
				rowId		= NULL
				,provider	= NULL 
				,agentName	= NULL 
				,xpin		= NULL  
				,customer	= NULL
				,beneficiary = NULL
				,customerAddress = NULL
				,beneficiaryAddress	= NULL
				,payoutAmount = NULL
				,payoutDate = NULL
			FROM xPressTranHistory  xp WITH(NOLOCK)
			WHERE 1 = 2	)X
		'
		
		SET @sql_filter = ''	
		
		SET @select_field_list ='
			 rowId
			,provider		
			,agentName 
			,xpin
			,customer
			,beneficiary
			,customerAddress
			,beneficiaryAddress
			,payoutAmount
			,payoutDate			
			'
		EXEC dbo.proc_paging
			 @table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber

	RETURN
END

ELSE IF @provider ='4909' AND @flag = 'S' ---->> xPress Money
BEGIN
	EXEC proc_xPressTranHistory @flag = 's'  ,@pageNumber = @pageNumber, @pageSize = @pageSize, @sortBy=@sortBy, @sortOrder=@sortOrder, @user = @user
	, @provider = 'xPress Money', @xpin = @xpin,@agentName = @agentName
	
	RETURN	
END
ELSE IF @provider ='4869' AND @flag = 'S' ---->> RIA FINANCIAL SERVICES
BEGIN
	EXEC proc_riaRemitPayHistory @flag = 's',@pageNumber = @pageNumber, @pageSize = @pageSize, @sortBy=@sortBy, @sortOrder=@sortOrder, @user = @user,
	@pIN = @xpin,@pAgentName = @agentName
	
	RETURN	
END
ELSE IF @provider ='4726' AND @flag = 'S'---->> EZREMIT Remit
BEGIN
	EXEC proc_ezPayHistory @flag = 's',@pageNumber = @pageNumber, @pageSize = @pageSize, @sortBy=@sortBy, @sortOrder=@sortOrder, @user = @user,
	@SecurityNumber = @xpin,@tbBranchName = @agentName	
	RETURN	
END 
ELSE IF @provider ='4734' AND @flag = 'S' ---->> Global IME Remit
BEGIN
	EXEC proc_globalBankPayHistory @flag = 's',@pageNumber = @pageNumber, @pageSize = @pageSize, @sortBy=@sortBy, @sortOrder=@sortOrder, @user = @user,
	@radNo = @xpin,@pAgentName = @agentName	
	RETURN	
END

ELSE IF @provider ='4670' AND @flag = 'S' ---->> Cash Express
BEGIN
	EXEC proc_cePayHistory_V2 @flag = 's',@pageNumber = @pageNumber, @pageSize = @pageSize, @sortBy=@sortBy, @sortOrder=@sortOrder, @user = @user,
	@ceNumber = @xpin,@pAgentName = @agentName	
	RETURN	
END

ELSE IF @provider ='4854' AND @flag = 'S' ---->> Money gram pay
BEGIN
	EXEC proc_mgPayHistory @flag = 's',@pageNumber = @pageNumber, @pageSize = @pageSize, @sortBy=@sortBy, @sortOrder=@sortOrder, @user = @user,
	@xpin = @xpin,@agentName = @agentNamee
	
	RETURN	
END

ELSE IF @provider ='4816' AND @flag = 'S' ---->> Instant Cash
BEGIN
	EXEC proc_instantCashPay @flag = 's',@pageNumber = @pageNumber, @pageSize = @pageSize, @sortBy=@sortBy, @sortOrder=@sortOrder, @user = @user,
	@xpin = @xpin,@agentName = @agentNamee
	
	RETURN	
END



GO
