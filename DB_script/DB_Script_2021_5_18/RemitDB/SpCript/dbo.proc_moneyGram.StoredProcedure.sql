USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_moneyGram]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_moneyGram]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@id								INT				= NULL
	
	,@agent								VARCHAR(200)    = NULL
	,@controlNo							VARCHAR(50)		= NULL
	,@recFullName                       VARCHAR(200)	= NULL
	,@sendFullName						VARCHAR(200)	= NULL
	
	,@recContactNo						VARCHAR(200)	= NULL
	,@amount							MONEY			= NULL
	,@date								DATETIME		= NULL
	,@location							INT      		= NULL
	,@address							VARCHAR(MAX)    = NULL
	,@sessionId							VARCHAR(100)	= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;


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
		,@ApprovedFunctionId INT
	SELECT
		 @ApprovedFunctionId = 20181230
		,@logIdentifier = 'id'
		,@logParamMain = 'moneyGram'
		,@logParamMod = 'moneyGramMod'
		,@module = '20'
		,@tableAlias = 'Money Gram'
		
		
	IF @flag='SS'--POPULATING AGENT LIST AS LOCATION
	BEGIN
	
		select agentId,agentName from 
		(
		select agentId,agentName from agentMaster where agentType =2903 and actAsBranch='y'
		union all
		select agentId,agentName from agentMaster where agentType=2904
		)a order by agentName

	END	
	ELSE IF @flag IN ('s')
	BEGIN
		SET @table = '(
				SELECT
					 id = ISNULL(mode.id, main.id)
					,agent = ISNULL(mode.agent, main.agent)
					,controlNo = ISNULL(mode.controlNo, main.controlNo)
					,recFullName = ISNULL(mode.recFullName, main.recFullName)
					,sendFullName = ISNULL(mode.sendFullName, main.sendFullName)
					,recContactNo = ISNULL(mode.recContactNo, main.recContactNo)
					,amount = ISNULL(mode.amount, main.amount)
					,tranDate = ISNULL(mode.tranDate, main.tranDate)
					,location = ISNULL(mode.location, main.location)
					,address = ISNULL(mode.address, main.address)
					,main.createdBy
					,main.createdDate
					,modifiedDate		= CASE WHEN main.approvedBy IS NULL THEN main.createdDate ELSE ISNULL(mode.createdDate, main.modifiedDate) END
					,modifiedBy			= CASE WHEN main.approvedBy IS NULL THEN main.createdBy ELSE ISNULL(mode.createdBy, main.modifiedBy) END
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) OR 
											(mode.id IS NOT NULL) 
										THEN ''Y'' ELSE ''N'' END

				FROM moneyGram main WITH(NOLOCK)
					LEFT JOIN moneyGramMod mode ON main.id = mode.id AND mode.approvedBy IS NULL
						AND (
								mode.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					WHERE 
						ISNULL(mode.sessionId,main.sessionId)=''' +  @sessionId + ''' 
						AND ISNULL(mode.createdBy,main.createdBy)=''' +  @user + ''' 
						AND ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
						 
			) '
			--PRINT (@table)
			

	END	
	IF @flag = 'i'
	BEGIN
		
			if exists(select * from moneyGram where controlNo=@controlNo and isnull(status,'Requested')<>'Rejected')
			begin
				EXEC proc_errorHandler 1, 'Already Added For This Control Number!', @controlNo
				return;
			end
			if exists(select * from moneyGram where controlNo='MG'+@controlNo and isnull(status,'Requested')<>'Rejected')
			begin
				EXEC proc_errorHandler 1, 'Already Added For This Control Number!', @controlNo
				return;
			end
			INSERT INTO moneyGram (
				 agent
				,controlNo
				,recFullName
				,sendFullName
				,recContactNo
				,amount
				,tranDate
				,location
				,address
				,sessionId
				,createdBy
				,createdDate
			)
			SELECT
				 @agent
				 ,@controlNo
				 ,@recFullName
				 ,@sendFullName
				 ,@recContactNo
				 ,@amount
				 ,@date
				 ,@location
				 ,@address
				 ,@sessionId
				 ,@user
				 ,GETDATE()
				 
			SET @id = SCOPE_IDENTITY()			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @id
		
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM moneyGramMod WITH(NOLOCK)
				WHERE id = @id AND createdBy = @user AND approvedBy IS NULL
		)		
		BEGIN
			
			SELECT
				id
				,agent
				,controlNo
				,recFullName
				,sendFullName
				,recContactNo
				,dbo.ShowDecimalExceptComma(amount) amount
				,convert(varchar,tranDate,107) tranDate
				,location
				,address
				,sessionId
				,createdBy
				,createdDate
				,modifiedBy
				,modifiedDate
				,isDeleted
			FROM moneyGramMod mode WITH(NOLOCK)
			WHERE mode.id= @id AND mode.approvedBy IS NULL
		END
		ELSE
		BEGIN
			SELECT 
				id
				,agent
				,controlNo
				,recFullName
				,sendFullName
				,recContactNo
				,dbo.ShowDecimalExceptComma(amount) amount
				,convert(varchar,tranDate,107) tranDate
				,location
				,address
				,sessionId
				,createdBy
				,createdDate
				,modifiedBy
				,modifiedDate
				,isDeleted 
				FROM moneyGram WITH(NOLOCK) WHERE id = @id
		END
	END
	ELSE IF @flag='VIEW'
	BEGIN
		SELECT 
				id
				,agent
				,controlNo
				,recFullName
				,sendFullName
				,recContactNo
				,dbo.ShowDecimal(amount) amount
				,convert(varchar,tranDate,107) tranDate 
				,b.agentName location
				,address
				,sessionId
				,a.createdBy
				,convert(varchar,a.createdDate,107) createdDate
				,a.modifiedBy
				,convert(varchar,a.modifiedDate,107) modifiedDate 
				,a.isDeleted 
				,a.status
				,a.approvedBy
				,convert(varchar,a.approvedDate,107) approvedDate
				FROM moneyGram  a WITH(NOLOCK) inner join agentMaster  b WITH(NOLOCK) on a.location=b.agentId
				WHERE id = @id
	END
	ELSE IF @flag = 'u'
	BEGIN
		
			UPDATE moneyGram SET
				 agent = @agent
				,controlNo = @controlNo
				,recFullName = @recFullName
				,sendFullName = @sendFullName
				,recContactNo = @recContactNo
				,amount=@amount
				,tranDate=@date
				,location=@location
				,address=@address
				,sessionId=@sessionId
				,modifiedBy = @user
				,modifiedDate = GETDATE()
			WHERE id = @id			

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @id
	END
	
	ELSE IF @flag = 'd'
	BEGIN

		DELETE FROM moneyGram WHERE ID=@id	
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @id
	END
	
	ELSE IF @flag = 'finalSave'
	BEGIN

		UPDATE moneyGram SET sessionId='',status='Requested',controlNo='MG'+controlNo
		WHERE createdBy=@user and sessionId=@sessionId
			
		EXEC proc_errorHandler 0, 'Final Saved successfully.', @id
	END
	
	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'id'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '( 
				SELECT
					 main.id
					,main.agent
					,main.controlNo
					,main.recFullName
					,main.sendFullName
					,main.recContactNo
					,main.amount
					,main.tranDate
					,location=am.agentName 
					,main.address
					,main.createdBy
					,main.createdDate
					,main.modifiedBy							
					,haschanged
				FROM agentMaster am 
				INNER JOIN ' + @table + ' main ON am.agentId = main.location
				) x
		
				'
				

		SET @sql_filter = ''				
			

		
			
		SET @select_field_list ='
					 id
					,agent
					,controlNo
					,recFullName
					,sendFullName
					,recContactNo
					,amount					
					,tranDate
					,location					
					,address
					,createdBy
					,createdDate
					,modifiedBy							
					,haschanged
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
		
		update moneyGram set approvedBy=@user,approvedDate=GETDATE(),status='Rejected' WHERE id = @id
		
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes rejected successfully.', @id
	END
