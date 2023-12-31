USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_HoUserTxn]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_HoUserTxn](
	 @user varchar(30)=NULL
	,@flag varchar(10)=NULL
	,@fromDate varchar(40)=NULL
	,@toDate varchar(40)=NULL
)AS
BEGIN
	IF @flag='rpt'
	BEGIN
		SELECT 
			    [Tran Id]=rt.id
			   ,[Control No]=rt.controlNo
			   ,[Sender]=rt.senderName
			   ,[Receiver]=rt.receiverName
			   ,[User Full Name]=x.userFullName
			   ,[Sending Branch]=rt.sBranchName
			   ,[Amount]=dbo.showDecimal(rt.pAmt)
			   ,[Payout Branch]=rt.pBranchName
			   ,[Approved Date]=rt.approvedDate
			   ,[Tran Status]=tranStatus
		FROM 
		(
			   SELECT 
					  userFullName = ISNULL( ' ' + au.firstName, '') + ISNULL( ' ' + au.middleName, '') + ISNULL( ' ' + au.lastName, '')
			   FROM dbo.applicationUsers au WITH(NOLOCK) WHERE agentId = 1001
		)x INNER JOIN remitTran rt WITH(NOLOCK) ON rt.senderName = x.userFullName OR rt.receiverName = x.userFullName
		WHERE rt.approvedDate  BETWEEN @fromDate AND @toDate+' 23:59:59'


		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
					
		SELECT 'From Date' head,@fromDate VALUE
		UNION ALL 
		SELECT 'TO Date' head,@toDate VALUE		

		SELECT 'Ho User Vs Transaction' title
	END		
END


GO
