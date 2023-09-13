SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER  PROC [dbo].[proc_staticDataValue]
      @flag                             VARCHAR(50)		= NULL
     ,@typeID                           INT				= NULL
     ,@user                             VARCHAR(30)		= NULL
     ,@valueId                          VARCHAR(30)		= NULL
     ,@detailTitle                      VARCHAR(MAX)	= NULL
     ,@detailDesc                       VARCHAR(MAX)	= NULL
     ,@moduleType						VARCHAR(10)		= NULL
     ,@isActive							CHAR(1)			= NULL
     ,@sortBy                           VARCHAR(50)		= NULL
     ,@sortOrder                        VARCHAR(5)		= NULL
     ,@pageSize                         INT				= NULL
     ,@pageNumber                       INT				= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
     CREATE TABLE #msg(error_code INT, msg VARCHAR(100), id INT)
     DECLARE
           @sql           VARCHAR(MAX)
          ,@oldValue      VARCHAR(MAX)
          ,@newValue      VARCHAR(MAX)
          ,@tableName     VARCHAR(50)
     DECLARE
           @select_field_list VARCHAR(MAX)
          ,@extra_field_list  VARCHAR(MAX)
          ,@table             VARCHAR(MAX)
          ,@sql_filter        VARCHAR(MAX)
     DECLARE
           @gridName              VARCHAR(50)
          ,@modType               VARCHAR(6)
		  ,@acct_num			  VARCHAR(20),
		  @bankName				  VARCHAR(65)
     SELECT
           @gridName          = 'grid_staticDataValue'
     
     IF @flag='a'
     BEGIN
			--SELECT * FROM staticDataValue WHERE valueId=@valueId AND (IS_DELETE IS NULL OR IS_DELETE='')
			SELECT * FROM staticDataValue WHERE valueId=@valueId AND (ISNULL(IS_DELETE,'N')<>'Y' OR IS_DELETE='')
     END
     ELSE IF @flag = 'c'
	 BEGIN
		SELECT
			 valueId
			,detailTitle
		FROM staticDataValue WITH (NOLOCK)
		WHERE typeId =@typeID AND valueId = ISNULL(@valueId, valueId) AND ISNULL(IS_DELETE, 'N') = 'N'
		AND ISNULL(isActive, 'Y') = 'Y'
		ORDER BY detailTitle
	END
	ELSE IF @flag = 'c1'
	BEGIN
		SELECT
			 detailTitle
			,detailDesc
		FROM staticDataValue WITH (NOLOCK)
		WHERE typeId =@typeID AND valueId = ISNULL(@valueId, valueId) AND ISNULL(IS_DELETE, 'N') <> 'Y'
		AND ISNULL(isActive, 'Y') = 'Y'
		ORDER BY detailTitle	
	END
	
	ELSE IF @flag = 'c-ut'
	BEGIN
		IF @moduleType = 'agent'
		BEGIN
			SELECT
				 detailTitle
				,detailDesc
			FROM staticDataValue WITH (NOLOCK)
			WHERE ISNULL(IS_DELETE, 'N') <> 'Y'
			AND ISNULL(isActive, 'Y') = 'Y'
			AND valueId IN(7300, 7301, 7302, 7303, 7304)
			ORDER BY detailTitle
		END
		ELSE IF @moduleType = 'ho'
		BEGIN
			SELECT
				 detailTitle
				,detailDesc
			FROM staticDataValue WITH (NOLOCK)
			WHERE ISNULL(IS_DELETE, 'N') <> 'Y'
			AND ISNULL(isActive, 'Y') = 'Y'
			AND valueId IN(7311,7310)


			UNION ALL
			SELECT 'RH','Regional Head'
			--SELECT
			--	 detailTitle
			--	,detailDesc
			--FROM staticDataValue WITH (NOLOCK)
			--WHERE ISNULL(IS_DELETE, 'N') <> 'Y'
			--AND ISNULL(isActive, 'Y') = 'Y'
			--AND valueId IN(7303)
		END	
		RETURN	
	END
	
	ELSE IF @flag = 'l'
	 BEGIN
		--SELECT * FROM (
			SELECT NULL 'value', 'Select' 'text' UNION ALL			
			SELECT
				 valueId AS 'value'
				,detailTitle AS 'text'
			FROM staticDataValue WITH (NOLOCK)
			WHERE typeId = @typeID
		--)	x
		--ORDER BY [1]
	END 
	ELSE IF @flag = 'l2'
	 BEGIN
		--SELECT * FROM (
			SELECT NULL [0], 'Select' [1] UNION ALL			
			SELECT '2903','Agent' UNION ALL	
			SELECT '2904','Branch'
		--)	x
		--ORDER BY [1]
	END 
	
	ELSE IF @flag = 'ltt' --log type by text
	 BEGIN
		--SELECT * FROM (
			SELECT NULL [value], 'Select' [text] UNION ALL			
			SELECT
				 detailTitle [value]
				,detailTitle [text]
			FROM staticDataValue WITH (NOLOCK)
			WHERE typeId = @typeID
		--)	x
		--ORDER BY [1]
	END 
	
     IF @flag = 'i'
     BEGIN
		IF EXISTS(SELECT 'X' FROM staticDataValue WHERE typeID = @typeID AND detailTitle = @detailTitle AND ISNULL(IS_DELETE, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END
          BEGIN TRANSACTION
		  IF @typeID='7010'
			BEGIN
				SELECT @bankName = @detailTitle 
			
				SELECT @acct_num = MAX(cast(ACCT_NUM as bigint)+1) FROM FastMoneyPro_Account.dbo.ac_master (NOLOCK) WHERE gl_code='72'
				SET @acct_num=ISNULL(@acct_num,100241000000)
				----## AUTO CREATE LEDGER FOR PARTNER AGENT
				INSERT INTO FastMoneyPro_Account.dbo.ac_master (acct_num, acct_name,gl_code, agent_id, 
				acct_ownership,dr_bal_lim, acct_rpt_code,acct_opn_date,clr_bal_amt, system_reserved_amt, 
				lien_amt, utilised_amt, available_amt,created_date,created_by,company_id, ac_currency)
				VALUES(@acct_num,@bankName,'72', NULL,'o',0,'TB',getdate(),0,0,0,0,0,getdate(),@user,1, 'JPY')
			END
			
               INSERT INTO staticDataValue (
					 typeID
					,detailTitle
                    ,detailDesc 
                    ,isActive                  
                    ,createdBy
                    ,createdDate
               )
               SELECT
                     @typeID
                    ,@detailTitle
                    ,@detailDesc  
                    ,@isActive                
                    ,@user
                    ,GETDATE()
               SET @valueId = SCOPE_IDENTITY()
               EXEC [dbo].proc_GetColumnToRow  'staticDataValue', 'valueId', @valueId, @newValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'insert', 'staticDataValue', @valueId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be updated.' mes, @valueId id
                    RETURN
               END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               SELECT 0 error_code, 'Record has been added successfully' mes, @valueId id
          END

     ELSE IF @flag = 'u'
     BEGIN
		IF EXISTS(SELECT 'X' FROM staticDataValue WHERE valueId <> @valueId AND typeID = @typeID AND detailTitle = @detailTitle AND ISNULL(IS_DELETE, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Record already exists', NULL
			RETURN
		END
          BEGIN TRANSACTION
               EXEC [dbo].proc_GetColumnToRow  'staticDataValue', 'valueId', @valueId, @oldValue OUTPUT
               UPDATE staticDataValue SET
                          detailTitle                   = @detailTitle
                         ,detailDesc                    = @detailDesc
                         ,isActive						= @isActive
                         ,modifiedBy     = @user
                         ,modifiedDate   = GETDATE()
                    WHERE valueId = @valueId
                    EXEC [dbo].proc_GetColumnToRow  'staticDataValue', 'valueId', @valueId, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'staticDataValue', @valueId, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @valueId id
                         RETURN
                    END
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
          SELECT 0 error_code, 'Record updated successfully.' mes, @valueId id 
     END

ELSE IF @flag = 'd'
     BEGIN
          BEGIN TRANSACTION
               UPDATE staticDataValue SET
                     IS_DELETE = 'Y'
                    ,modifiedBy = @user
                    ,modifiedDate=GETDATE()
               WHERE valueId = @valueId
               EXEC [dbo].proc_GetColumnToRow  'staticDataValue', 'valueId', @valueId, @oldValue OUTPUT
               INSERT INTO #msg(error_code, msg, id)
               EXEC proc_applicationLogs 'i', NULL, 'delete', 'staticDataValue', @valueId, @user, @oldValue, @newValue
               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
               BEGIN
                    IF @@TRANCOUNT > 0
                    ROLLBACK TRANSACTION
                    SELECT 1 error_code, 'Record can not be deleted.' mes, @valueId id
                    RETURN
               END
          IF @@TRANCOUNT > 0
          COMMIT TRANSACTION
          SELECT 0 error_code, 'Record deleted successfully.' mes, @valueId id
     END
     
	ELSE IF @flag IN ('s')
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'valueId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		SET @table = '(
				SELECT 
					 valueId 
					,sdv.typeId
					,type = sdt.typeTitle 
					,sdv.detailTitle
					,sdv.detailDesc
					,isActive = ISNULL(sdv.isActive, ''Y'')
					,sdv.IS_DELETE
				FROM staticDataValue sdv WITH(NOLOCK)  
                LEFT JOIN staticDataType sdt WITH(NOLOCK) ON sdv.typeId = sdt.typeId
				WHERE sdv.typeID = ' + CAST(@typeID AS VARCHAR) + ' 
				) x'
		SET @sql_filter = ''
		if @detailTitle is not null
			set @sql_filter = @sql_filter + ' AND detailTitle like '''+@detailTitle+'%'''

		SET @sql_filter = @sql_filter + ' AND ISNULL(IS_DELETE, '''') <> ''Y'''
		SET @select_field_list ='
			 valueId
			,typeId
			,type
			,detailTitle
			,detailDesc
			,isActive
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
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH
GO