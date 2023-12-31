USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_systemEmailSetup]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_systemEmailSetup]') AND TYPE IN (N'P', N'PC'))
--	 DROP PROCEDURE [dbo].proc_systemEmailSetup

--GO

CREATE proc [dbo].[proc_systemEmailSetup]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@id								INT				= NULL	
	,@country							VARCHAR(200)	= NULL
	,@name								VARCHAR(200)    = NULL
	,@email								VARCHAR(max)	= NULL
	,@mobile							VARCHAR(200)    = NULL
	,@agent								VARCHAR(max)	= NULL
	,@isCancel							VARCHAR(100)	= NULL
	,@isTrouble							VARCHAR(100)	= NULL
	,@isAccount                         VARCHAR(50)		= NULL
	,@isXRate	                        VARCHAR(50)		= NULL
	,@isSummary	                        VARCHAR(50)		= NULL
	,@isBonus	                        VARCHAR(50)		= NULL
	,@isEodRpt	                        VARCHAR(50)		= NULL
	,@isbankGuaranteeExpiry				VARCHAR(10)		= NULL
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
		 @logIdentifier = 'id'
		,@logParamMain = 'systemEmailSetup'
		,@module = '20'
		,@tableAlias = 'System Email Setup'
		
-- select * from systemEmailSetup
-- ALTER TABLE systemEmailSetup ADD isBonus VARCHAR(5)

	IF @flag IN ('s')
	BEGIN
		SET @table = '(
				SELECT
					 id 
					,country
					,name
					,email
					,mobile
					,dbo.GetAgentNameFromId(agent) agent
					,isCancel
					,isTrouble
					,isAccount
					,isXRate
					,isSummary
					,isBonus
					,isEodRpt
					,isbankGuaranteeExpiry
					,createdBy
					,createdDate
					,modifiedDate		
					,modifiedBy			
					,hasChanged = ''Y''

				FROM systemEmailSetup main 	with(nolock)
				WHERE ISNULL(isDeleted,''N'')<>''Y''
			)a '
			--select (@table)
			--return;
	
	END	
	IF @flag = 'i'
	BEGIN
		
			INSERT INTO systemEmailSetup 
			(
					 name
					,email
					,mobile
					,agent
					,isCancel
					,isTrouble
					,isAccount
					,isXRate
					,isSummary
					,isBonus
					,isEodRpt
					,isbankGuaranteeExpiry
					,createdBy
					,createdDate
					,country
			)
			SELECT
					 @name
					,@email
					,@mobile
					,@agent
					,@isCancel
					,@isTrouble
					,@isAccount
					,@isXRate
					,@isSummary
					,@isBonus
					,@isEodRpt
					,@isbankGuaranteeExpiry
					,@user
					,GETDATE()
					,@country
				 
			SET @id = SCOPE_IDENTITY()			
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @id
		
	END
	
	ELSE IF @flag = 'a'
	BEGIN
			
			SELECT
				 id
				,country
				,name
				,email
				,mobile
				,agent
				,isCancel
				,isTrouble
				,isAccount
				,isXRate
				,isSummary
				,isBonus
				,isEodRpt
				,isbankGuaranteeExpiry
				,createdBy
				,createdDate
				,modifiedBy
				,modifiedDate				
			FROM systemEmailSetup where id=@id
	
	END

	ELSE IF @flag = 'u'
	BEGIN
		
			UPDATE systemEmailSetup SET
				 name				= @name
				,email				= @email
				,mobile				= @mobile
				,agent				= @agent
				,isCancel			= @isCancel
				,isTrouble			= @isTrouble
				,isAccount			= @isAccount
				,isXRate			= @isXRate
				,isSummary			= @isSummary	
				,isBonus			= @isBonus
				,isEodRpt			= @isEodRpt
				,isbankGuaranteeExpiry=@isbankGuaranteeExpiry
				,modifiedBy			= @user
				,modifiedDate		= GETDATE()
				,country			= @country
			WHERE id = @id			

		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @id
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		update systemEmailSetup set isDeleted='Y' WHERE ID=@id	
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @id
	END
	
	ELSE IF @flag = 's'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'id'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '( 
				SELECT
					 id 
					,country
					,name
					,email
					,mobile
					,agent
					,isCancel
					,isTrouble
					,isAccount
					,isXRate
					,isSummary
				    ,isBonus
				    ,isEodRpt
					,isbankGuaranteeExpiry
					,createdBy
					,createdDate
					,modifiedDate		
					,modifiedBy			
					,hasChanged
					
				FROM ' + @table + ' 
				) x
		
				'
		set @sql_filter=''
		
		IF @name IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND name LIKE ''%' + @name + '%'''

		IF @email IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND email LIKE ''%' + @email + '%'''
		
		--select @table
		--return;	
		SET @select_field_list ='
					 id 
					,country
					,name
					,email
					,mobile
					,agent
					,isCancel
					,isTrouble
					,isAccount
					,isXRate
					,isSummary
				    ,isBonus
				    ,isEodRpt
					,isbankGuaranteeExpiry
					,createdBy
					,createdDate
					,modifiedDate		
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


END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @id
END CATCH



GO
