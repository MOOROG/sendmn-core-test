USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetAgentRating]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetAgentRating](@flag varchar(10),@riskCategory varchar(50),@arDetailId INT)  
RETURNS varchar(500) AS  
BEGIN 
	DECLARE  @result varchar(50)
	
	DECLARE @rating VARCHAR(10),@score VARCHAR(10)
	
	--SET @result=(SELECT top 1 rating +' ('+ CAST(dbo.ShowDecimal(score) AS VARCHAR)+')' FROM branchRatingSummary WHERE brDetailId=@brDetailId and riskCategory=@riskCategory)	
	SELECT top 1 @rating=rating,@score= CAST(dbo.ShowDecimal(score) AS VARCHAR) FROM agentRatingSummary WHERE arDetailId=@arDetailId and riskCategory=@riskCategory
	
	IF @rating is null
		SET @result=''
	ELSE
		BEGIN
		IF(@flag='merge')
		BEGIN
					SET @result=CASE @rating WHEN 'LOW' THEN '<span style="color:#008000;">'+@rating+' ('+@score+')'+ '</span>'
					WHEN 'A' THEN '<span style="color:#008000;">'+@rating+' ('+@score+')'+ '</span>'
					WHEN 'MEDIUM' THEN '<span style="color:#5d8aa8;">'+@rating+' ('+@score+')'+ '</span>'
					WHEN 'B' THEN '<span style="color:#5d8aa8;">'+@rating+' ('+@score+')'+ '</span>'
					WHEN 'HIGH' THEN '<span style="color:#fd5e53;">'+@rating+' ('+@score+')'+ '</span>'
					WHEN 'C' THEN '<span style="color:#fd5e53;">'+@rating+' ('+@score+')'+ '</span>'
					ELSE ''
					END	
		END
		ELSE IF (@flag='rating')
		BEGIN
			SET @result=@rating
		END
		END
		
	RETURN (@result)
end


GO
