USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetAgentRatingUtilities]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetAgentRatingUtilities](@flag varchar(10),@batchId INT)  
RETURNS VARCHAR(50) AS  
BEGIN 
	DECLARE  @result VARCHAR(50) = ''

	-- New Logic: Check if rating completed for all branches or not.
	-- 1 means branch rating is completed. if rating is not completed then 0 will be assigned.

	DECLARE @labelStr VARCHAR(15)='Rating', @IsBranchRatingCompleted INT = 1 
	--SET @IsBranchRatingCompleted = 0
	--SET @type = 'preview'
	--SET @labelStr='Preview'

	IF @flag='gettype'
	BEGIN
		IF EXISTS(SELECT 'X' FROM dbo.agentRatingDetail WITH (NOLOCK) WHERE batchId = @batchId AND branchId IS NOT NULL AND ratingDate IS NULL)
		BEGIN
			SET @result='preview'
		END
		ELSE
			SET @result='rating'
	END
	ELSE IF @flag='getlabel'
	BEGIN
		IF EXISTS(SELECT 'X' FROM dbo.agentRatingDetail WITH (NOLOCK) WHERE batchId = @batchId AND branchId IS NOT NULL AND ratingDate IS NULL)
		BEGIN
			SET @result=''
		END
		ELSE
			SET @result='Rating'
	END
	RETURN (@result)
end


GO
