USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_INFICARE_payTxn]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_INFICARE_payTxn]
	 @flag					VARCHAR(50) = NULL
	,@tranIds				VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON

IF @flag = 'p'
BEGIN
	CREATE TABLE #tranIdTable(tranId BIGINT)
	INSERT INTO #tranIdTable
	SELECT val FROM dbo.SplitXML(',', @tranIds)
END


GO
