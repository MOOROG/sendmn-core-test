USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[spa_createAccountNumber]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec spa_createAccountNumber 'a','1'

CREATE proc [dbo].[spa_createAccountNumber]
	@flag char(1),
	@gl_code varchar(6)
AS
	set nocount on;

if @flag='a'
begin
	
	declare @bookedid varchar(20), @uniquenum varchar(2)
	
	if len(@gl_code)=1
	set @gl_code=@gl_code+'0'
	
	set @gl_code= left(@gl_code,2)

	select @bookedid=1+ident_current('ac_master')
	set @uniquenum=replace(right((RAND()*5),1),'.','0')
	
	select cast(@gl_code as varchar) + cast(@bookedid as varchar) + cast(@uniquenum as varchar) as BookedID
	
end


GO
