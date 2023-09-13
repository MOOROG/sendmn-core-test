USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_EXECUTE_JOB]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[PROC_EXECUTE_JOB]
(
	@JOB_NAME VARCHAR(100)
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	EXEC msdb.dbo.sp_start_job @job_name = @JOB_NAME
END


GO