--alter table moneyGram add status varchar(50)
	ELSE IF @flag = 'approve'
	BEGIN

	
			UPDATE moneyGram SET
				 approvedBy = @user
				,approvedDate= GETDATE()
				,sessionId=''
				,status='Approved'				
			WHERE id = @id
			

				
				/*
				
				remitTran updates here...
				
				*/
			

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Changes approved successfully.', @id
	END
	
	ELSE IF @flag IN ('appS')
	BEGIN
		SET @table = '(
				SELECT
					 id = main.id
					,agent = main.agent
					,controlNo = main.controlNo
					,recFullName =  main.recFullName
					,sendFullName = main.sendFullName
					,recContactNo = main.recContactNo
					,amount = main.amount
					,tranDate = main.tranDate
					,location = main.location
					,address = main.address
					,status=main.status
					,main.createdBy
					,main.createdDate
					,modifiedBy=isnull(main.modifiedBy,main.createdBy)
					,approvedBy		= main.approvedBy 
					,approvedDate	= main.approvedDate 
					
					,hasChanged = CASE WHEN (main.approvedBy IS NULL) and (main.sessionId='''')										
										THEN ''Y'' ELSE ''N'' END

				FROM moneyGram main WITH(NOLOCK)					
					WHERE 						
						ISNULL(main.isDeleted, ''N'')  <> ''Y''
						AND main.sessionId=''''
						AND (
								main.approvedBy IS NOT NULL 
								OR main.createdBy = ''' +  @user + ''' 
								OR ''Y'' = dbo.FNAHasRight(''' + @user + ''',' + CAST(@ApprovedFunctionId AS VARCHAR) + ')
							)
					
						 
			) '
	

		IF @sortBy IS NULL
			SET @sortBy = 'id'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '
				(SELECT
					 main.id
					,main.agent
					,main.controlNo
					,main.recFullName
					,main.sendFullName
					,main.recContactNo
					,main.amount
					,main.tranDate
					,location=am.agentName 
					,main.address
					,main.status
					,main.createdBy
					,main.createdDate
					,main.modifiedBy
					,main.approvedBy
					,main.approvedDate							
					,haschanged
				FROM agentMaster am 
				INNER JOIN ' + @table + ' main ON am.agentId = main.location)y
				
				
		
				'
				
		--select @table
		--return;
		SET @sql_filter = ''				
			
		IF @controlNo IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND controlNo = ''' + CAST(@controlNo AS VARCHAR)+ ''''		

	     IF @recFullName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND recFullName LIKE ''' + @recFullName + '%'''		

		IF @sendFullName IS NOT NULL
			 SET @sql_filter = @sql_filter + ' AND sendFullName LIKE ''' + @sendFullName + '%'''		
		
		IF @location IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND  agent like  ''' + @location + '%'''	
		
			
		SET @select_field_list ='
					 id
					,agent
					,controlNo
					,recFullName
					,sendFullName
					,recContactNo
					,amount					
					,tranDate
					,location					
					,address
					,status
					,createdBy
					,createdDate
					,modifiedBy
					,approvedBy
					,approvedDate							
					,haschanged
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
     EXEC proc_errorHandler 1, @errorMessage, @id
END CATCH


GO
