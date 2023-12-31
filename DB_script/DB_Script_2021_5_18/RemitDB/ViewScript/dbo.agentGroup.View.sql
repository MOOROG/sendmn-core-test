USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[agentGroup]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[agentGroup]  
AS  
SELECT     
	 agentId
	,agentGrp AS groupId
	,isActive
	,isDeleted
	,createdDate
	,createdBy
	,modifiedDate
	,modifiedBy
	,approvedDate
	,approvedBy  
FROM dbo.agentMaster  
GO
