USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_externalBank]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_externalBank]

	 @flag							VARCHAR(50)		=	NULL
	,@user                          VARCHAR(30)		=	NULL
	,@extBankId						INT				=	NULL
	,@bankName						VARCHAR(250)	=	NULL
	,@bankCode						VARCHAR(50)		=	NULL
	,@country						VARCHAR(50)		=	NULL
	,@address						VARCHAR(500)	=	NULL
	,@phone							VARCHAR(20)		=	NULL
	,@fax							VARCHAR(20)		=	NULL
	,@email							VARCHAR(100)	=	NULL
	,@contactPerson					VARCHAR(100)	=	NULL
	,@swiftCode						VARCHAR(50)		=	NULL
	,@routingCode					VARCHAR(50)		=	NULL
	,@externalCode					VARCHAR(50)		=	NULL
	,@internalCode					VARCHAR(50)		=	NULL
	,@domInternalCode				VARCHAR(50)		=	NULL
	,@externalBankType				INT				=	NULL
	,@IsBranchSelectionRequired		VARCHAR(20)		=	NULL
	,@receivingMode					INT				=	NULL
	,@isDeleted						CHAR(1)			=	NULL
	,@createdDate					DATETIME		=	NULL
	,@createdBy						VARCHAR(100)	=	NULL
	,@modifiedDate					DATETIME		=	NULL
	,@modifiedBy					varchar(100)	=	NULL
	,@sortBy                        VARCHAR(50)		=	NULL
	,@sortOrder                     VARCHAR(5)		=	NULL
	,@pageSize                      INT				=	NULL
	,@pageNumber                    INT				=	NULL
	,@isBlocked						varchar(20)		=	NULL


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
		,@modType			VARCHAR(6)
		
	SELECT
		 @logIdentifier = 'extBankId'
		,@tableAlias = ' External Bank'	

	IF @flag = 'i'
	BEGIN
	--alter table externalBank add isBlocked char(1)
		BEGIN TRANSACTION
			INSERT INTO externalBank (
					 bankName						
					,bankCode					
					,country						
					,address							
					,phone							
					,fax								
					,email							
					,contactPerson					
					,swiftCode						
					,routingCode						
					,externalCode
					,internalCode					
					,externalBankType				
					,IsBranchSelectionRequired		
					,receivingMode
					,isDeleted					
					,createdDate					
					,createdBy						
					,modifiedDate					
					,modifiedBy	
					,domInternalCode
					,isBlocked													)
			SELECT
					@bankName						
					,@bankCode					
					,@country						
					,@address							
					,@phone							
					,@fax								
					,@email							
					,@contactPerson					
					,@swiftCode						
					,@routingCode						
					,@externalCode
					,@internalCode				
					,@externalBankType				
					,@IsBranchSelectionRequired		
					,@receivingMode
					,@isDeleted					
					,GETDATE()					
					,@user						
					,@modifiedDate					
					,@modifiedBy	
					,@domInternalCode
					,@isBlocked	
					
			SET @modType = 'Insert'
			SET @extBankId = @@IDENTITY
			
			EXEC [dbo].proc_GetColumnToRow  @tableAlias, @logIdentifier, @extBankId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @extBankId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @extBankId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @extBankId
		RETURN 
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT * from externalBank WITH(NOLOCK) where extBankId = @extBankId
		RETURN
	END

	ELSE IF @flag = 'u'
	BEGIN
	BEGIN TRANSACTION
			UPDATE externalBank SET
					bankName					=	@bankName						
					,bankCode					=	@bankCode			
					,country					=	@country					
					,address					=	@address						
					,phone						=	@phone				
					,fax						=	@fax				
					,email						=	@email						
					,contactPerson				=	@contactPerson				
					,swiftCode					=	@swiftCode					
					,routingCode				=	@routingCode					
					,externalCode				=	@externalCode
					,internalCode				=	@internalCode			
					,externalBankType			=	@externalBankType			
					,IsBranchSelectionRequired	=	@IsBranchSelectionRequired
					,receivingMode				=	@receivingMode
					,modifiedDate				=	GETDATE()	
					,modifiedBy					=	@user
					,domInternalCode			=	@domInternalCode
					,isBlocked					=	@isBlocked
					WHERE extBankId = @extBankId
			
			SET @modType = 'Update'
			EXEC [dbo].proc_GetColumnToRow  @tableAlias, @logIdentifier, @extBankId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'u', NULL, @modType, @tableAlias, @extBankId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @extBankId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @extBankId
		return
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE externalBank SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE extBankId = @extBankId
			
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @tableAlias, @logIdentifier, @extBankId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'u', NULL, @modType, @tableAlias, @extBankId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @extBankId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @extBankId
		return
	END


	ELSE IF @flag = 's'
	BEGIN
	
		IF @sortBy IS NULL
			SET @sortBy = 'extBankId'

		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '(	SELECT
								extBankId
								,bankName						
								,bankCode = externalCode					
								,country = main.country						
								,address							
								,phone							
								,fax								
								,email							
								,contactPerson									
								,internalCode
								,domInternalCode						
								,externalCode	
								,externalBankType =externalBankType		
								,swiftCode	=swiftCode								
								,agentBankcode =ISNULL(CASE WHEN detailTitle=''Agent Specific'' THEN ''<a href="AgentWiseBankCodeStup/List.aspx?parentId=''+CAST(extBankId AS VARCHAR)+''&bankName=''+bankName+''" title="Agent Bankcode"><img src="../../../Images/branch.png" border=0 />Agent Bankcode</a>'' END,'''')
								 +''  ''+ISNULL( CASE WHEN IsBranchSelectionRequired=''Select'' THEN ''<a href="ListBranch.aspx?bankName=''+bankName+''&parentId=''+CAST(extBankId AS VARCHAR)+''" title=Branches><img src="../../../Images/branch.png" border=0 />Branches</a>'' END,'''')
								,isBlocked=ISNULL(main.isBlocked,''N'')
							FROM externalBank main WITH(NOLOCK)
							LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON sdv.valueId = main.externalBankType 	
							WHERE ISNULL(main.isDeleted, '''')<>''Y''
					) x'
--print @table
		SET @sql_filter = ''
			
		IF @bankName IS NOT NULL
			SET @sql_filter= @sql_filter + '  AND bankName LIKE ''%'+@bankName+'%'''
			
		IF @country IS NOT NULL
			SET @sql_filter= @sql_filter + '  AND country LIKE ''%'+@country+'%'''
			
		IF @isBlocked is not null
			SET @sql_filter= @sql_filter + '  AND isBlocked LIKE ''%'+@isBlocked+'%'''
		
		SET @select_field_list ='
			extBankId
			,bankName						
			,bankCode					
			,country						
			,address							
			,phone							
			,fax								
			,email							
			,contactPerson								
			,internalCode	
			,domInternalCode					
			,externalCode	
			,agentBankcode	
			,externalBankType			
			,swiftCode
			,isBlocked	
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
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @extBankId
END CATCH



GO
