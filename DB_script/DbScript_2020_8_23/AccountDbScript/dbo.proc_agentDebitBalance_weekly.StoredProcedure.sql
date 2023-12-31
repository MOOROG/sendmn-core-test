ALTER  PROC  [dbo].[proc_agentDebitBalance_weekly]
@DATE		VARCHAR(10)		= NULL
,@agentGrp	VARCHAR(100)	= NULL --= 'Proprietorship Firm'
,@agentId	INT				= null
,@trantype	VARCHAR(5)		= NULL
,@FLAG		VARCHAR(5)

AS
SET NOCOUNT ON
DECLARE @Title varchar(100) ='Agent Summary Report - Weekly'
DECLARE @agentName VARCHAR(150) = (SELECT agent_name FROM dbo.agentTable WHERE map_code = 1043)
DECLARE @agentGroup VARCHAR(80) = (SELECT detailTitle FROM SendMnPro_Remit.dbo.staticDataValue WHERE valueId = @agentGrp)

IF @FLAG ='RPT'
BEGIN

declare @sql varchar(max)

	set @sql ='create table ##temp(acct_name varchar(100),[Agent Group] varchar(50),part_tran_type varchar(10),
	['+cast(DATEADD(d,-6,cast(@DATE as date)) as varchar)+'] money,['+cast(DATEADD(d,-5,cast(@DATE as date)) as varchar)+'] money
	,['+cast(DATEADD(d,-4,cast(@DATE as date)) as varchar)+'] money,['+cast(DATEADD(d,-3,cast(@DATE as date)) as varchar)+'] money
	,['+cast(DATEADD(d,-2,cast(@DATE as date)) as varchar)+'] money,['+cast(DATEADD(d,-1,cast(@DATE as date)) as varchar)+'] money,
	['+cast(cast(@DATE as date) as varchar)+'] money,[Sum Balance] money)'

IF OBJECT_ID('tempdb..##temp') IS NOT NULL
   DROP TABLE ##temp

exec(@sql)


