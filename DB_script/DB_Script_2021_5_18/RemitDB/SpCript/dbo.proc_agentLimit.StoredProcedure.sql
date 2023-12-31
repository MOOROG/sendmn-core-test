USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentLimit]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

    EXEC proc_agentLimit @flag = 'u', @user = 'admin', @agentId = '9', @AC_ID = '104548', @DR_LIMIT = '14500', @LIMIT_EXPIRY = '05/05/2010'

*/

CREATE PROC [dbo].[proc_agentLimit]
      @flag								VARCHAR(50)    = NULL
     ,@user								VARCHAR(30)    = NULL
     ,@agentId							INT			   = NULL
     ,@AC_ID                            INT            = NULL
     ,@DR_LIMIT                         money        = NULL
     ,@LIMIT_EXPIRY                     datetime       = NULL
  --   ,@sortBy                             VARCHAR(50)    = NULL
	 --,@sortOrder                          VARCHAR(5)     = NULL
	 --,@pageSize                           INT            = NULL
	 --,@pageNumber                         INT            = NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
     CREATE TABLE #msg(error_code INT, msg VARCHAR(100), id INT)
     DECLARE
           @sql           VARCHAR(MAX)         
          ,@newValue      VARCHAR(MAX)
          ,@tableName     VARCHAR(50)     
          
	IF @flag='a'
	BEGIN
			SELECT convert(varchar,lim_expiry,102)as limit,* FROM ac_master WHERE AGENT_ID=@agentId
    END
    IF @flag='ha'
    BEGIN
			SELECT * FROM limitHistory
    END
     
     IF @flag = 'u'
     BEGIN
     
			declare @oldvalue money,@old_lim_expiry varchar(20),@AVL_AMT varchar(30)
				if @LIMIT_EXPIRY < getdate()
				begin
					select 0 error_code,'Limit expiry should be greater than today' mes,@AC_ID id
					return
				end
          BEGIN TRANSACTION
               --EXEC [dbo].proc_GetColumnToRow  'agentLimit', 'ROWID', @ROWID, @oldValue OUTPUT
          

				select @oldvalue=DR_BAL_LIM,@old_lim_expiry=convert(varchar(20),lim_expiry,102) from ac_master where acct_id=@AC_ID

				update ac_master set
				DR_BAL_LIM=@DR_LIMIT,
				lim_expiry=@LIMIT_EXPIRY
				where acct_id=@AC_ID
				
				update ac_master set
				AVAILABLE_AMT=isnull(DR_BAL_LIM,0) + isnull(CLR_BAL_AMT,0) - isnull(SYSTEM_RESERVED_AMT,0) - isnull(LIEN_AMT,0)
				where acct_id=@AC_ID
	
			select @AVL_AMT=AVAILABLE_AMT from ac_master where acct_id=@AC_ID
	
	
                    EXEC [dbo].proc_GetColumnToRow  'ac_master', 'AC_ID', @AC_ID, @newValue OUTPUT
                    INSERT INTO #msg(error_code, msg, id)
                    EXEC proc_applicationLogs 'i', NULL, 'update', 'ac_master', @AC_ID, @user, @oldValue, @newValue
                    IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
                    BEGIN
                         IF @@TRANCOUNT > 0
                         ROLLBACK TRANSACTION
                         SELECT 1 error_code, 'Record can not be updated.' mes, @AC_ID id
                         RETURN
                    END
                    
               IF @@TRANCOUNT > 0
               COMMIT TRANSACTION
               insert into job_history(job_name,job_time,job_user,job_value,job_remarks,update_row,old_value) 
	values ('ac_master',getdate(),@user,convert(varchar(50),@DR_LIMIT),'DRLimiUpdate:'+isnull(@old_lim_expiry,'') +'-'+ isnull((convert(varchar,@LIMIT_EXPIRY,102)),''),@AC_ID,@oldvalue)

               INSERT INTO limitHistory ( AGENT_ID,AC_ID,DR_LIMIT,LIMIT_EXPIRY,UTILISED_AMT,AVL_AMT,CREATED_BY,CREATED_DATE  )
               SELECT @agentId,@AC_ID,@DR_LIMIT,@LIMIT_EXPIRY,0,@AVL_AMT ,@user   ,GETDATE()
          SELECT 0 error_code, 'Record updated successfully.' mes, @AC_ID id 
     END

--ELSE IF @flag = 'd'
--     BEGIN
--          BEGIN TRANSACTION
--               UPDATE agentLimit SET
--                     IS_DELETE = 'Y'
--                    ,MODIFY_BY = @user
--                    ,MODIFY_DATE=GETDATE()
--               WHERE ROWID = @ROWID AND agentId=@agentId
--               EXEC [dbo].proc_GetColumnToRow  'agentLimit', 'ROWID', @ROWID, @oldValue OUTPUT
--               INSERT INTO #msg(error_code, msg, id)
--               EXEC proc_applicationLogs 'i', NULL, 'delete', 'agentLimit', @ROWID, @user, @oldValue, @newValue
--               IF EXISTS (SELECT 'X' FROM #msg WHERE error_code <> 0 )
--               BEGIN
--                    IF @@TRANCOUNT > 0
--                    ROLLBACK TRANSACTION
--                    SELECT 1 error_code, 'Record can not be deleted.' mes, @ROWID id
--                    RETURN
--               END
--          IF @@TRANCOUNT > 0
--          COMMIT TRANSACTION
--          SELECT 0 error_code, 'Record deleted successfully.' mes, @ROWID id
--     END

   
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, null id
END CATCH



GO
