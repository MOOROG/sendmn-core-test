USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ncellUpload]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	select * from ncellFreeSimCampaign
	DELETE FROM ncellFreeSimCampaign
*/

CREATE proc [dbo].[proc_ncellUpload]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@rowId								INT				= NULL
	,@filePath							VARCHAR(500)	= NULL

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
		,@logParamMain = 'ncellFreeSimCampaign'
		,@tableAlias = 'Ncell Free Sim Campaign'	
	

	IF @flag = 'mActivate'
	BEGIN
			IF EXISTS(SELECT 'x' FROM ncellFreeSimCampaign WITH(NOLOCK) 
						WHERE id=@rowid AND activatedDate IS NOT NULL AND rejectedDate IS NULL)
			BEGIN
					EXEC proc_errorHandler 1, 'Already Activated Record.', @rowId
					RETURN
			END
			BEGIN TRANSACTION
			UPDATE ncellFreeSimCampaign SET
				 activatedBy = @user
				,activatedDate= GETDATE()
				,rejectedBy=null
				,rejectedDate=null
			WHERE id = @rowId
			SET @modType = 'Activate'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to activate record.', @rowId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record activated successfully.', @rowId
	END
		
	ELSE IF @flag = 'mDocAck'
	BEGIN
			IF EXISTS(SELECT 'x' FROM ncellFreeSimCampaign WITH(NOLOCK) 
						WHERE id=@rowid AND docReceivedDate IS NOT NULL and rejectedDate is null)
			BEGIN
					EXEC proc_errorHandler 1, 'Already Received Document.', @rowId
					RETURN
			END
			BEGIN TRANSACTION
			UPDATE ncellFreeSimCampaign SET
				 docReceivedBy = @user
				,docReceivedDate  = GETDATE()
				,rejectedBy=null
				,rejectedDate=null
			WHERE id = @rowId
			SET @modType = 'Doc Received'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to Doc Receive record.', @rowId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record Document Received successfully.', @rowId
	END
	
	ELSE IF @flag = 'mDocSend'
	BEGIN
			IF EXISTS(SELECT 'x' FROM ncellFreeSimCampaign WITH(NOLOCK) 
						WHERE id=@rowid AND docSendDate IS NOT NULL and rejectedDate is null)
			BEGIN
					EXEC proc_errorHandler 1, 'Already Document Sent.', @rowId
					RETURN
			END
			
			BEGIN TRANSACTION
			UPDATE ncellFreeSimCampaign SET
				 docSendBy = @user
				,docSendDate= GETDATE()
				,rejectedBy=null
				,rejectedDate=null
			WHERE id = @rowId
			SET @modType = 'Document Send'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to Document Send.', @rowId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record Document Sent successfully.', @rowId
	END
	
	ELSE IF @flag = 'reject'
	BEGIN
		    BEGIN TRANSACTION
			UPDATE ncellFreeSimCampaign SET
				 rejectedBy = @user
				,rejectedDate= GETDATE()
			WHERE id = @rowId
			SET @modType = 'reject'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to Reject Record.', @rowId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		    EXEC proc_errorHandler 0, 'Record Rejected successfully.', @rowId
	END
	
	IF @flag='upload'
	BEGIN

		UPDATE SIMReceivedFromNcell_Temp
    			SET 
				ICCID=REPLACE(LTRIM(ICCID),'á',''),
				MOBILE=REPLACE(LTRIM(MOBILE),'á','')

		UPDATE SIMReceivedFromNcell_Temp
    			SET 
				ICCID=REPLACE((ICCID),' ',''),
				MOBILE=REPLACE((MOBILE),' ','')

		IF EXISTS(SELECT 'X' FROM SIMReceivedFromNcell_Temp WITH(NOLOCK) WHERE LEN(MOBILE)<>10) 
		BEGIN
			DELETE FROM SIMReceivedFromNcell_Temp
			SELECT 'Invalid Mobile Length!' AS remarks
			RETURN;
		END
		
		IF EXISTS(SELECT 'X' FROM SIMReceivedFromNcell_Temp 
				GROUP BY mobile
					HAVING COUNT(*)>1)
		BEGIN
			DELETE FROM SIMReceivedFromNcell_Temp
			SELECT 'Dublicate Mobile Number!' AS remarks
			RETURN;
		END
		
		IF EXISTS(SELECT 'X' FROM SIMReceivedFromNcell_Temp 
					GROUP BY iccId
					HAVING COUNT(*)>1)
		BEGIN
			DELETE FROM SIMReceivedFromNcell_Temp
			SELECT 'Dublicate ICCID Number!' AS remarks
			RETURN;
		END
		
		IF EXISTS(SELECT 'x' FROM SIMReceivedFromNcell_Temp a WITH(NOLOCK)  
			INNER JOIN SIMReceivedFromNcell b WITH(NOLOCK) ON a.mobile=b.mobile )
		BEGIN
			DELETE FROM SIMReceivedFromNcell_Temp
			SELECT 'Already Upload Some Mobile Number!' AS remarks
			RETURN;
		END
		IF EXISTS(SELECT 'x' FROM SIMReceivedFromNcell_Temp a 
			INNER JOIN SIMReceivedFromNcell b WITH(NOLOCK) ON a.iccid=b.iccid )
		BEGIN
			DELETE FROM SIMReceivedFromNcell_Temp
			SELECT 'Already Upload Some ICCID Number!' AS remarks
			RETURN;
		END

		INSERT INTO SIMReceivedFromNcell(iccId,mobile,createdBy,createdDate)
			SELECT ICCID,MOBILE,'admin',GETDATE() FROM SIMReceivedFromNcell_Temp

		DELETE FROM SIMReceivedFromNcell_Temp
		SELECT 'Upload Completed Sucessfully.' AS remarks	
	
	END
	
	IF @flag='uploadAgent'
	BEGIN

		UPDATE DistributionOfSIMToAgent_Temp
    			SET 
				agentId=REPLACE(LTRIM(agentId),'á',''),
				iccId=REPLACE(LTRIM(iccId),'á','')

		UPDATE DistributionOfSIMToAgent_Temp
    			SET 
				agentId=REPLACE((agentId),' ',''),
				iccId=REPLACE((iccId),' ','')
	
		IF EXISTS(SELECT 'X' FROM DistributionOfSIMToAgent_Temp 
					GROUP BY iccId
					HAVING COUNT(*)>1)
		BEGIN
			DELETE FROM DistributionOfSIMToAgent_Temp
			SELECT 'Dublicate ICCID Number!' AS remarks
			RETURN;
		END
				
		IF EXISTS(SELECT 'x' FROM DistributionOfSIMToAgent_Temp a 
			INNER JOIN DistributionOfSIMToAgent b WITH(NOLOCK) ON a.iccId=b.iccId )
		BEGIN
			DELETE FROM DistributionOfSIMToAgent_Temp
			SELECT 'Already Upload Some ICCID Number!' AS remarks
			RETURN;
		END
		IF EXISTS(SELECT 'X' FROM DistributionOfSIMToAgent_Temp 
			WHERE iccId NOT IN (SELECT iccId FROM SIMReceivedFromNcell WITH(NOLOCK)))
		BEGIN
			DELETE FROM DistributionOfSIMToAgent_Temp
			SELECT 'Invalid Some ICCID, Not In Stock!' AS remarks
			RETURN;
		END		
		
		IF EXISTS(SELECT 'X' FROM DistributionOfSIMToAgent_Temp 
			WHERE agentId NOT IN (SELECT agentId FROM agentMaster WITH(NOLOCK)))
		BEGIN
			DELETE FROM DistributionOfSIMToAgent_Temp
			SELECT 'Invalid Some Agent ID!' AS remarks
			RETURN;
		END		
		BEGIN TRANSACTION
		INSERT INTO DistributionOfSIMToAgent(agentId,iccId,mobile,createdBy,createdDate)
			SELECT agentId,a.iccId,b.mobile,@user,GETDATE() FROM DistributionOfSIMToAgent_Temp a with(nolock)
			inner join SIMReceivedFromNcell b on a.iccId=b.iccId

		DELETE FROM DistributionOfSIMToAgent_Temp	
		
		SET @modType = 'Upload'
		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to upload record.', @rowId
				DELETE FROM DistributionOfSIMToAgent_Temp
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION	
		
		SELECT 'Upload Completed Sucessfully.' AS remarks	
	
	END
		
	IF @flag='uploadActivate'
	BEGIN
		UPDATE SIMUpdate_Temp
    			SET 
				mobile=REPLACE(LTRIM(mobile),'á','')

		UPDATE SIMUpdate_Temp
    			SET 
				mobile=REPLACE((mobile),' ','')
	
		IF EXISTS(SELECT 'X' FROM SIMUpdate_Temp 
					GROUP BY mobile
					HAVING COUNT(*)>1)
		BEGIN
			DELETE FROM SIMUpdate_Temp
			SELECT 'Dublicate Mobile Number!' AS remarks
			RETURN;
		END
		
		IF EXISTS(SELECT 'X' FROM SIMUpdate_Temp 
			WHERE mobile NOT IN (SELECT mobileNo FROM NcellFreeSimCampaign WITH(NOLOCK)))
		BEGIN
			DELETE FROM SIMUpdate_Temp
			SELECT 'Invalid Some Mobile Number, System can not find the mobile number!' AS remarks
			RETURN;
		END		
		BEGIN TRANSACTION
		UPDATE NcellFreeSimCampaign SET 
				 activatedBy=@user
				,activatedDate=GETDATE()
				,rejectedBy=null
				,rejectedDate=null 
		FROM NcellFreeSimCampaign a,
		(
			SELECT mobile FROM SIMUpdate_Temp
		)b WHERE a.mobileNo=b.mobile and a.activatedDate is null

		DELETE FROM SIMUpdate_Temp
		SET @modType = 'Upload'
		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to upload record.', @rowId
				DELETE FROM SIMUpdate_Temp
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION	
		
		SELECT 'Upload Completed Sucessfully.' AS remarks
	
	END	
	
	IF @flag='uploadDocAck'
	BEGIN

		UPDATE SIMUpdate_Temp
    			SET 
				mobile=REPLACE(LTRIM(mobile),'á','')

		UPDATE SIMUpdate_Temp
    			SET 
				mobile=REPLACE((mobile),' ','')
	
		IF EXISTS(SELECT 'X' FROM SIMUpdate_Temp 
					GROUP BY mobile
					HAVING COUNT(*)>1)
		BEGIN
			DELETE FROM SIMUpdate_Temp
			SELECT 'Dublicate Mobile Number!' AS remarks
			RETURN;
		END
		IF EXISTS(SELECT 'X' FROM SIMUpdate_Temp 
			WHERE mobile NOT IN (SELECT mobileNo FROM NcellFreeSimCampaign WITH(NOLOCK) WHERE activatedDate IS NOT NULL))
		BEGIN
			DELETE FROM SIMUpdate_Temp
			SELECT 'Invalid Upload, Some Mobile Numbers Are Not Activated Or Not In Registered Yet!' AS remarks
			RETURN;
		END		
		
		BEGIN TRANSACTION
		UPDATE NcellFreeSimCampaign SET 
			 docReceivedBy=@user
			,docReceivedDate=GETDATE() 
			,rejectedBy=null
			,rejectedDate=null 
		FROM NcellFreeSimCampaign a,
		(
			SELECT mobile FROM SIMUpdate_Temp
		)b WHERE a.mobileNo=b.mobile and a.docReceivedDate is null

		DELETE FROM SIMUpdate_Temp
		SET @modType = 'Upload'
		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to upload record.', @rowId
				DELETE FROM SIMUpdate_Temp
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION	
		
		SELECT 'Upload Completed Sucessfully.' AS remarks
	
	END
	
	IF @flag='uploadDocSent'
	BEGIN

		UPDATE SIMUpdate_Temp
    			SET 
				mobile=REPLACE(LTRIM(mobile),'á','')

		UPDATE SIMUpdate_Temp
    			SET 
				mobile=REPLACE((mobile),' ','')
	
		IF EXISTS(SELECT 'X' FROM SIMUpdate_Temp 
					GROUP BY mobile
					HAVING COUNT(*)>1)
		BEGIN
			DELETE FROM SIMUpdate_Temp
			SELECT 'Dublicate Mobile Number!' AS remarks
			RETURN;
		END
		
		IF EXISTS(SELECT 'X' FROM SIMUpdate_Temp 
			WHERE mobile NOT IN (SELECT mobileNo FROM NcellFreeSimCampaign WITH(NOLOCK) WHERE docReceivedDate IS NOT NULL))
		BEGIN
			DELETE FROM SIMUpdate_Temp
			SELECT 'Invalid Upload, Some Documents Are Not Received Or Not In Registered Yet!' AS remarks
			RETURN;
		END		
		
		BEGIN TRANSACTION
		UPDATE NcellFreeSimCampaign SET 
				 docSendBy=@user
				,docSendDate=GETDATE() 
				,rejectedBy=null
				,rejectedDate=null 
		FROM NcellFreeSimCampaign a,
		(
			SELECT mobile FROM SIMUpdate_Temp
		)b WHERE a.mobileNo=b.mobile and a.docSendDate is null

		DELETE FROM SIMUpdate_Temp
		SET @modType = 'Upload'
		EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
		INSERT INTO #msg(errorCode, msg, id)
		EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
		IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
		BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to upload record.', @rowId
				DELETE FROM SIMUpdate_Temp
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION	
		
		SELECT 'Upload Completed Sucessfully.' AS remarks
	
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
