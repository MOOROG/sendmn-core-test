USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_AgentTranReport1]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC proc_AgentTranReport1 @agentId = '9' ,
@fromDate = 'May  1 2012 12:00AM' ,@tranId = '2' ,@flag = 'S'


*/

CREATE procEDURE [dbo].[proc_AgentTranReport1]
	 @flag					VARCHAR(20)
	,@agentid				varchar(10)	
	,@fromDate				varchar(20)	= NULL
	,@CNO					varchar(40)	= NULL
	,@tranId					varchar(40)	= NULL

AS

SET NOCOUNT ON;


DECLARE @DATEPARAM VARCHAR(30),@TRNAGENT VARCHAR(30),@SQL VARCHAR(MAX)
,@NAME VARCHAR(30),@ADDRESS VARCHAR(30),@TRNFLG CHAR(3)
SET @NAME = 'Sender Name'
SET @ADDRESS = 'Sender Address'
SET @TRNFLG = 'ts.' 

IF @flag= 'P'
BEGIN
	SET @NAME = 'Receiver Name'
	SET @ADDRESS = 'Receiver Address'
	SET @TRNFLG = 'tr.' 
END


--,@flag CHAR(1),@fromDate VARCHAR(20),@toDate VARCHAR(20)
--SET @flag ='S'
--SET @toDate = '2012-4-12'
--SET @fromDate = '2012-2-2'


SET @DATEPARAM  = CASE WHEN @flag ='S' THEN 'approvedDate'
							WHEN @flag ='P' THEN 'rt.paidDate'
							WHEN @flag ='C' THEN 'rt.cancelApprovedDate'			END
							
SET @TRNAGENT  = CASE WHEN @flag ='S' THEN 'RT.sAgent'
							WHEN @flag ='P' THEN 'RT.PAgent'
							WHEN @flag ='C' THEN 'RT.sAgent'	END
					
							
SET @SQL='			
SELECT 
	 [Date] = CONVERT(VARCHAR,RT.TRNDATE ,101)
	,[Reference No] =''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?tranId=''+CAST(rt.id AS VARCHAR)+'''''')">''+ dbo.FNADecryptString(rt.controlNo) + ''</a>''
	,[Amount] = rt.tAmt
	,[Service Charge] = rt.serviceCharge
	,[Sending Agent] = sa.agentName
	,['+@NAME+'] = '+@TRNFLG+'firstName + ISNULL('' '' + '+@TRNFLG+'middleName, '''') + ISNULL('' '' + '+@TRNFLG+'lastName1, '''') + ISNULL('' '' + '+@TRNFLG+'lastName2, '''')
	,['+@ADDRESS+'] = '+@TRNFLG+'address	
	,[Tran Status] = rt.tranStatus
	
FROM (
		
		SELECT
			id,controlNo,tAmt,serviceCharge,'+@DATEPARAM+' [TRNDATE],'+@TRNAGENT+' [sAgent],tranStatus
		FROM remitTran rt WITH(NOLOCK)
		WHERE id = '''+@tranId+''' 
		AND '+@TRNAGENT+'='+@agentid+'
) rt'

IF @flag = 'S' 
BEGIN
	SET @SQL= @SQL + ' INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId '
END
IF @flag = 'C' 
BEGIN
	SET @SQL= @SQL + ' INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId '
END
IF @flag = 'P' 
BEGIN
	SET @SQL= @SQL + ' INNER JOIN tranReceivers tr WITH(NOLOCK) ON rt.id = tr.tranId '
END

SET @SQL= @SQL +'INNER JOIN agentMaster sa WITH(NOLOCK) ON RT.sAgent = CAST(sa.agentId AS VARCHAR) '
			

print @SQL
EXEC(@SQL)


EXEC proc_errorHandler '0', 'Report has been prepared successfully.', @agentid

SELECT 'Tran Date' head, CONVERT(VARCHAR(10), @fromDate, 101) value
UNION ALL
SELECT 'Control No' head, CONVERT(VARCHAR(10), @CNO, 101) value

SELECT 'Transaction Report' title

GO
