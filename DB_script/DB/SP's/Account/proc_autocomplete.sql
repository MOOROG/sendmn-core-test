use fastmoneypro_account
go

ALTER PROC [dbo].[proc_autocomplete] (
	 @category VARCHAR(50) 
	,@searchText VARCHAR(50) 
	,@param1 VARCHAR(50) = NULL
	,@param2 VARCHAR(50) = NULL
	,@param3 VARCHAR(50) = NULL	
)
AS

DECLARE @SQL AS VARCHAR(MAX)
IF @category = 'acInfo'
BEGIN
	IF LEN(@searchText) < 3
	BEGIN
		Select TOP 20 acct_num  as value,acct_num+' | '+acct_name as name
		from ac_master a WITH (NOLOCK) 
		where 1 = 2
		--and a.gl_code <> 0
		RETURN
	END

	DECLARE @LastSearch VARCHAR(50)

	IF @searchText LIKE '%-%'
		SELECT @searchText=REPLACE(@searchText,'-'+value,'') ,@LastSearch = value FROM DBO.Split('-',@searchText) WHERE ID = 2
	
	DECLARE @acList TABLE(value VARCHAR(20),name VARCHAR(300))
	
	--select top 10* from ac_master where GL_CODE = 0 and acct_type_code = 'RA'
	INSERT INTO @acList
	select value,value+' | '+ acct_name AS name from (
		Select distinct TOP 50 acct_num  as value,acct_name = CASE WHEN GL_CODE = 0 and acct_rpt_code = 'RA' THEN R.REFERRAL_NAME ELSE acct_name END
		from ac_master a WITH (NOLOCK) 
		LEFT JOIN FASTMONEYPRO_REMIT.DBO.REFERRAL_AGENT_WISE R(NOLOCK) ON R.ROW_ID = A.AGENT_ID AND A.GL_CODE = 0
		where (acct_name like @searchText + '%' OR REFERRAL_NAME LIKE @searchText + '%')
		--and ISNULL(acct_rpt_code, '') <> 'CA'
		--and a.gl_code <> 0
		UNION
		Select  distinct TOP 35 acct_num  as value, acct_name = CASE WHEN GL_CODE = 0 and acct_rpt_code = 'RA' THEN R.REFERRAL_NAME ELSE acct_name END
		from ac_master a WITH (NOLOCK) 
		LEFT JOIN FASTMONEYPRO_REMIT.DBO.REFERRAL_AGENT_WISE R(NOLOCK) ON R.ROW_ID = A.AGENT_ID AND A.GL_CODE = 0
		where acct_num like @searchText + '%'
		--and ISNULL(acct_rpt_code, '') <> 'CA'
		--and a.gl_code <>0
	)x order by acct_name

	IF @LastSearch IS NOT NULL
		SELECT top 30 * FROM @acList WHERE name LIKE '%'+@LastSearch + '%' 
	ELSE 
		SELECT top 30  * FROM @acList 
	RETURN
END
IF @category = 'acInfo-agent'
BEGIN
	IF LEN(@searchText) < 3
	BEGIN
		Select TOP 20 acct_num  as value,acct_num+' | '+acct_name as name
		from ac_master a WITH (NOLOCK) 
		where 1 = 2
		--and a.gl_code <> 0
		RETURN
	END


	IF @searchText LIKE '%-%'
		SELECT @searchText=REPLACE(@searchText,'-'+value,'') ,@LastSearch = value FROM DBO.Split('-',@searchText) WHERE ID = 2
	
	DECLARE @acList1 TABLE(value VARCHAR(20),name VARCHAR(300))
	
	INSERT INTO @acList1
	select value,value+' | '+ acct_name AS name from (
		Select distinct TOP 50 acct_num  as value,acct_name = CASE WHEN GL_CODE = 0 and acct_rpt_code = 'RA' THEN R.REFERRAL_NAME ELSE acct_name END
		from ac_master a WITH (NOLOCK) 
		LEFT JOIN FASTMONEYPRO_REMIT.DBO.REFERRAL_AGENT_WISE R(NOLOCK) ON R.ROW_ID = A.AGENT_ID AND A.GL_CODE = 0
		where (acct_name like @searchText + '%' OR REFERRAL_NAME LIKE @searchText + '%')
		and a.gl_code = 0
		UNION
		Select  distinct TOP 35 acct_num  as value, acct_name = CASE WHEN GL_CODE = 0 and acct_rpt_code = 'RA' THEN R.REFERRAL_NAME ELSE acct_name END
		from ac_master a WITH (NOLOCK) 
		LEFT JOIN FASTMONEYPRO_REMIT.DBO.REFERRAL_AGENT_WISE R(NOLOCK) ON R.ROW_ID = A.AGENT_ID AND A.GL_CODE = 0
		where acct_num like @searchText + '%'
		and a.gl_code = 0
		UNION
		Select  distinct TOP 35 acct_num  as value, acct_name = acct_name
		from ac_master a WITH (NOLOCK) 
		where (acct_name like @searchText + '%' OR acct_num like @searchText + '%')
		and a.acct_rpt_code = 'TCA'
	)x order by acct_name

	IF @LastSearch IS NOT NULL
		SELECT top 30 * FROM @acList1 WHERE name LIKE '%'+@LastSearch + '%' 
	ELSE 
		SELECT top 30  * FROM @acList1 
	RETURN
