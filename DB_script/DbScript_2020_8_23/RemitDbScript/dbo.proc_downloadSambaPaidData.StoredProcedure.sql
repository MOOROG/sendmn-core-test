USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_downloadSambaPaidData]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC proc_downloadSambaPaidData @flag ='r',@fromDate='06/02/2014',@toDate='06/03/2014'
EXEC proc_downloadSambaPaidData @flag ='s',@fromDate='06/02/2014',@toDate='06/03/2014'


*/

CREATE proc [dbo].[proc_downloadSambaPaidData]
		 @user				VARCHAR(50)		= NULL
		,@flag				VARCHAR(50)		= NULL
		,@fromDate			VARCHAR(50)		= NULL
		,@toDate			VARCHAR(50)		= NULL
		
AS
SET NOCOUNT ON;
BEGIN
	IF @flag='r'
	BEGIN
		SELECT 
		     ICN	= dbo.FNADecryptString(controlNo)
		    ,TOD	= CONVERT(varchar, approvedDate,103)
		    ,CODE	= '00001'
		    ,[USER] = 'SANJEEV'
		    ,[USER] = 'SANJEEV'
		    ,POD	= CONVERT(VARCHAR, paidDate,103)
		 FROM remitTran WITH(NOLOCK) WHERE sAgent = '4876'
		 AND paidDate BETWEEN @fromDate AND @toDate 
		RETURN;
	END

	IF @flag='s'
	BEGIN
		SELECT 
		     ICN	= dbo.FNADecryptString(controlNo)
		    ,TOD	= CONVERT(varchar, approvedDate,103)
		    ,CODE	= '00001'
		    ,[USER] = 'SANJEEV'
		    ,[USER] = 'SANJEEV'
		    ,POD	= CONVERT(VARCHAR, paidDate,103)
		 FROM remitTran WITH(NOLOCK) WHERE sAgent = '4876'
		 AND paidDate BETWEEN @fromDate AND @toDate 
		RETURN;
	END
END




GO
