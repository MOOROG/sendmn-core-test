USE [SendMnPro_Account]
GO
/****** Object:  View [dbo].[VW_PostedAccountDetail]    Script Date: 5/18/2021 5:21:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_PostedAccountDetail] AS 
SELECT tran_date,acc_num,gl_sub_head_code,T.FCY_CURR,T.USD_RATE,T.ref_num,acct_type_code,T.USD_AMT,PART_TRAN_TYPE,TRAN_AMT
,T.TRAN_ID,field2,CREATED_DATE,T.COMPANY_ID,field1,D.tran_particular,SendMargin
FROM tran_master(NOLOCK) T
INNER JOIN tran_masterDETAIL D(NOLOCK) ON D.ref_num = T.ref_num AND T.tran_type = D.tran_type

GO
