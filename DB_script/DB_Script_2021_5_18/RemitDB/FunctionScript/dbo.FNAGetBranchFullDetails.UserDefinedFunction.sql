USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetBranchFullDetails]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetBranchFullDetails](@sBranch INT)
RETURNS @table TABLE (sBranch INT,sBranchName VARCHAR(100), sAgent INT, sAgentName VARCHAR(100)
	, sSuperAgent INT, sSuperAgentName VARCHAR(100),pCountry VARCHAR(50),pCountryId INT,pSuperAgent INT,pSuperAgentName VARCHAR(100))


AS

BEGIN

IF EXISTS(SELECT 'A' FROM agentMaster (NOLOCK) WHERE agentId = @sBranch AND agentType = 2904)
BEGIN
 INSERT INTO @table (sBranch,sBranchName, sAgent, sAgentName,sSuperAgent,sSuperAgentName,pCountry,pCountryId,pSuperAgent,pSuperAgentName) 
 --SELECT @sBranch,agentName,parentId,1002,'Nepali Agent' from agentMaster(NOLOCK) where agentId = @sBranch
 SELECT am1.agentId ,
        am1.agentName ,
        am2.agentId ,
        am2.agentName ,
        am3.agentId ,
        am3.agentName,
		pCountry='Mongolia',
		pCountryI='142',
		pSuperAgent='394399',
		pSuperAgentName='Mongolia Super Agent'
 FROM   dbo.agentMaster am1 ( NOLOCK )
        INNER JOIN dbo.agentMaster am2 ( NOLOCK ) ON am2.agentId = am1.parentId
        INNER JOIN dbo.agentMaster am3 ( NOLOCK ) ON am3.agentId = am2.parentId
 WHERE  am1.agentId = @sBranch
END
ELSE
BEGIN
	 INSERT INTO @table (sBranch,sBranchName, sAgent, sAgentName,sSuperAgent,sSuperAgentName,pCountry,pCountryId,pSuperAgent,pSuperAgentName) 
     SELECT am1.agentId ,
            am1.agentName ,
            am1.agentId ,
            am1.agentName ,
            am2.agentId ,
            am2.agentName,
			pCountry='Mongolia',
			pCountryI='142',
			pSuperAgent='394399',
			pSuperAgentName='Mongolia Super Agent'
     FROM   dbo.agentMaster am1 ( NOLOCK )
    INNER JOIN dbo.agentMaster am2 ( NOLOCK ) ON am2.agentId = am1.parentId
     WHERE  am1.agentId = @sBranch
END
RETURN

END


GO
