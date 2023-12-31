USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAgentNameFromId]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select dbo.[GetAgentNameFromId](3)

CREATE function [dbo].[GetAgentNameFromId](@ID int)
returns char(1000)
as 
begin

	declare @Full_Name as varchar(500)
	if @ID is null or @ID=0 or @ID='' 
	begin
		set @Full_Name='All Agents'
		return @Full_Name;
	end
	set @Full_Name = (	select agentName from agentmaster  with (nolock) 
					WHERE agentId = @ID)
	return @Full_Name
	
end
GO
