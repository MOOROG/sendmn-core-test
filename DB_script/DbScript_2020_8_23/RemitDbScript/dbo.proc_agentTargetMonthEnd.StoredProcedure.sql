USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentTargetMonthEnd]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	/*
	EXEC [proc_agentTargetMonthEnd] @flag = 'month-end', @year = '2014', @month = 'February', @user ='dipesh'
	*/

CREATE proc [dbo].[proc_agentTargetMonthEnd]
 		 @flag		VARCHAR(50)	= NULL
		,@year		varchar(20) = null
		,@month		varchar(50) = null 
		,@user		varchar(50)	= null


AS
SET NOCOUNT ON
SET XACT_ABORT ON
IF @flag='month-end'
BEGIN	
		declare @StartDate varchar(20),@EndDate varchar(20),@nextMonthDate varchar(20),@nextMonth varchar(50),@nextYear varchar(20),
		@msg varchar(max)
		
		SET @StartDate = CONVERT(DateTime, LEFT(@month, 3) + ' 1 '+@year+'', 100);
		SET @EndDate = DATEADD(MONTH, 1, @StartDate) - 1;

		set @StartDate = convert(varchar,cast(@StartDate as datetime),101)
		set @EndDate = convert(varchar,cast(@EndDate as datetime),101)		

		set @nextMonthDate = dateadd(day,1,@EndDate)
		select @nextMonth = datename(month,@nextMonthDate)
	    select @nextYear = datepart(year,@nextMonthDate)

		if not exists(select 'x' from RemittanceLogData.dbo.agentTarget with(nolock) where yr = @year and yrMonth = @month)
		begin
			set @msg ='No Data Found for the ['+@month+'] to month-end.'
			EXEC proc_errorHandler '1', @msg, NULL
			return;
		end

		if not exists(select 'x' from RemittanceLogData.dbo.agentTarget with(nolock) where yr = @nextYear and yrMonth = @nextMonth)
		begin
			set @msg ='Please setup target for the next month ['+@nextMonth+'] to month end.'
			EXEC proc_errorHandler '1', @msg, NULL
			return;
		end

		declare @tempTable table(agentId  int, 
					sendChange money, sendBonus int, sendPoint money,
					eduPayChange money,eduPayBonus int, eduPayPoint money,
					topupChange money,topupBonus int, topupPoint money, totalBonus int, totalPoint money) 


		insert into @tempTable (agentId,sendChange,sendPoint, eduPayChange, eduPayPoint,topupChange,topupPoint)
		select   agentId
				,SC = cast((isnull(actualTxn,0) - isnull(targentTxn,0)) as float)/cast(isnull(targentTxn,0) as float) * 100	
				,SP = round(0.70 * (cast(isnull(actualTxn,0) as float)/cast(isnull(targentTxn,0) as float)),3)
				,EC = (cast(isnull(actualEduPay,0) as float) - cast(isnull(targetEduPay,0) as float))/cast(isnull(targetEduPay,0) as float) * 100
				,EP = case when round(0.20 * (cast(isnull(actualEduPay,0) as float)/cast(isnull(targetEduPay,0) as float)),3) 
							> =  0.2 then 0.2 
								else round(0.20 * (cast(isnull(actualEduPay,0) as float)/cast(isnull(targetEduPay,0) as float)),3) end
				,TC = cast((isnull(actualTopup,0) - isnull(targetTopup,0)) as float)/cast(isnull(targetTopup,0) as float) * 100 
				,TP = case when round(0.10 * (cast(isnull(actualTopup,0) as float)/cast(isnull(targetTopup,0) as float)),3) 
						>= 0.1 then 0.1 
							else round(0.10 * (cast(isnull(actualTopup,0) as float)/cast(isnull(targetTopup,0) as float)),3) end
		from RemittanceLogData.dbo.agentTarget at with(nolock) 
		where yr = @year and yrMonth = @month

		update @tempTable set sendBonus = case when sendChange >= 10 then '2' when sendChange <= -20 then '-1' else '0' end,
								eduPayBonus = case when eduPayChange >= 10 then '2' when eduPayChange <= -20 then '-1' else '0' end,
								topupBonus = case when topupChange >= 10 then '2' when topupChange <= -20 then '-1' else '0' end


		update @tempTable set totalBonus = sendBonus + eduPayBonus + topupBonus, 
								totalPoint = sendPoint + eduPayPoint + topupPoint		


		update RemittanceLogData.dbo.agentTarget 
				set  totPoint = isnull(b.totalPoint,0)
					,totBonus = isnull(a.totBonus,0) + isnull(b.totalBonus,0)
					,monthEndBy = @user
					,monthEndDate = getdate()
				from RemittanceLogData.dbo.agentTarget a,
					(
						select * from @tempTable 
					)b where a.agentId = b.agentId
						and yr = @year and yrMonth = @month
		
		
		update RemittanceLogData.dbo.agentTarget 
				set  totBonus = isnull(a.totBonus,0) + isnull(b.totalBonus,0)
					,totPoint = isnull(b.totalPoint,0) 
				from RemittanceLogData.dbo.agentTarget a,
					(
						select * from @tempTable 
					)b where a.agentId = b.agentId
						and yr = @nextYear and yrMonth = @nextMonth

		EXEC proc_errorHandler '0', 'Month-End has been done successfully.', NULL
END




GO
