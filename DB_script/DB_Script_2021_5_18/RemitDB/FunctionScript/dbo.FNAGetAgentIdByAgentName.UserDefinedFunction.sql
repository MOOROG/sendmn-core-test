USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetAgentIdByAgentName]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select dbo.[GetAgentNameFromId](3)

CREATE function [dbo].[FNAGetAgentIdByAgentName](@AgentName VARCHAR(100))
returns BIGINT
as 
begin

	declare @AgentId as BIGINT,
			@agentCode VARCHAR(50)
	if @AgentName is null or @AgentName='' 
	begin
		set @AgentId=0
		return @AgentId;
	END
    
	IF @AgentName='mobile'
	BEGIN
	    SET @agentCode='MGO394442'
	END
	    SET @AgentId= (SELECT AgentId FROM dbo.agentMaster WHERE agentCode='MGO394442')
		RETURN @AgentId
end
GO