INSERT INTO ##temp
SELECT *,'Sum Balance' = (Y.First + Y.Second +Y.Third+Y.Fourth + Y.Fifth + Y.Sixth + Y.Seventh )
FROM (
SELECT acct_name,CONSTITUTION as 'Agent Group',ISNULL(upper(@trantype),'') 'part_tran_type'
	,CASE WHEN @trantype ='DR' AND SUM(X.[1]) <0 THEN  SUM(X.[1]) WHEN @trantype ='CR' AND SUM(X.[1]) >0 THEN SUM(X.[1]) ELSE 0 END 'First'
	,CASE WHEN @trantype ='DR' AND SUM(X.[2]) <0 THEN  SUM(X.[2]) WHEN @trantype ='CR' AND SUM(X.[2]) >0 THEN SUM(X.[2]) ELSE 0 END 'Second'
	,CASE WHEN @trantype ='DR' AND SUM(X.[3]) <0 THEN  SUM(X.[3]) WHEN @trantype ='CR' AND SUM(X.[3]) >0 THEN SUM(X.[3]) ELSE 0 END 'Third'
	,CASE WHEN @trantype ='DR' AND SUM(X.[4]) <0 THEN  SUM(X.[4]) WHEN @trantype ='CR' AND SUM(X.[4]) >0 THEN SUM(X.[4]) ELSE 0 END 'Fourth'
	,CASE WHEN @trantype ='DR' AND SUM(X.[5]) <0 THEN  SUM(X.[5]) WHEN @trantype ='CR' AND SUM(X.[5]) >0 THEN SUM(X.[5]) ELSE 0 END 'Fifth'
	,CASE WHEN @trantype ='DR' AND SUM(X.[6]) <0 THEN  SUM(X.[6]) WHEN @trantype ='CR' AND SUM(X.[6]) >0 THEN SUM(X.[6]) ELSE 0 END 'Sixth'
	,CASE WHEN @trantype ='DR' AND SUM(X.[7]) <0 THEN  SUM(X.[7]) WHEN @trantype ='CR' AND SUM(X.[7]) >0 THEN SUM(X.[7]) ELSE 0 END 'Seventh'
	----,SUM(X.[2]) 'Second',SUM(X.[3]) 'Third',SUM(X.[4]) 'Fourth'
	----,SUM(X.[5]) 'Fifth',SUM(X.[6]) 'Sixth',SUM(X.[7]) 'Seventh' 
	FROM (
		SELECT c.acct_name,stv.detailTitle as CONSTITUTION
		,'1' = CASE WHEN CONVERT(VARCHAR,balDate,101) = DATEADD(d,-6,cast(@DATE as date)) THEN SUM(t.amt) ELSE 0 END 
		,'2' = CASE WHEN CONVERT(VARCHAR,balDate,101) = DATEADD(d,-5,cast(@DATE as date)) THEN SUM(t.amt) ELSE 0 END 
		,'3' = CASE WHEN CONVERT(VARCHAR,balDate,101) = DATEADD(d,-4,cast(@DATE as date)) THEN SUM(t.amt) ELSE 0 END 
		,'4' = CASE WHEN CONVERT(VARCHAR,balDate,101) = DATEADD(d,-3,cast(@DATE as date)) THEN SUM(t.amt) ELSE 0 END 
		,'5' = CASE WHEN CONVERT(VARCHAR,balDate,101) = DATEADD(d,-2,cast(@DATE as date)) THEN SUM(t.amt) ELSE 0 END 
		,'6' = CASE WHEN CONVERT(VARCHAR,balDate,101) = DATEADD(d,-1,cast(@DATE as date)) THEN SUM(t.amt) ELSE 0 END 
		----,'7' = CASE WHEN cast(@DATE as date) = CONVERT(VARCHAR,GETDATE(),101) then  
		----	SUM(ISNULL(c.clr_bal_amt,0) + ISNULL(Ka.todaysPaid,0) - ISNULL(Ka.todaysSend,0) + ISNULL(Ka.todaysPO,0)  - ISNULL(Ka.todaysEP,0) +ISNULL(Ka.todaysCancel,0) ) 
		----	ELSE CASE WHEN CONVERT(VARCHAR,balDate,101) = CAST(@DATE as date) THEN SUM(t.amt) ELSE 0 END 
		----	END 
		,'7' = CASE WHEN CONVERT(VARCHAR,balDate,101) = cast(@DATE as date) THEN SUM(t.amt) ELSE 0 END 
		FROM RemittanceLogData.dbo.agentClosingBalanceHistory t with(nolock)
		inner join SendMnPro_Remit.dbo.agentMaster am with(nolock) on am.agentId = t.agentId 
		inner join agentTable ka WITH(NOLOCK) ON am.mapCodeInt = ka.map_code
		INNER JOIN ac_master c WITH(NOLOCK) ON ka.agent_id = c.agent_id 
		left join SendMnPro_Remit.dbo.staticDataValue stv with(nolock) on valueId = am.agentGrp
		where acct_rpt_code = '20' 
		and t.balDate between dateadd(d,-6,cast(@DATE as date)) and @DATE
		AND ISNULL(stv.detailTitle,'') = ISNULL(@agentGrp,ISNULL(stv.detailTitle,''))
		AND kA.AGENT_ID = ISNULL(@agentId,kA.AGENT_ID)
		GROUP BY t.balDate,c.acct_name,stv.detailTitle
	)X
	GROUP BY acct_name,CONSTITUTION
)Y 
 WHERE Y.First <>0 OR Y.Second <> 0 OR Y.Third <> 0 OR Y.Fourth <> 0 OR Y.Fifth <>0 OR Y.Sixth <>0 OR Y.Seventh <>0
ORDER BY acct_name 

	SELECT * FROM ##temp

	
	IF OBJECT_ID('tempdb..##temp') IS NOT NULL
   DROP TABLE ##temp

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	SELECT 'As on Date' head, CONVERT(VARCHAR(10), @DATE, 101) value
	UNION ALL
	SELECT 'Agent Name' head, @agentName value UNION ALL 
	SELECT 'Agent Group' head,@agentGroup UNION ALL 
	SELECT 'Tran Type' head,@trantype

	SELECT title = @Title

RETURN
END

GO
