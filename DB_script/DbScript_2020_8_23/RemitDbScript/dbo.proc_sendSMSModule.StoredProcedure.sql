USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendSMSModule]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_sendSMSModule]
 	 @flag					VARCHAR(50)		= NULL
	,@user                  VARCHAR(30)		= NULL
	,@rowId					INT				= NULL
	,@xml					XML				= NULL
	,@msg					VARCHAR(MAX)	= NULL

AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMain		VARCHAR(100)
		,@modType			VARCHAR(6)
	SELECT
		 @logIdentifier = 'id'
		,@logParamMain = 'SMSQueue'
		,@tableAlias = 'SMSQueue'	
	

	
	IF @flag='sms'
	BEGIN
		
		declare @tempTbl table(mobile varchar(50))
		INSERT @tempTbl(mobile)
		SELECT
			  p.value('@id','VARCHAR(50)')
		FROM @xml.nodes('/root/row') as tmp(p)



		UPDATE @tempTbl
    			SET 
				mobile=REPLACE(LTRIM(mobile),'á','')

		UPDATE @tempTbl
    			SET 
				mobile=REPLACE((mobile),' ','')
	
		IF EXISTS(SELECT 'X' FROM @tempTbl 
					GROUP BY mobile
					HAVING COUNT(*)>1)
		BEGIN
			SELECT 'Dublicate Mobile Number!' AS remarks
			RETURN;
		END
		--select * from @tempTbl
		--return;
		BEGIN TRANSACTION
		INSERT INTO SMSQueue(mobileNo,msg,createdBy,createdDate,country)
		SELECT mobile,@msg,@user,GETDATE(),'Manual Sent' FROM @tempTbl
		
		SET @modType = 'Upload'
		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to upload record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION	
		
		SELECT 'SMS Send Upload Completed Sucessfully.' AS remarks	
	
	END
		
	
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @rowId
END CATCH



GO
