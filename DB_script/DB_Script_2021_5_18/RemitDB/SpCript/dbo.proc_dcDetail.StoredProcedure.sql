USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_dcDetail]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_dcDetail]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@dcDetailId						VARCHAR(30)		= NULL
	,@dcMasterId						INT				= NULL
	,@fromAmt                           MONEY			= NULL
	,@toAmt                             MONEY			= NULL
	,@serviceChargePcnt                 FLOAT			= NULL
	,@serviceChargeMinAmt               MONEY			= NULL
	,@serviceChargeMaxAmt				MONEY			= NULL
	,@sAgentCommPcnt					FLOAT			= NULL
	,@sAgentCommMinAmt					MONEY			= NULL
	,@sAgentCommMaxAmt					MONEY			= NULL
	,@ssAgentCommPcnt					FLOAT			= NULL
	,@ssAgentCommMinAmt					MONEY			= NULL
	,@ssAgentCommMaxAmt					MONEY			= NULL
	,@pAgentCommPcnt					FLOAT			= NULL
	,@pAgentCommMinAmt					MONEY			= NULL
	,@pAgentCommMaxAmt					MONEY			= NULL
	,@psAgentCommPcnt					FLOAT			= NULL
	,@psAgentCommMinAmt					MONEY			= NULL
	,@psAgentCommMaxAmt					MONEY			= NULL			
	,@bankCommPcnt						FLOAT			= NULL
	,@bankCommMinAmt					MONEY			= NULL
	,@bankCommMaxAmt					MONEY			= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)		
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
	SELECT
		 @ApprovedFunctionId = 20231230
		,@logIdentifier = 'dcDetailId'
		,@logParamMain = 'dcDetail'
		,@logParamMod = 'dcDetailHistory'
		,@module = '20'
		,@tableAlias = 'Default Domestic Commission Detail'
	
	
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM dcDetail
				WHERE dcMasterId = '+ CAST(ISNULL(@dcMasterId, 0) AS VARCHAR) + '					
				AND dcDetailId <> ' + CAST(ISNULL(@dcDetailId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @dcDetailId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@serviceChargeMaxAmt < @serviceChargeMinAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcDetailId
			RETURN	
		END
		IF(@sAgentCommMaxAmt < @sAgentCommMinAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcDetailId
			RETURN	
		END
		IF(@ssAgentCommMaxAmt < @ssAgentCommMinAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcDetailId
			RETURN	
		END
		IF(@pAgentCommMaxAmt < @pAgentCommMinAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcDetailId
			RETURN	
		END
		IF(@psAgentCommMaxAmt < @psAgentCommMinAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcDetailId
			RETURN	
		END
		IF(@bankCommMaxAmt < @bankCommMinAmt)
		BEGIN
			EXEC proc_errorHandler 0, 'Min Amount is greater than Max Amount!!!', @dcDetailId
			RETURN	
		END
	END	
	
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcMaster WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcMasterHistory WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcDetailId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO dcDetail (
				 dcMasterId
				,fromAmt
				,toAmt
				,serviceChargePcnt
				,serviceChargeMinAmt
				,serviceChargeMaxAmt
				,sAgentCommPcnt
				,sAgentCommMinAmt
				,sAgentCommMaxAmt
				,ssAgentCommPcnt
				,ssAgentCommMinAmt
				,ssAgentCommMaxAmt
				,pAgentCommPcnt
				,pAgentCommMinAmt
				,pAgentCommMaxAmt
				,psAgentCommPcnt
				,psAgentCommMinAmt
				,psAgentCommMaxAmt
				,bankCommPcnt
				,bankCommMinAmt
				,bankCommMaxAmt
				,createdBy
				,createdDate
			)
			SELECT
				 @dcMasterId
				,@fromAmt
				,@toAmt
				,@serviceChargePcnt
				,@serviceChargeMinAmt
				,@serviceChargeMaxAmt
				,@sAgentCommPcnt
				,@sAgentCommMinAmt
				,@sAgentCommMaxAmt
				,@ssAgentCommPcnt
				,@ssAgentCommMinAmt
				,@ssAgentCommMaxAmt
				,@pAgentCommPcnt
				,@pAgentCommMinAmt
				,@pAgentCommMaxAmt
				,@psAgentCommPcnt
				,@psAgentCommMinAmt
				,@psAgentCommMaxAmt
				,@bankCommPcnt
				,@bankCommMinAmt
				,@bankCommMaxAmt
				,@user
				,GETDATE()
				
			SET @dcDetailId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @dcDetailId
	END
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcDetailHistory WITH(NOLOCK)
				WHERE dcDetailId = @dcDetailId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM dcDetailHistory mode WITH(NOLOCK)
			INNER JOIN dcDetail main WITH(NOLOCK) ON mode.dcDetailId = main.dcDetailId
			WHERE mode.dcDetailId= @dcDetailId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM dcDetail WITH(NOLOCK) WHERE dcDetailId = @dcDetailId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcMaster WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcMasterHistory WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcDetail WITH(NOLOCK)
			WHERE dcDetailId = @dcDetailId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcDetailHistory WITH(NOLOCK)
			WHERE dcDetailId  = @dcDetailId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @dcDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcDetail WHERE approvedBy IS NULL AND dcDetailId  = @dcDetailId)			
			BEGIN				
				UPDATE dcDetail SET
				 dcMasterId				= @dcMasterId
				,fromAmt				= @fromAmt
				,toAmt					= @toAmt
				,serviceChargePcnt		= @serviceChargePcnt
				,serviceChargeMinAmt	= @serviceChargeMinAmt
				,serviceChargeMaxAmt	= @serviceChargeMaxAmt
				,sAgentCommPcnt			= @sAgentCommPcnt
				,sAgentCommMinAmt		= @sAgentCommMinAmt
				,sAgentCommMaxAmt		= @sAgentCommMaxAmt
				,ssAgentCommPcnt		= @ssAgentCommPcnt
				,ssAgentCommMinAmt		= @ssAgentCommMinAmt
				,ssAgentCommMaxAmt		= @ssAgentCommMaxAmt
				,pAgentCommPcnt			= @pAgentCommPcnt
				,pAgentCommMinAmt		= @pAgentCommMinAmt
				,pAgentCommMaxAmt		= @pAgentCommMaxAmt
				,psAgentCommPcnt		= @psAgentCommPcnt
				,psAgentCommMinAmt		= @psAgentCommMinAmt
				,psAgentCommMaxAmt		= @psAgentCommMaxAmt
				,bankCommPcnt			= @bankCommPcnt
				,bankCommMinAmt			= @bankCommMinAmt
				,bankCommMaxAmt			= @bankCommMaxAmt
				,modifiedBy				= @user
				,modifiedDate			= GETDATE()
			WHERE dcDetailId = @dcDetailId			
			END
			ELSE
			BEGIN
				DELETE FROM dcDetailHistory WHERE dcDetailId = @dcDetailId AND approvedBy IS NULL
				INSERT INTO dcDetailHistory(
					 dcDetailId
					,fromAmt
					,toAmt
					,serviceChargePcnt
					,serviceChargeMinAmt
					,serviceChargeMaxAmt
					,sAgentCommPcnt
					,sAgentCommMinAmt
					,sAgentCommMaxAmt
					,ssAgentCommPcnt
					,ssAgentCommMinAmt
					,ssAgentCommMaxAmt
					,pAgentCommPcnt
					,pAgentCommMinAmt
					,pAgentCommMaxAmt
					,psAgentCommPcnt
					,psAgentCommMinAmt
					,psAgentCommMaxAmt
					,bankCommPcnt
					,bankCommMinAmt
					,bankCommMaxAmt
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 @dcDetailId
					,@fromAmt
					,@toAmt
					,@serviceChargePcnt
					,@serviceChargeMinAmt
					,@serviceChargeMaxAmt
					,@sAgentCommPcnt
					,@sAgentCommMinAmt
					,@sAgentCommMaxAmt
					,@ssAgentCommPcnt
					,@ssAgentCommMinAmt
					,@ssAgentCommMaxAmt
					,@pAgentCommPcnt
					,@pAgentCommMinAmt
					,@pAgentCommMaxAmt
					,@psAgentCommPcnt
					,@psAgentCommMinAmt
					,@psAgentCommMaxAmt
					,@bankCommPcnt
					,@bankCommMinAmt
					,@bankCommMaxAmt
					,@user
					,GETDATE()
					,'U'

			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @dcDetailId
	END
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM dcMaster WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcMasterHistory WITH(NOLOCK)
			WHERE dcMasterId = @dcMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @dcDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcDetail WITH(NOLOCK)
			WHERE dcDetailId = @dcDetailId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @dcDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM dcDetailHistory  WITH(NOLOCK)
			WHERE dcDetailId = @dcDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @dcDetailId
			RETURN
		END
		SELECT @dcMasterId = dcMasterId FROM dcDetail WHERE dcDetailId = @dcDetailId
		IF EXISTS(SELECT 'X' FROM dcDetail WITH(NOLOCK) WHERE dcDetailId = @dcDetailId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM dcDetail WHERE dcDetailId = @dcDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcMasterId
			RETURN
		END
			INSERT INTO dcDetailHistory(
					 dcDetailId
					,fromAmt
					,toAmt
					,serviceChargePcnt
					,serviceChargeMinAmt
					,serviceChargeMaxAmt
					,sAgentCommPcnt
					,sAgentCommMinAmt
					,sAgentCommMaxAmt
					,ssAgentCommPcnt
					,ssAgentCommMinAmt
					,ssAgentCommMaxAmt
					,pAgentCommPcnt
					,pAgentCommMinAmt
					,pAgentCommMaxAmt
					,psAgentCommPcnt
					,psAgentCommMinAmt
					,psAgentCommMaxAmt
					,bankCommPcnt
					,bankCommMinAmt
					,bankCommMaxAmt
					,createdBy
					,createdDate
					,modType
				)
				SELECT
					 dcDetailId
					,fromAmt
					,toAmt
					,serviceChargePcnt
					,serviceChargeMinAmt
					,serviceChargeMaxAmt
					,sAgentCommPcnt
					,sAgentCommMinAmt
					,sAgentCommMaxAmt
					,ssAgentCommPcnt
					,ssAgentCommMinAmt
					,ssAgentCommMaxAmt
					,pAgentCommPcnt
					,pAgentCommMinAmt
					,pAgentCommMaxAmt
					,psAgentCommPcnt
					,psAgentCommMinAmt
					,psAgentCommMaxAmt
					,bankCommPcnt
					,bankCommMinAmt
					,bankCommMaxAmt
					,@user
					,GETDATE()					
					,'D'
				FROM dcDetail
				WHERE dcDetailId = @dcDetailId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @dcMasterId
	END


	ELSE IF @flag IN ('s', 'p')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'dcDetailId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 dcDetailId = ISNULL(mode.dcDetailId, main.dcDetailId)
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,serviceChargePcnt = ISNULL(mode.serviceChargePcnt, main.serviceChargePcnt)
					,serviceChargeMinAmt = ISNULL(mode.serviceChargeMinAmt, main.serviceChargeMinAmt)
					,serviceChargeMaxAmt = ISNULL(mode.serviceChargeMaxAmt, main.serviceChargeMaxAmt)
					,sAgentCommPcnt = ISNULL(mode.sAgentCommPcnt, main.sAgentCommPcnt)
					,sAgentCommMinAmt = ISNULL(mode.sAgentCommMinAmt, main.sAgentCommMinAmt)
					,sAgentCommMaxAmt = ISNULL(mode.sAgentCommMaxAmt, main.sAgentCommMinAmt)
					,ssAgentCommPcnt = ISNULL(mode.ssAgentCommPcnt, main.ssAgentCommPcnt)
					,ssAgentCommMinAmt = ISNULL(mode.ssAgentCommMinAmt, main.ssAgentCommMinAmt)
					,ssAgentCommMaxAmt = ISNULL(mode.ssAgentCommMaxAmt, main.ssAgentCommMinAmt)
					,pAgentCommPcnt = ISNULL(mode.pAgentCommPcnt, main.pAgentCommPcnt)
					,pAgentCommMinAmt = ISNULL(mode.pAgentCommMinAmt, main.pAgentCommMinAmt)
					,pAgentCommMaxAmt = ISNULL(mode.pAgentCommMaxAmt, main.pAgentCommMaxAmt)
					,psAgentCommPcnt = ISNULL(mode.psAgentCommPcnt, main.psAgentCommPcnt)
					,psAgentCommMinAmt = ISNULL(mode.psAgentCommMinAmt, main.psAgentCommMinAmt)
					,psAgentCommMaxAmt = ISNULL(mode.psAgentCommMaxAmt, main.psAgentCommMaxAmt)
					,bankCommPcnt = ISNULL(mode.bankCommPcnt, main.bankCommPcnt)
					,bankCommMinAmt = ISNULL(mode.bankCommMinAmt, main.bankCommMinAmt)
					,bankCommMaxAmt = ISNULL(mode.bankCommMaxAmt, main.bankCommMaxAmt)
					,main.createdBy
					,main.createdDate
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.dcDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM dcDetail main WITH(NOLOCK)
					LEFT JOIN dcDetailHistory mode ON main.dcDetailId = mode.dcDetailId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.dcMasterId = ' + CAST (@dcMasterId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''

		SET @select_field_list ='
			 dcDetailId
			,fromAmt
			,toAmt
			,serviceChargePcnt
			,serviceChargeMinAmt
			,serviceChargeMaxAmt
			,sAgentCommPcnt
			,sAgentCommMinAmt
			,sAgentCommMaxAmt
			,ssAgentCommPcnt
			,ssAgentCommMinAmt
			,ssAgentCommMaxAmt
			,pAgentCommPcnt
			,pAgentCommMinAmt
			,pAgentCommMaxAmt
			,psAgentCommPcnt
			,psAgentCommMinAmt
			,psAgentCommMaxAmt
			,bankCommPcnt
			,bankCommMinAmt
			,bankCommMaxAmt
			,createdBy
			,createdDate
			,modifiedBy
			,hasChanged 
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
	END
	ELSE IF @flag = 'reject'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcDetail WITH(NOLOCK)
			WHERE dcDetailId = @dcDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcDetail WITH(NOLOCK)
			WHERE dcDetailId = @dcDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM dcDetail WHERE approvedBy IS NULL AND dcDetailId = @dcDetailId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcDetailId
					RETURN
				END
			DELETE FROM dcDetail WHERE dcDetailId =  @dcDetailId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @dcDetailId
					RETURN
				END
				DELETE FROM dcDetailHistory WHERE dcDetailId = @dcDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @dcDetailId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM dcDetail WITH(NOLOCK)
			WHERE dcDetailId = @dcDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM dcDetail WITH(NOLOCK)
			WHERE dcDetailId = @dcDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @dcDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM dcDetail WHERE approvedBy IS NULL AND dcDetailId = @dcDetailId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM dcDetailHistory WHERE dcDetailId = @dcDetailId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE dcDetail SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE dcDetailId = @dcDetailId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcDetailId, @oldValue OUTPUT
				UPDATE main SET
					 main.fromAmt					= mode.fromAmt
					,main.toAmt						= mode.toAmt
					,main.serviceChargePcnt			= mode.serviceChargePcnt
					,main.serviceChargeMinAmt		= mode.serviceChargeMinAmt
					,main.serviceChargeMaxAmt		= mode.serviceChargeMaxAmt
					,main.sAgentCommPcnt			= mode.sAgentCommPcnt
					,main.sAgentCommMinAmt			= mode.sAgentCommMinAmt
					,main.sAgentCommMaxAmt			= mode.sAgentCommMaxAmt
					,main.ssAgentCommPcnt			= mode.ssAgentCommPcnt
					,main.ssAgentCommMinAmt			= mode.ssAgentCommMinAmt
					,main.ssAgentCommMaxAmt			= mode.ssAgentCommMaxAmt
					,main.pAgentCommPcnt			= mode.pAgentCommPcnt
					,main.pAgentCommMinAmt			= mode.pAgentCommMinAmt
					,main.pAgentCommMaxAmt			= mode.pAgentCommMaxAmt
					,main.psAgentCommPcnt			= mode.psAgentCommPcnt
					,main.psAgentCommMinAmt			= mode.psAgentCommMinAmt
					,main.psAgentCommMaxAmt			= mode.psAgentCommMaxAmt
					,main.bankCommPcnt				= mode.bankCommPcnt
					,main.bankCommMinAmt			= mode.bankCommMinAmt
					,main.bankCommMaxAmt			= mode.bankCommMaxAmt
					,main.modifiedDate				= GETDATE()
					,main.modifiedBy				= @user
				FROM dcDetail main
				INNER JOIN dcDetailHistory mode ON mode.dcDetailId = main.dcDetailId
				WHERE mode.dcDetailId = @dcDetailId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'dcDetail', 'dcDetailId', @dcDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @dcDetailId, @oldValue OUTPUT
				UPDATE dcDetail SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE dcDetailId = @dcDetailId
			END
			
			UPDATE dcDetailHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE dcDetailId = @dcDetailId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @dcDetailId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @dcDetailId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @dcDetailId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @dcDetailId
END CATCH


GO
