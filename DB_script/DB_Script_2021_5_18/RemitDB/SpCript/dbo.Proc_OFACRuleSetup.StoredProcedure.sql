USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_OFACRuleSetup]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC  [dbo].[Proc_OFACRuleSetup] (
@flag                               VARCHAR(50)		= NULL
,@user                              VARCHAR(30)		= NULL
,@RuleId							VARCHAR(30)		= NULL
,@amount                            MONEY			= NULL
,@period							INT				= NULL
,@sortBy                            VARCHAR(50)		= NULL
,@sortOrder                         VARCHAR(5)		= NULL
,@pageSize                          INT				= NULL
,@pageNumber                        INT				= NULL
,@isPerTransaction					VARCHAR(5)		= NULL
)

AS 
BEGIN 
SET NOCOUNT ON;
BEGIN TRY

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

SELECT  @ApprovedFunctionId = 20602030

IF @flag='i'    -- insert Rule setup 
BEGIN
		IF EXISTS( SELECT 'x'	FROM csSafelistRuleDetail  WHERE ISNULL(period, 0) = ISNULL(@period, 0) )

							-- AND ISNULL(condition, 0) = ISNULL(@condition, 0) AND 
							-- ANDISNULL(tranCount, 0) = ISNULL(@tranCount, 0) AND
							-- AND ISNULL(nextAction, 0) = ISNULL(@nextAction, 0)
							-- AND ISNULL(ruleScope, 0) = ISNULL(@ruleScope, 0)
					
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', NULL
			RETURN
		END
		BEGIN TRANSACTION
			INSERT INTO csSafelistRuleDetail (
				
				
				 Amount
				,period
				,createdBy
				,createdDate
				,IsPerTransaction
				,IsActive	
				
			)
			SELECT
				 @amount
				,@period
				,@user
				,GETDATE()
				,@isPerTransaction
				,'Y'
				
			SET @RuleId = SCOPE_IDENTITY()
			
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record has been added successfully.', @RuleId
	END

