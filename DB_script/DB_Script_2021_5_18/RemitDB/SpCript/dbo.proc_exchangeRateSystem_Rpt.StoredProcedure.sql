USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_exchangeRateSystem_Rpt]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC proc_exchangeRateSystem_Rpt @user = 'admin' ,@cCountry =NULL ,@pCountry = NULL,
				@cAgent = NULL, @pAgent = NULL, 
				@cAgentGroup =NULL, @pAgentGroup =NULL, 
				@cBranch =NULL, @pBranch = NULL, 
				@cBranchGroup =NULL, @pBranchGroup = NULL

SELECT * FROM spExRate
 
*/
CREATE procEDURE [dbo].[proc_exchangeRateSystem_Rpt]
			  @flag			AS VARCHAR(50)=NULL
            , @user			AS VARCHAR(50)=NULL
            , @cCountry		AS VARCHAR(50)=NULL
            , @pCountry		AS VARCHAR(50)=NULL
            , @cAgent		AS VARCHAR(50)=NULL
            , @pAgent		AS VARCHAR(50)=NULL
            , @cAgentGroup	AS VARCHAR(50)=NULL
            , @pAgentGroup	AS VARCHAR(50)=NULL
            , @cBranch		AS VARCHAR(50)=NULL
            , @pBranch		AS VARCHAR(50)=NULL
            , @cBranchGroup AS VARCHAR(50)=NULL
            , @pBranchGroup AS VARCHAR(50)=NULL
            , @pageNumber	AS VARCHAR(50)=NULL
            , @pageSize		AS VARCHAR(50)=NULL
AS

SET NOCOUNT ON;
--SET @TODATE = @TODATE + ' 23:59:59'
DECLARE 
	 @NUM			INT
	,@ROWNUM		INT
	,@CLOSEAMT		MONEY
	,@REPORTHEAD	VARCHAR(40)
	,@maxReportViewDays	INT

SET @NUM=0
SET @pageSize = ISNULL(@pageSize,500)

	SET @pageNumber = ISNULL(@pageNumber,1)
	
	SELECT @maxReportViewDays=ISNULL(maxReportViewDays,60) FROM applicationUsers WHERE userName = @user
	

	SELECT  ROW_NUMBER() OVER(ORDER BY EX.spExRateId) [S.N.]
			,ISNULL(cast(tranType as varchar),'Any') [Tran Type]
			,B.countryName Collection_Country
			,ISNULL(CAST(CASE WHEN cAgent IS NULL THEN cAgentGroup else cAgent END AS VARCHAR),'All') [Collection_Agent/Group]
			,ISNULL(CAST(CASE WHEN cBranch IS NULL THEN cBranchGroup else cBranch END AS VARCHAR),'All')  [Collection_Branch/Group]
			,B1.countryName Payment_Country
			,ISNULL(CAST(CASE WHEN pAgent IS NULL THEN pAgentGroup else pAgent END AS VARCHAR),'All')  [Payment_Agent/Group]
			,ISNULL(CAST(CASE WHEN pBranch IS NULL THEN pBranchGroup else pBranch END AS VARCHAR),'All')  [Payment_Branch/Group]
			,cCurrency [Collection Rate_Currency]
			,cRate [Collection Rate_Rate]
			,cCurrHOMargin [Collection Rate_HO Margin]
			,cRate-cCurrHOMargin [Collection Rate_Agent Offer]
			,cCurrAgentMargin [Collection Rate_Agent Margin]
			,cRate-cCurrHOMargin+cCurrAgentMargin [Collection Rate_Customer Offer]		
			,pCurrency [Payment Rate_Currency]
			,pRate [Payment Rate_Rate]
			,pCurrHOMargin [Payment Rate_HO Margin]
			,pRate-pCurrHOMargin [Payment Rate_Agent Offer]
			,pCurrAgentMargin [Payment Rate_Agent Margin]
			,pRate-pCurrHOMargin+pCurrAgentMargin [Payment Rate_Customer Offer]
			,(pRate-pCurrHOMargin)/(cRate-cCurrHOMargin) [Sattlement Rate]
			,(pRate-pCurrHOMargin+pCurrAgentMargin)/(cRate-cCurrHOMargin+cCurrAgentMargin) [Customer Rate]
			,CAST(HIS.createdDate AS VARCHAR) +':'+HIS.createdBy+'</br>'+CAST(HIS.approvedDate AS VARCHAR)+':'+HIS.approvedBy [Last Update/Approve]
	FROM spExRate EX WITH(NOLOCK) INNER JOIN countryMaster B WITH(NOLOCK) ON EX.cCountry=B.countryId
	INNER JOIN countryMaster B1 WITH(NOLOCK) ON EX.pCountry=B1.countryId
	LEFT JOIN
	(
		select a.rowId,a.spExRateId,b.createdBy,b.createdDate,b.approvedBy,b.approvedDate from 
		(
			select max(rowId) rowId,spExRateId from spExRateHistory where approvedDate is not null
			group by spExRateId 
		)a 
		inner join
		(
			select * from spExRateHistory
		)b on a.rowId=b.rowId
	)HIS ON HIS.spExRateId=EX.spExRateId
	
	WHERE EX.cCountry =ISNULL(@cCountry,EX.cCountry)
		  AND ISNULL(EX.cCountry,'') =ISNULL(@cCountry,ISNULL(EX.cCountry,''))
		  AND ISNULL(EX.pCountry,'') =ISNULL(@pCountry,ISNULL(EX.pCountry,''))
		  AND ISNULL(EX.cAgent,'') =ISNULL(@cAgent,ISNULL(EX.cAgent,''))
		  AND ISNULL(EX.pAgent,'') =ISNULL(@pAgent,ISNULL(EX.pAgent,''))
		  AND ISNULL(EX.cAgentGroup,'') =ISNULL(@cAgentGroup,ISNULL(EX.cAgentGroup,''))
		  AND ISNULL(EX.pAgentGroup,'') =ISNULL(@pAgentGroup,ISNULL(EX.pAgentGroup,''))
		  AND ISNULL(EX.cBranch,'') =ISNULL(@cBranch,ISNULL(EX.cBranch,''))
		  AND ISNULL(EX.pBranch,'') =ISNULL(@pBranch,ISNULL(EX.pBranch,''))
		  AND ISNULL(EX.cBranchGroup,'') =ISNULL(@cBranchGroup,ISNULL(EX.cBranchGroup,''))
		  AND ISNULL(EX.pBranchGroup,'') =ISNULL(@pBranchGroup,ISNULL(EX.pBranchGroup,''))
		  AND EX.approvedDate IS NOT NULL

