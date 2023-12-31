USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[JobHistoryRecord]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','raghu'
CREATE proc [dbo].[JobHistoryRecord]
	@flag char(1),
	@job_name varchar(200)=null,
	@old_value varchar(200)=null,
	@job_value varchar(200)=null,
	@job_remarks varchar(200)=null,
	@update_row varchar(200)=null,
	@job_user varchar(200)=null
as
if @flag='i'
begin

	insert into job_history(job_name,job_time,job_user,job_value,job_remarks,update_row,old_value) 
	values (@job_name,getdate(),@job_user,@job_value,@job_remarks,@update_row,@old_value)

end
if @flag='a'
begin

	select * from job_history

end

GO
