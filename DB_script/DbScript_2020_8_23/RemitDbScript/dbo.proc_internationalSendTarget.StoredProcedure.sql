USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_internationalSendTarget]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_internationalSendTarget](
		 @flag							 VARCHAR(50)	= NULL
	    ,@year							 VARCHAR(20)    = NULL
	    ,@month							 VARCHAR(50)    = NULL 
		,@branchId						 VARCHAR(50)	= NULL	
		,@user							 VARCHAR(50)	= NULL
		,@userType						 VARCHAR(2)		= NULL
		,@agentId						 INT			= NULL
		,@countryId						 VARCHAR(50)	= NULL
)AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN
	DECLARE 
		 @previousMonth					VARCHAR(20)
		,@previousYr					VARCHAR(20)
		,@StartDate						VARCHAR(20)
		,@previousMonthDate				VARCHAR(20)
		,@incentive						VARCHAR(MAX)
	IF @flag='s'
	BEGIN

		select @month = datename(month,getdate())
	    select @year = datepart(year,getdate())
		SET @StartDate = CONVERT(DateTime, LEFT(@month, 3) + ' 1 '+@year+'', 100);			
		
		SELECT  TOP 1 
				 [Target]	=isnull(targentTxn,0)
				,[Actual]	=isnull(actualTxn,0)
				,[Remaining]=ISNULL(targentTxn,0)-ISNULL(actualTxn,0)
				,[PreviousActual] = isnull(preMonthActual,0)
				,head = '<span class=\"color-red\">Txn count till <strong>'+@month+' '+cast(DATEPART(day,getdate())-1 as varchar)+'</strong></span>'
		FROM RemittanceLogData.dbo.agentTarget WITH(NOLOCK) 
		WHERE agentId = @branchId  
			AND yr =  @year  
			AND yrMonth =  @month 
			AND userName = @user

		SELECT @incentive WHERE 1=2
		SELECT @incentive head

	END
END





GO
