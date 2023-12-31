USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_emailNotes]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_emailNotes]
@flag		varchar(10),
@sendFrom	varchar(100),
@sendTo		varchar(500),
@sendCc		varchar(500),
@sendBcc	varchar(500),
@subject	varchar(500),
@User		varchar(50),
@errorMsg   varchar(max),
@sendStatus char(1)

as 
set nocount on ;

if @flag='i'
begin
	insert into emailNotes(sendFrom,sendTo,sendCc,sendBcc,subject,sendStatus,createdBy, notesText)
	select @sendFrom,@sendTo,@sendCc,@sendBcc,@subject,@sendStatus,@User, @errorMsg
end
GO
