USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetAgentRatingMaxScore]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetAgentRatingMaxScore](@flag varchar(25),@itemId INT,@batchId INT)  
RETURNS MONEY AS  
BEGIN 
	DECLARE  @result MONEY = 0
	IF @flag='preview'
	BEGIN
		--SELECT @batchId = batchid FROM dbo.agentRatingDetail WHERE ratingId = @arDetailId
		IF(ISNULL(@itemId,0) > 0 AND ISNULL(@batchId,0) > 0)
		BEGIN

			SELECT @result = MAX(score) FROM agentRating WHERE arMasterId = @itemId AND arDetailid IN(
				SELECT DISTINCT ratingId FROM dbo.agentRatingDetail WITH (NOLOCK) WHERE batchId = @batchId AND branchId IS NOT NULL)

		-- SELECT * FROM dbo.agentRatingMaster where rowId=72
		END
	END
	IF @flag='previewsummary'
	BEGIN
		
		IF(ISNULL(@itemId,0) > 0)
		BEGIN

			SELECT @result = MAX(score) FROM agentRatingSummary WHERE arMasterId = @itemId AND arDetailid IN(
				SELECT DISTINCT ratingId FROM dbo.agentRatingDetail WITH (NOLOCK) WHERE batchId = @batchId AND branchId IS NOT NULL)

		-- SELECT * FROM dbo.agentRatingMaster where rowId=72
		END
	END
	RETURN (@result)
end


GO