EXEC proc_errorHandler '0', 'Report has been prepared successfully.', @cAgent
if @cCountry is null
	set @cCountry='All'
else
	select @cCountry=countryName from countryMaster where countryId=@cCountry
if @pCountry is null
	set @pCountry='All'
else
	select @pCountry=countryName from countryMaster where countryId=@pCountry
	
	
if @cAgent is null
	set @cAgent='All'
else
	select @cAgent=agentName from agentMaster where agentId=@cAgent
	
if @pAgent is null
	set @pAgent='All'
else
	select @pAgent=agentName from agentMaster where agentId=@pAgent
	
if @cAgentGroup is null
	set @cAgentGroup='All'
else
	select @cAgentGroup=detailTitle from staticDataValue where valueId=@cAgentGroup
	
if @pAgentGroup is null
	set @pAgentGroup='All'
else
	select @pAgentGroup=detailTitle from staticDataValue where valueId=@pAgentGroup

if @pBranch is null
	set @pBranch='All'
else
	select @pBranch=agentName from agentMaster where agentId=@pBranch
	
if @cBranch is null
	set @cBranch='All'
else
	select @cBranch=agentName from agentMaster where agentId=@cBranch
	
if @cBranchGroup is null
	set @cBranchGroup='All'
else
	select @cBranchGroup=detailTitle from staticDataValue where valueId=@cBranchGroup
	
if @pBranchGroup is null
	set @pBranchGroup='All'
else
	select @pBranchGroup=detailTitle from staticDataValue where valueId=@pBranchGroup	
	
select 'Collection Country' head,@cCountry value
union all
select 'Collection Agent' head,@cAgent value
union all
select 'Collection Agent Group' head,@cAgentGroup value
union all
select 'Collection Branch' head,@cBranch value
union all
select 'Collection Branch Group' head,@cBranchGroup value
union all
select 'Payment Country' head,@pCountry value
union all
select 'Payment Agent' head,@pAgent value
union all
select 'Payment Agent Group' head,@pAgentGroup value
union all
select 'Payment Branch' head,@pBranch value
union all
select 'Payment Branch Group' head,@pBranchGroup value

SELECT 'Exchange Rate System Report' title


GO
