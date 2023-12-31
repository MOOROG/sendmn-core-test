USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[JobHistoryRecord]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','raghu'
CREATE proc [dbo].[JobHistoryRecord]
	 @flag			CHAR(1)
	,@job_name		VARCHAR(200)	= NULL
	,@old_value		VARCHAR(200)	= NULL
	,@job_value		VARCHAR(200)	= NULL
	,@job_remarks	VARCHAR(200)	= NULL
	,@update_row	VARCHAR(200)	= NULL
	,@job_user		VARCHAR(200)	= NULL
AS
SET NOCOUNT ON;


	IF @flag='i'
	BEGIN

		INSERT INTO job_history(
			 job_name
			,job_time
			,job_user
			,job_value
			,job_remarks
			,update_row
			,old_value
		) 
		VALUES (
			 @job_name
			,GETDATE()
			,@job_user
			,@job_value
			,@job_remarks
			,@update_row
			,@old_value
		)

	END
	IF @flag='a'
	BEGIN

		SELECT * FROM job_history

	END


GO
