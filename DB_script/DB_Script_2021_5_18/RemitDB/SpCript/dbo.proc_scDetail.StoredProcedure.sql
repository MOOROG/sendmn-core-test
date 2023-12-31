USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_scDetail]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_scDetail]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@scDetailId						VARCHAR(30)		= NULL
	,@scMasterId						INT				= NULL
	,@oldScMasterId						INT				= NULL
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
		 @ApprovedFunctionId = 20131330
		,@logIdentifier = 'scDetailId'
		,@logParamMain = 'scDetail'
		,@logParamMod = 'scDetailHistory'
		,@module = '20'
		,@tableAlias = 'Custom Domestic Commission Detail'
	
	
	IF @flag IN ('i', 'u')
	BEGIN
		SET @sql = '
				SELECT 
					 fromAmt
					,toAmt  
				FROM scDetail
				WHERE scMasterId = '+ CAST(ISNULL(@scMasterId, 0) AS VARCHAR) + '					
				AND scDetailId <> ' + CAST(ISNULL(@scDetailId, 0) AS VARCHAR) + ' AND ISNULL(isDeleted, ''N'') <> ''Y''
				'
				
		DECLARE @success INT
		EXEC dbo.proc_CheckRange
			 @sql		= @sql
			,@from		= @fromAmt
			,@to		= @toAmt
			,@id		= @scDetailId
			,@success	= @success OUTPUT
			
		IF ISNULL(@success, 0) = 0
		RETURN
		
		IF(@serviceChargeMaxAmt < @serviceChargeMinAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Min Amount is greater than Max Amount!!!', @scDetailId
			RETURN	
		END
		IF(@sAgentCommMaxAmt < @sAgentCommMinAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Min Amount is greater than Max Amount!!!', @scDetailId
			RETURN	
		END
		IF(@ssAgentCommMaxAmt < @ssAgentCommMinAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Min Amount is greater than Max Amount!!!', @scDetailId
			RETURN	
		END
		IF(@pAgentCommMaxAmt < @pAgentCommMinAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Min Amount is greater than Max Amount!!!', @scDetailId
			RETURN	
		END
		IF(@psAgentCommMaxAmt < @psAgentCommMinAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Min Amount is greater than Max Amount!!!', @scDetailId
			RETURN	
		END
		IF(@bankCommMaxAmt < @bankCommMinAmt)
		BEGIN
			EXEC proc_errorHandler 1, 'Min Amount is greater than Max Amount!!!', @scDetailId
			RETURN	
		END
	END	
	
	ELSE IF @flag = 'cs'					--Copy Slab
	BEGIN
		IF EXISTS(SELECT 'X' FROM scDetail WITH(NOLOCK) WHERE ISNULL(isDeleted, 'N') = 'N' AND scMasterId = @scMasterId)
		BEGIN
			EXEC proc_errorHandler 1, 'Amount Slab already exists. Copy process terminated', @scMasterId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scDetail(
				 scMasterId
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
				 @scMasterId
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
			FROM scDetail WITH(NOLOCK) WHERE scMasterId = @oldScMasterId AND ISNULL(isDeleted, 'N') = 'N'	
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Copy has been done successfully.', @scMasterId	
	END
	
	IF @flag = 'i'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scMaster WITH(NOLOCK)
			WHERE scMasterId = @scMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scMasterHistory WITH(NOLOCK)
			WHERE scMasterId = @scMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scDetailId
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO scDetail (
				 scMasterId
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
				 @scMasterId
				,@fromAmt
				,@toAmt
				,ISNULL(@serviceChargePcnt, 0)
				,ISNULL(@serviceChargeMinAmt, 0)
				,ISNULL(@serviceChargeMaxAmt, 0)
				,ISNULL(@sAgentCommPcnt, 0)
				,ISNULL(@sAgentCommMinAmt, 0)
				,ISNULL(@sAgentCommMaxAmt, 0)
				,ISNULL(@ssAgentCommPcnt, 0)
				,ISNULL(@ssAgentCommMinAmt, 0)
				,ISNULL(@ssAgentCommMaxAmt, 0)
				,ISNULL(@pAgentCommPcnt, 0)
				,ISNULL(@pAgentCommMinAmt, 0)
				,ISNULL(@pAgentCommMaxAmt, 0)
				,ISNULL(@psAgentCommPcnt, 0)
				,ISNULL(@psAgentCommMinAmt, 0)
				,ISNULL(@psAgentCommMaxAmt, 0)
				,ISNULL(@bankCommPcnt, 0)
				,ISNULL(@bankCommMinAmt, 0)
				,ISNULL(@bankCommMaxAmt, 0)
				,@user
				,GETDATE()
				
			SET @scDetailId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @scDetailId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scDetailHistory WITH(NOLOCK)
				WHERE scDetailId = @scDetailId AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			SELECT
				mode.*
			FROM scDetailHistory mode WITH(NOLOCK)
			INNER JOIN scDetail main WITH(NOLOCK) ON mode.scDetailId = main.scDetailId
			WHERE mode.scDetailId= @scDetailId AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT * FROM scDetail WITH(NOLOCK) WHERE scDetailId = @scDetailId
		END
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scMaster WITH(NOLOCK)
			WHERE scMasterId = @scMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scMasterHistory WITH(NOLOCK)
			WHERE scMasterId = @scMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scDetail WITH(NOLOCK)
			WHERE scDetailId = @scDetailId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @scDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scDetailHistory WITH(NOLOCK)
			WHERE scDetailId  = @scDetailId AND (createdBy<> @user OR modType = 'delete')
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @scDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scDetail WHERE approvedBy IS NULL AND scDetailId  = @scDetailId)			
			BEGIN				
				UPDATE scDetail SET
				 scMasterId				= @scMasterId
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
			WHERE scDetailId = @scDetailId			
			END
			ELSE
			BEGIN
				DELETE FROM scDetailHistory WHERE scDetailId = @scDetailId AND approvedBy IS NULL
				INSERT INTO scDetailHistory(
					 scDetailId
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
					 @scDetailId
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
		EXEC proc_errorHandler 0, 'Record updated successfully.', @scDetailId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM scMaster WITH(NOLOCK)
			WHERE scMasterId = @scMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scMasterHistory WITH(NOLOCK)
			WHERE scMasterId = @scMasterId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. You are trying to perform an illegal operation.', @scDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scDetail WITH(NOLOCK)
			WHERE scDetailId = @scDetailId  AND (createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> You are trying to perform an illegal operation.</center>', @scDetailId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM scDetailHistory  WITH(NOLOCK)
			WHERE scDetailId = @scDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not delete this record. <br /> Previous modification has not been approved yet.</center>',  @scDetailId
			RETURN
		END
		SELECT @scMasterId = scMasterId FROM scDetail WHERE scDetailId = @scDetailId
		IF EXISTS(SELECT 'X' FROM scDetail WITH(NOLOCK) WHERE scDetailId = @scDetailId AND createdBy = @user AND approvedBy IS NULL)
		BEGIN
			DELETE FROM scDetail WHERE scDetailId = @scDetailId
			EXEC proc_errorHandler 0, 'Record deleted successfully.', @scMasterId
			RETURN
		END
			INSERT INTO scDetailHistory(
					 scDetailId
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
					 scDetailId
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
				FROM scDetail
				WHERE scDetailId = @scDetailId
			SET @modType = 'delete'		

		EXEC proc_errorHandler 0, 'Record deleted successfully.', @scMasterId
	END

/*
EXEC proc_scDetail @flag = 's', @scMasterId = 5 , @user = 'admin', @pageNumber = '1', @pageSize='100', @sortBy='fromAmt', @sortOrder='ASC'
*/
	ELSE IF @flag IN ('s', 'p')
	BEGIN
		---IF @sortBy IS NULL
			SET @sortBy = 'fromAmt'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT
					 scDetailId = ISNULL(mode.scDetailId, main.scDetailId)
					,fromAmt = ISNULL(mode.fromAmt, main.fromAmt)
					,toAmt = ISNULL(mode.toAmt, main.toAmt)
					,serviceChargePcnt		= CASE WHEN ISNULL(mode.serviceChargePcnt, main.serviceChargePcnt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.serviceChargePcnt, main.serviceChargePcnt) AS VARCHAR) END
					,serviceChargeMinAmt	= CASE WHEN ISNULL(mode.serviceChargeMinAmt, main.serviceChargeMinAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.serviceChargeMinAmt, main.serviceChargeMinAmt) AS VARCHAR) END
					,serviceChargeMaxAmt	= CASE WHEN ISNULL(mode.serviceChargeMaxAmt, main.serviceChargeMaxAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.serviceChargeMaxAmt, main.serviceChargeMaxAmt) AS VARCHAR) END
					,sAgentCommPcnt			= CASE WHEN ISNULL(mode.sAgentCommPcnt, main.sAgentCommPcnt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.sAgentCommPcnt, main.sAgentCommPcnt) AS VARCHAR) END
					,sAgentCommMinAmt		= CASE WHEN ISNULL(mode.sAgentCommMinAmt, main.sAgentCommMinAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.sAgentCommMinAmt, main.sAgentCommMinAmt) AS VARCHAR) END
					,sAgentCommMaxAmt		= CASE WHEN ISNULL(mode.sAgentCommMaxAmt, main.sAgentCommMaxAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.sAgentCommMaxAmt, main.sAgentCommMaxAmt) AS VARCHAR) END
					,ssAgentCommPcnt		= CASE WHEN ISNULL(mode.ssAgentCommPcnt, main.ssAgentCommPcnt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.ssAgentCommPcnt, main.ssAgentCommPcnt) AS VARCHAR) END
					,ssAgentCommMinAmt		= CASE WHEN ISNULL(mode.ssAgentCommMinAmt, main.ssAgentCommMinAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.ssAgentCommMinAmt, main.ssAgentCommMinAmt) AS VARCHAR) END
					,ssAgentCommMaxAmt		= CASE WHEN ISNULL(mode.ssAgentCommMaxAmt, main.ssAgentCommMaxAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.ssAgentCommMaxAmt, main.ssAgentCommMaxAmt) AS VARCHAR) END
					,pAgentCommPcnt			= CASE WHEN ISNULL(mode.pAgentCommPcnt, main.pAgentCommPcnt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.pAgentCommPcnt, main.pAgentCommPcnt) AS VARCHAR) END
					,pAgentCommMinAmt		= CASE WHEN ISNULL(mode.pAgentCommMinAmt, main.pAgentCommMinAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.pAgentCommMinAmt, main.pAgentCommMinAmt) AS VARCHAR) END
					,pAgentCommMaxAmt		= CASE WHEN ISNULL(mode.pAgentCommMaxAmt, main.pAgentCommMaxAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.pAgentCommMaxAmt, main.pAgentCommMaxAmt) AS VARCHAR) END
					,psAgentCommPcnt		= CASE WHEN ISNULL(mode.psAgentCommPcnt, main.psAgentCommPcnt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.psAgentCommPcnt, main.psAgentCommPcnt) AS VARCHAR) END
					,psAgentCommMinAmt		= CASE WHEN ISNULL(mode.psAgentCommMinAmt, main.psAgentCommMinAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.psAgentCommMinAmt, main.psAgentCommMinAmt) AS VARCHAR) END
					,psAgentCommMaxAmt		= CASE WHEN ISNULL(mode.psAgentCommMaxAmt, main.psAgentCommMaxAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.psAgentCommMaxAmt, main.psAgentCommMaxAmt) AS VARCHAR) END
					,bankCommPcnt			= CASE WHEN ISNULL(mode.bankCommPcnt, main.bankCommPcnt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.bankCommPcnt, main.bankCommPcnt) AS VARCHAR) END
					,bankCommMinAmt			= CASE WHEN ISNULL(mode.bankCommMinAmt, main.bankCommMinAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.bankCommMinAmt, main.bankCommMinAmt) AS VARCHAR) END
					,bankCommMaxAmt			= CASE WHEN ISNULL(mode.bankCommMaxAmt, main.bankCommMaxAmt) = 0 THEN ''-'' ELSE CAST(ISNULL(mode.bankCommMaxAmt, main.bankCommMaxAmt) AS VARCHAR) END
					,main.createdBy
					,main.createdDate
					,modifiedBy = CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE mode.createdBy END
					,modifiedDate = CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE mode.createdDate END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.scDetailId IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM scDetail main WITH(NOLOCK)
					LEFT JOIN scDetailHistory mode ON main.scDetailId = mode.scDetailId AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE main.scMasterId = ' + CAST (@scMasterId AS VARCHAR) + ' AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						--AND NOT(ISNULL(mode.modType, '''') = ''D'' AND mode.createdBy = ''' + @user + ''')
			) x'
			
		SET @sql_filter = ''
	

		SET @select_field_list ='
			 scDetailId
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
			SELECT 'X' FROM scDetail WITH(NOLOCK)
			WHERE scDetailId = @scDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scDetail WITH(NOLOCK)
			WHERE scDetailId = @scDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scDetailId
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM scDetail WHERE approvedBy IS NULL AND scDetailId = @scDetailId)
		BEGIN --New record
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scDetailId
					RETURN
				END
			DELETE FROM scDetail WHERE scDetailId =  @scDetailId
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			BEGIN TRANSACTION
				SET @modType = 'Reject'
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scDetailId, @oldValue OUTPUT
				INSERT INTO #msg(errorCode, msg, id)
				EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scDetailId, @user, @oldValue, @newValue
				IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
				BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to reject the transaction.', @scDetailId
					RETURN
				END
				DELETE FROM scDetailHistory WHERE scDetailId = @scDetailId AND approvedBy IS NULL
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		END
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @scDetailId
	END

	ELSE IF @flag = 'approve'
	BEGIN
		IF NOT EXISTS (
			SELECT 'X' FROM scDetail WITH(NOLOCK)
			WHERE scDetailId = @scDetailId
		)
		AND
		NOT EXISTS (
			SELECT 'X' FROM scDetail WITH(NOLOCK)
			WHERE scDetailId = @scDetailId AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>Modification approval is not pending.</center>', @scDetailId
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM scDetail WHERE approvedBy IS NULL AND scDetailId = @scDetailId )
				SET @modType = 'I'
			ELSE
				SELECT @modType = modType FROM scDetailHistory WHERE scDetailId = @scDetailId AND approvedBy IS NULL
			IF @modType = 'I'
			BEGIN --New record
				UPDATE scDetail SET
					isActive = 'Y'
					,approvedBy = @user
					,approvedDate= GETDATE()
				WHERE scDetailId = @scDetailId
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'U'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scDetailId, @oldValue OUTPUT
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
				FROM scDetail main
				INNER JOIN scDetailHistory mode ON mode.scDetailId = main.scDetailId
				WHERE mode.scDetailId = @scDetailId AND mode.approvedBy IS NULL

				EXEC [dbo].proc_GetColumnToRow  'scDetail', 'scDetailId', @scDetailId, @newValue OUTPUT
			END
			ELSE IF @modType = 'D'
			BEGIN
				EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @scDetailId, @oldValue OUTPUT
				UPDATE scDetail SET
					 isDeleted = 'Y'
					,modifiedDate = GETDATE()
					,modifiedBy = @user					
				WHERE scDetailId = @scDetailId
			END
			
			UPDATE scDetailHistory SET
				 approvedBy = @user
				,approvedDate = GETDATE()
			WHERE scDetailId = @scDetailId AND approvedBy IS NULL
			
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @scDetailId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Could not approve the changes.', @scDetailId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @scDetailId
	END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @scDetailId
END CATCH


GO