ELSE IF @flag = 'u'                 -- update rule detail (done) : (urd_v2)
	BEGIN
		IF EXISTS (
			SELECT 'X' FROM csSafelistRuleDetail WITH(NOLOCK)
			WHERE RuleId = @RuleId AND ( createdBy <> @user AND approvedBy IS NULL)
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @RuleId
			RETURN
		END
		IF EXISTS (
			SELECT 'X' FROM csSafelistRuleDetail WITH(NOLOCK)
			WHERE RuleId = @RuleId  AND (createdBy<> @user OR ISNULL(isDeleted,'N') <> 'N') AND approvedBy IS NULL
		)
		BEGIN
			EXEC proc_errorHandler 1, '<center>You can not modify this record. <br /> You are trying to perform an illegal operation.</center>', @RuleId
			RETURN
		END
		IF EXISTS(
			SELECT 'x' FROM csSafelistRuleDetail (NOLOCK) WHERE ISNULL(period, 0) = ISNULL(@period, 0) AND RuleId <> @RuleId)
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exist.', NULL
			RETURN
		END
		BEGIN TRANSACTION
			IF EXISTS (SELECT 'X' FROM csSafelistRuleDetail (NOLOCK) WHERE approvedBy IS NULL AND RuleId = @RuleId)			
			BEGIN				
				UPDATE csSafelistRuleDetail SET
				
					amount			= @amount
					,period			= @period
					,createdBy		= @user
					,createdDate	= GETDATE()
					,IsActive		= 'Y'
					,ModifiedBy		= @user
					,ModifiedDate	= GETDATE()		
				WHERE RuleId = @RuleId				
			END
			ELSE
			BEGIN
				INSERT INTO 
					csSafelistRuleDetailHistory
					(
						 ruleId
						,amount
						,period
						,isDeleted
						,approvedBy
						,approvedDate
						,createdBy
						,createdDate
						,modifiedBy
						,modifiedDate
						,IsActive
					)
				SELECT   RuleId
						,amount
						,period
						,isDeleted
						,approvedBy
						,ApprovedDate
						,createdBy
						,createdDate
						,modifiedBy
						,modifiedDate
						,IsActive 
				FROM csSafelistRuleDetail
				WHERE RuleId = @RuleId	

				UPDATE csSafelistRuleDetail SET
					amount			= @amount
					,period			= @period
					,createdBy		= @user
					,createdDate	= GETDATE()
					,IsActive		= 'Y'
					,modifiedBy			= @user
					,modifiedDate	= GETDATE()		
				WHERE RuleId = @RuleId	
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record updated successfully.', @RuleId
	END

ELSE IF @flag ='s'     -- (rdGrid_v2)
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'condition'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @pageNumber = 1
		SET @pageSize = 10000
		
		
		SET @table = '(
				SELECT
					 main.RuleId
					,main.Amount
					,main.Period
					,isDisabled=CASE WHEN ISNULL(main.IsActive,''n'')=''y'' then ''Enabled'' else ''Disabled'' END
					,main.CreatedBy
					,main.CreatedDate
					,main.ModifiedBy
					,main.ModifiedDate
					,CASE WHEN main.ApprovedBy IS NULL THEN '''' ELSE ''none'' END as isApproved

				FROM csSafeListRuleDetail main WITH(NOLOCK)
				LEFT JOIN staticDataValue con WITH(NOLOCK) ON  1=1       --main.condition = con.valueId			
					WHERE ISNULL(main.isDeleted, ''N'')  <> ''Y''
						
			)x'


			
		SET @sql_filter = ''
		
		
		IF @amount IS NOT NULL AND @amount<>0
		SET @sql_filter =  @sql_filter + ' AND x.amount = ''' + CAST(@amount AS VARCHAR(50))+''''
		
		IF @period IS NOT NULL AND @period<>0
		SET @sql_filter =  @sql_filter + ' AND x.period = ''' + CAST(@period AS VARCHAR(50))+''''

		SET @select_field_list ='
			 RuleID
			,amount
			,period
			,isDisabled
			,createdBy
			,createdDate
			,modifiedBy
			,modifiedDate
			,isApproved
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

	ELSE IF @flag ='s1'--(rdGrid)
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'condition'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @pageNumber = 1
		SET @pageSize = 10000
		
		
		SET @table = '(
				SELECT
					 main.RuleId
					,main.amount
					,main.period
					,isDisabled=CASE WHEN ISNULL(main.IsActive,''n'')=''y'' then ''Enabled'' else ''Disabled'' END
					,main.CreatedBy
					,main.CreatedDate
					,main.ModifiedBy
					,main.ModifiedDate
					,CASE WHEN main.ApprovedBy IS NULL THEN '''' ELSE ''none'' END as isApproved

				FROM csSafeListRuleDetail main WITH(NOLOCK)
				LEFT JOIN staticDataValue con WITH(NOLOCK) ON main.condition = con.valueId
				LEFT JOIN staticDataValue cm WITH(NOLOCK) ON main.collMode = cm.valueId
				LEFT JOIN serviceTypeMaster pm WITH(NOLOCK) ON main.paymentMode = pm.serviceTypeId						
					WHERE --main.csMasterId = + CAST (@csMasterId AS VARCHAR) 
					  ISNULL(main.IsDeleted, ''N'')  <> ''Y''
						--AND (
						--		main.ApprovedBy IS NOT NULL 
						--		OR main.CreatedBy = ''' +  ISNULL(@user,'') + '''
						--	)
			)x'
			
		SET @sql_filter = ''

		SET @select_field_list ='
			 RuleID
			,Amount
			,period
			,isDisabled
			,AreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
			,IsApproved
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
     EXEC proc_errorHandler 1, @errorMessage, NULL
END CATCH

END
GO