END
IF @category = 'acInfoUSD'
BEGIN
	IF LEN(@searchText) < 3
	BEGIN
		Select TOP 20 acct_num  as value,acct_num+' | '+acct_name as name
		from ac_master a WITH (NOLOCK) 
		where 1 = 2 AND usd_amt < 0
		and a.gl_code <> 0
		RETURN
	END

	IF @searchText LIKE '%-%'
		SELECT @searchText=REPLACE(@searchText,'-'+value,'') ,@LastSearch = value FROM DBO.Split('-',@searchText) WHERE ID = 2
	
	INSERT INTO @acList
	select value,value+' | '+ acct_name AS name from (
		Select TOP 50 acct_num  as value,acct_name+ ISNULL(' / '+ac_currency,' / KRW') as acct_name
		from ac_master a WITH (NOLOCK) 
		where ac_currency is not null and acct_name like @searchText + '%'
		and a.gl_code <> 0
		UNION
		Select TOP 35 acct_num  as value, acct_name+ ISNULL(' / '+ac_currency,' / KRW') as name
		from ac_master a WITH (NOLOCK) 
		WHERE ac_currency is not null and acct_num like @searchText + '%'
		and a.gl_code <> 0
	)x order by acct_name

	IF @LastSearch IS NOT NULL
		SELECT top 30 * FROM @acList WHERE name LIKE '%'+@LastSearch + '%' 
	ELSE 
		SELECT top 30  * FROM @acList 
	RETURN
END
ELSE IF @category = 'gl_code'
BEGIN
	Select TOP 20 gl_code  as value,gl_name as name
	from dbo.GL_Group WITH (NOLOCK) 
	where gl_name like @searchText + '%'
	ORDER BY name
	RETURN
END
ELSE IF @category = 'agentInfo'
BEGIN
	Select TOP 20 map_code  as value,agent_name as name
	from dbo.agenttable WITH (NOLOCK) 
	where agent_name like @searchText + '%'
	ORDER BY name
	RETURN
END
ELSE IF @category = 'SearchGL_AC'
BEGIN
	SELECT * FROM (
		Select TOP 10 acct_num  as value,acct_num+' | '+acct_name as name
		from ac_master a WITH (NOLOCK) 
		where acct_name like @searchText + '%'
		and a.gl_code <> 0
		UNION ALL 
		SELECT TOP 10 cast(gl_code as varchar),gl_name FROM GL_Group (NOLOCK)
		WHERE gl_name like @searchText + '%'
	)X ORDER BY name
	RETURN
END
ELSE IF @category='sendingAgent'
BEGIN
	Select TOP 20 map_code ,agent_name
	from agentTable (NOLOCK)
	where AGENT_TYPE = 'Sending' 
	AND agent_name like @searchText + '%'
	order by agent_name
END
ELSE IF @category='receivingAgent'
BEGIN
	Select TOP 20 map_code ,agent_name
	from agentTable (NOLOCK)
	where AGENT_TYPE = 'Receiving' 
	AND agent_name like @searchText + '%'
	order by agent_name
END
ELSE IF @category='agentByGrp'
BEGIN
	IF @param1 IS NOT NULL
	BEGIN
	    Select TOP 20 agentId,agentName+'|'+CAST(agentId AS VARCHAR)
		from dbo.agentMaster (NOLOCK)
		where agentName like @searchText + '%' 
		AND agentGrp = @param1
		order by agentName
		RETURN
	END
	ELSE
	BEGIN
	    Select TOP 20 agentId,agentName+'|'+CAST(agentId AS VARCHAR)
		from dbo.agentMaster (NOLOCK)
		where agentName like @searchText + '%' 
		order by agentName
		RETURN
	END
	
END
ELSE IF @category='agentSettle'
BEGIN
	Select TOP 20 map_code,agent_name
	from dbo.agenttable (NOLOCK)
	where agent_name like @searchText + '%'
	AND agent_status <> 'n' AND AGENT_TYPE='receiving' AND (IsMainAgent ='y' OR ISNULL(central_sett,'n') ='n')
	order by agent_name

END
ELSE IF @category='sendingAgentRpt'
BEGIN
	Select TOP 20 at.agent_id ,at.agent_name
	from agentTable at (NOLOCK)
	inner join FastMoneyPro_remit.dbo.agentMaster am on am.agentId = at.map_code
	where AGENT_TYPE = 'receiving' 
	AND agent_name like @searchText + '%'
	and am.agentCountry = 'Nepal'  
	order by agent_name
END

ELSE IF @category='partydetail'
BEGIN
	Select TOP 20 agent_id,agent_name from agentTable (NOLOCK) WHERE  agent_name like @searchText + '%'
END

ELSE IF @category='bankCode'
BEGIN
select distinct BANKCODE,BANKCODE + ' - ' + BANKBRANCH from agentTable (NOLOCK)
where BANKCODE is not null and BANKCODE <> '' 
order by BANKCODE
END




