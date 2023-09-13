USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ttt]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[ttt]
as

SELECT 
	 x.dscDetailId
	,x.fromAmt  
	,x.toAmt
	,x.pcnt
	,x.minAmt
	,x.maxAmt
	,modType = 'INSERT'
FROM (
	SELECT	1 dscDetailId, 1 fromAmt, 1000 toAmt, 0 pcnt, 10 minAmt, 10 maxAmt UNION ALL
	SELECT	2, 1001 , 100000 , 0 , 150 , 150 UNION ALL
	SELECT	3, 100001 , 10000000 , 0 , 550 , 550
) x



GO
