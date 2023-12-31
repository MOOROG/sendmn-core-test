USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcCreateSchedultJobOneTime]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*

SELECT Replace( CONVERT(VARCHAR(12), GETDATE(), 114), ':',''),
Replace( CONVERT(VARCHAR(12), GETDATE(), 114), ':','')+ 40000

exec ProcCreateSchedultJobOneTime 
	@JOB_NAME='Generate_RA_Balance',
	@SQL='Exec ProcRABalanceJob ''2010-11-17'', ''2010-12-15'',
	@DB='IMEKL',
	@ReplaceIfExists='Y'

*/

CREATE Proc [dbo].[ProcCreateSchedultJobOneTime]
	@JOB_NAME			varchar(200),
	@SQL				varchar(max),
	@DB					varchar(200),
	@ReplaceIfExists	CHAR(1) = 'N'
	
AS
Begin
	
	    SET @DB='FastMoneyPro_account'

	    declare @Time varchar(20)
	    set @Time=left(Replace( CONVERT(VARCHAR(12), GETDATE(), 114), ':','')+ 10000, 6)
    	
	    IF ISNULL(@ReplaceIfExists, 'N') = 'N'
	    BEGIN
		    IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @JOB_NAME)
		    BEGIN
			    PRINT 'Job ''' + @JOB_NAME + ''' already exists.'
			    RETURN;
		    END	
	    END

		declare @job_id				varchar(500)
		DECLARE @owner_login_name	VARCHAR(100)
		DECLARE @active_start_date	INT
		SEt @active_start_date	= CAST(REPLACE(convert(varchar, GETDATE(), 102),'.','') AS INT)
		SET @owner_login_name	= 'fastmoney'
		
		
		set @job_id = (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @JOB_NAME)


		/****** Object:  Job [TEST_JOB]    Script Date: 11/14/2010 14:09:40 ******/
		IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = @JOB_NAME)
			EXEC msdb.dbo.sp_delete_job @job_id=@job_id, @delete_unused_schedule=1


		/****** Object:  Job [TEST_JOB]    Script Date: 11/14/2010 14:09:40 ******/
		BEGIN TRANSACTION
		DECLARE @ReturnCode INT
		SELECT @ReturnCode = 0
		/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 11/14/2010 14:09:40 ******/
		IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories 
		WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
		BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		END

		DECLARE @jobId BINARY(16)
		EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@JOB_NAME, 
				@enabled=1, 
				@notify_level_eventlog=0, 
				@notify_level_email=0, 
				@notify_level_netsend=0, 
				@notify_level_page=0, 
				@delete_level=0, 
				@description=N'No description available.', 
				@category_name=N'[Uncategorized (Local)]', 
				@owner_login_name=@owner_login_name, @job_id = @jobId OUTPUT
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		/****** Object:  Step [JOB1_SCH]    Script Date: 11/14/2010 14:09:40 ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step1', 
				@step_id=1, 
				@cmdexec_success_code=0, 
				@on_success_action=1, 
				@on_success_step_id=0, 
				@on_fail_action=3, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N'TSQL', 
				@command=@SQL, 
				@database_name=@DB, 
				@flags=0

		 -- EXEC 	msdb.dbo.sp_add_jobstep @job_name = @run_job_name,
		 --  	@step_id = 1,
		 --  	@step_name = 'Step1',
		 --  	@subsystem = 'TSQL',
			--@on_fail_action = 3,
			--@on_success_action = 1, 
			--@on_fail_step_id = 2,
		 --  	@command = @spa,
			--@database_name = @db_name


		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1

		--IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		--EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'JOB1_TIME', 
		--		@enabled=1, 
		--		@freq_type=1, 
		--		@active_start_date=@active_start_date, 
		--		@schedule_uid=N'fa852d18-abeb-4990-96d7-12ee29f46b1c'
				
				
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'


		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		EXEC msdb.dbo.sp_start_job @job_id = @jobId, @server_name = N'(local)'


		COMMIT TRANSACTION

		GOTO EndSave
		QuitWithRollback:
			IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
		EndSave:

		PRINT 'Job ''' + @JOB_NAME + ''' successfully created/updated.'

end




GO
