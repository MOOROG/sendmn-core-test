USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetSuperAgent]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[FNAGetSuperAgent](@agentId INT)
RETURNS varchar(200)
AS
BEGIN

		declare @newAgentId as int,@oldAgentid as int,@superAgentId as int
		set @newAgentId	=3824
		if exists(select * from agentMaster where agentId=@newAgentId and agentType=2902)
		begin
			set @superAgentId= @newAgentId
		
		end 
		set @oldAgentid= @newAgentId;
		select @newAgentId= parentId from agentMaster  where agentId=@oldAgentid

		if exists(select * from agentMaster where agentId=@newAgentId and agentType=2902)
		begin
			set @superAgentId= @newAgentId

		end 

		set @oldAgentid= @newAgentId;
		select @newAgentId= parentId from agentMaster  where agentId=@oldAgentid
		if exists(select * from agentMaster where agentId=@newAgentId and agentType=2902)
		begin
			set @superAgentId= @newAgentId
	
		end 
		set @oldAgentid= @newAgentId;
		select @newAgentId= parentId from agentMaster  where agentId=@oldAgentid
		if exists(select * from agentMaster where agentId=@newAgentId and agentType=2902)
		begin
			set @superAgentId= @newAgentId
	
		end 
		return @superAgentId
		
end
GO
