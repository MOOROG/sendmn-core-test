USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNACheckWsAuthentication]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNACheckWsAuthentication](
  @userName   VARCHAR(50) = NULL
 ,@password   VARCHAR(50) = NULL
 ,@agentCode   VARCHAR(50) = NULL
)
RETURNS INT

AS
BEGIN

DECLARE @status INT = 1

IF ISNULL(@userName, '') = 'sch_admin' AND ISNULL(@password, '') = 'on1y!m3r3m!t' AND ISNULL(@agentCode, '') = 'IMEHO'
BEGIN
 SET @status = 0
END
ELSE
 SET @status = 1
 
RETURN  @status
END 

--SELECT dbo.FNACheckWsAuthentication('','', NULL)
GO
