USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentTargetRpt]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
exec [proc_agentTargetRpt] @flag ='rpt',@year ='2014',@month ='February',@agentId='5563'
*/
CREATE proc [dbo].[proc_agentTargetRpt]
(	 
	 @flag				VARCHAR(50)
	,@agentId			VARCHAR(50)		= NULL
	,@year				varchar(50)		= null
	,@month				varchar(50)		= null
	,@pageNumber			INT			= 1
	,@pageSize				INT			= 50	
	,@user				varchar(50)		= null
) 
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	declare @sql varchar(max)
	IF @flag='rpt'
	BEGIN	
		declare @tempTable table(agentId  int, 
					sendTarget int, sendActual int, sendChange money, sendBonus int, sendPoint money,
					eduPayTarget int, eduPayActual int, eduPayChange money,eduPayBonus int, eduPayPoint money,
					topupTarget int, topupActual int, topupChange money,topupBonus int, topupPoint money, totalBonus int, totalPoint money) 

		insert into @tempTable (agentId,sendTarget,sendActual,sendChange,sendPoint, eduPayTarget , eduPayActual , eduPayChange, eduPayPoint ,topupTarget , topupActual , topupChange,topupPoint)
		select   agentId
				,ST = isnull(targentTxn,0)
				,SA = isnull(actualTxn,0)
				,SC = cast((isnull(actualTxn,0) - isnull(targentTxn,0)) as float)/cast(isnull(targentTxn,0) as float) * 100	
				,SP = round(0.70 * (cast(isnull(actualTxn,0) as float)/cast(isnull(targentTxn,0) as float)),3)
				,ET = isnull(targetEduPay,0)
				,EA = isnull(actualEduPay,0)
				,EC = (cast(isnull(actualEduPay,0) as float) - cast(isnull(targetEduPay,0) as float))/cast(isnull(targetEduPay,0) as float) * 100
				,EP = case when round(0.20 * (cast(isnull(actualEduPay,0) as float)/cast(isnull(targetEduPay,0) as float)),3) 
							> =  0.2 then 0.2 
								else round(0.20 * (cast(isnull(actualEduPay,0) as float)/cast(isnull(targetEduPay,0) as float)),3) end
				,TT = isnull(targetTopup,0)
				,TA = isnull(actualTopup,0)
				,TC = cast((isnull(actualTopup,0) - isnull(targetTopup,0)) as float)/cast(isnull(targetTopup,0) as float) * 100 
				,TP = case when round(0.10 * (cast(isnull(actualTopup,0) as float)/cast(isnull(targetTopup,0) as float)),3) 
						>= 0.1 then 0.1 
							else round(0.10 * (cast(isnull(actualTopup,0) as float)/cast(isnull(targetTopup,0) as float)),3) end
		from RemittanceLogData.dbo.agentTarget at with(nolock) 
		where yr = @year and yrMonth = @month and
		agentId = isnull(@agentId,at.agentId)

		update @tempTable set sendBonus = case when sendChange >= 10 then '2' when sendChange <= -20 then '-1' else '0' end,
								eduPayBonus = case when eduPayChange >= 10 then '2' when eduPayChange <= -20 then '-1' else '0' end,
								topupBonus = case when topupChange >= 10 then '2' when topupChange <= -20 then '-1' else '0' end


		update @tempTable set totalBonus = sendBonus + eduPayBonus + topupBonus, 
				totalPoint = sendPoint + eduPayPoint + topupPoint

		select		 [Agent_Id] = a.agentId
					,[Agent_Zone] = am.agentState
					,[Agent_District] = am.agentDistrict
					,[Agent_Name] = am.agentName  
					,[Send Transaction_Target] = sendTarget 
					,[Send Transaction_Actual] = sendActual 
					,[Send Transaction_Change] = sendChange 
					,[Send Transaction_Bonus] =  sendBonus 
					,[Send Transaction_Point] =  sendPoint 
					,[EduPay_Target] = eduPayTarget 
					,[EduPay_Actual] = eduPayActual 
					,[EduPay_Change] = eduPayChange 
					,[EduPay_Bonus] = eduPayBonus 
					,[EduPay_Point] = eduPayPoint 
					,[Topup_Target] = topupTarget 
					,[Topup_Actual] = topupActual 
					,[Topup_Change] = topupChange 
					,[Topup_Bonus] = topupBonus 
					,[Topup_Point] = topupPoint 
					,[Total_Bonus] = totalBonus
					,[Total_Point] = totalPoint
		from @tempTable a inner join agentMaster am with(nolock) on a.agentId = am.agentId
		order by totalBonus desc

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Year' head, @year value 
		union all
		SELECT  'Month' head, @month value
		union all
		select 'Agent' head, case when @agentId is not null then (select agentName from agentMaster with(nolock) where agentId = @agentId)
		else 'All' end


		SELECT 'Agent Target Report ' title
	END




GO
