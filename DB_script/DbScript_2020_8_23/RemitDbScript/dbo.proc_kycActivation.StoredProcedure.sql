USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_kycActivation]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_kycActivation]
	 @flag					varchar(50)
	,@user					varchar(30)			
	,@kycId					bigint 			= NULL
	,@remitCardNo			varchar(20) 	= NULL
AS 
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY

	DECLARE
		 @sql				VARCHAR(MAX)
		,@table				VARCHAR(MAX)

	IF @flag = 's'
	BEGIN
		SELECT
			 id = main.remitCardNo
			,[S.N.] = row_number()over(order by main.firstName)	
			,[IME Remit Card Number] = main.remitCardNo
			,[Customer Name] = isnull(' '+main.salutation,'')+' '+ isnull(' '+main.firstName,'')+ isnull(' '+main.middleName,'')+ isnull(' '+main.lastName,'')				
			,[Agent Name] = case when main.agentId is null then 'Head Office' else am.agentName END
			,[Created By] = main.createdBy
			,[Created Date] = main.createdDate	
			,[Approved By] = main.approvedBy
			,[Approved Date] = main.approvedDate
		FROM kycMaster main WITH(NOLOCK) 
		LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
		WHERE main.activatedDate IS NULL
		AND ISNULL(main.isDeleted,'N')<>'Y'
		AND ISNULL(main.isActivated,'N') = 'N'
		AND main.remitCardNo = ISNULL(@remitCardNo,main.remitCardNo)

		--FROM kycMaster main WITH(NOLOCK) 
		--LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
		--WHERE main.activatedDate IS NOT NULL
		--AND ISNULL(main.isDeleted,'N')<>'Y'
		--AND ISNULL(main.isActivated,'N') = 'Y'
		--AND main.remitCardNo = ISNULL(@remitCardNo,main.remitCardNo)
		ORDER BY main.firstName
	END
	IF @flag = 'activate'
	BEGIN	
		
		UPDATE kycMaster 
		SET isActivated = 'Y',
			activatedBy = @user, 
			activatedDate = Getdate() 
		WHERE remitCardNo = @remitCardNo	
		EXEC proc_errorHandler 0, 'IME Remit Card has been activated successfully.', @remitCardNo	
				
		-- ## Send SMS	
		DECLARE @mobile VARCHAR(10),@customerName varchar(500),@msg varchar(max)	
		select 
			@mobile = mobileP,
			@customerName = isnull(' '+main.salutation,'')+' '+ isnull(' '+main.firstName,'')+ isnull(' '+main.middleName,'')+ isnull(' '+main.lastName,'')
			from kycMaster main with(nolock) where remitCardNo = @remitCardNo
		IF @mobile <> '' OR @mobile IS NOT NULL or @customerName <> '' and @customerName is not null
        BEGIN
			SET @msg = 'Dear '+upper(@customerName)+', Your IME Remit Card No. '+@remitCardNo+' has been activated. Now you can send and receive money using your IME Remit Card. Thank You -IME, For further information, please contact: 01-4430600'
			INSERT INTO smsqueue(mobileNo,msg,createdDate,createdBy,country)
			SELECT @mobile,@msg,GETDATE(),@user,'Nepal'		 
		END
		
		RETURN;
	END

	IF @flag = 's_block'
	BEGIN
		SELECT
			 id = main.remitCardNo
			,[IME Remit Card Number] = main.remitCardNo
			,[Customer Name] = isnull(' '+main.salutation,'')+' '+ isnull(' '+main.firstName,'')+ isnull(' '+main.middleName,'')+ isnull(' '+main.lastName,'')				
			,[Agent Name] = case when main.agentId is null then 'Head Office' else am.agentName END
			,[Created By] = main.createdBy
			,[Created Date] = main.createdDate	
			,[Approved By] = main.approvedBy
			,[Approved Date] = main.approvedDate
			,[Activated By] = main.activatedBy
			,[Activated Date] = main.activatedDate
		FROM kycMaster main WITH(NOLOCK) 
		LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
		WHERE main.blockedDate is null
		AND ISNULL(main.isDeleted,'N')<>'Y'
		AND ISNULL(main.isDeleted,'N') = 'N'
		AND main.remitCardNo = @remitCardNo
	END
	IF @flag = 'u_block'
	BEGIN
		UPDATE kycMaster 
		SET isBlocked = 'Y',
			blockedBy = @user, 
			blockedDate = Getdate() 
		WHERE remitCardNo = @remitCardNo	
		EXEC proc_errorHandler 0, 'IME Remit Card has been blocked successfully.', @remitCardNo	
		RETURN;
	END
	IF @flag = 'pin_refresh'
	BEGIN
		SELECT
			 id = main.remitCardNo
			,[S.N.] = row_number()over(order by main.firstName)	
			,[IME Remit Card Number] = main.remitCardNo
			,[Customer Name] = isnull(' '+main.salutation,'')+' '+ isnull(' '+main.firstName,'')+ isnull(' '+main.middleName,'')+ isnull(' '+main.lastName,'')				
			,[Agent Name] = case when main.agentId is null then 'Head Office' else am.agentName END
			,[Created By] = main.createdBy
			,[Created Date] = main.createdDate	
			,[Approved By] = main.approvedBy
			,[Approved Date] = main.approvedDate
		FROM kycMaster main WITH(NOLOCK) 
		LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId
		WHERE main.activatedDate IS NOT NULL
		AND ISNULL(main.isDeleted,'N')<>'Y'
		AND ISNULL(main.isActivated,'N') = 'Y'
		AND main.remitCardNo = ISNULL(@remitCardNo,main.remitCardNo)
		ORDER BY main.firstName
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 errCode, ERROR_MESSAGE() + ERROR_LINE() mes, NULL id
END CATCH




GO
