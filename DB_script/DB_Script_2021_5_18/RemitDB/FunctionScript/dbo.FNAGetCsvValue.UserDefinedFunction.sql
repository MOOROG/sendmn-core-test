USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetCsvValue]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  FUNCTION [dbo].[FNAGetCsvValue](
	 @Id		INT	
	,@flagId	INT
	,@user		VARCHAR(30)
)  
RETURNS VARCHAR(MAX)
AS  
BEGIN
	DECLARE @str VARCHAR(MAX)
	
	IF @flagId = 1000 -- compliance details criteria (criteriaId)
	BEGIN
		IF EXISTS(SELECT 'X' FROM csCriteriaHistory WITH(NOLOCK) WHERE csDetailId = @id AND @user = createdBy AND approvedBy IS NULL)
		BEGIN	
			SELECT
				@str = ISNULL(@str + ',', '') + CAST(cs.criteriaId AS VARCHAR)			
			 FROM csCriteriaHistory cs WITH(NOLOCK) 
			 WHERE cs.csDetailId = @id	
			 AND approvedBy IS NULL
			
		END
		ELSE
		BEGIN
			SELECT
				@str = ISNULL(@str + ',', '') + CAST(cs.criteriaId AS VARCHAR)			
			FROM csCriteria cs WITH(NOLOCK) 
			WHERE cs.csDetailId = @id		
		END
	END
	ELSE IF @flagId = 1001 -- Id setup details criteria (criteriaId)
	BEGIN
		IF EXISTS(SELECT 'X' FROM cisCriteriaHistory WITH(NOLOCK) WHERE cisDetailId = @id AND @user = createdBy AND approvedBy IS NULL)
		BEGIN	
			SELECT
				@str = ISNULL(@str + ',', '') + CAST(ISNULL(cs.criteriaId, 0) AS VARCHAR)
			 FROM (
				SELECT 
					sdv.valueId, sdv.detailTitle 
				FROM staticDataValue sdv WITH(NOLOCK) WHERE typeId = 5100
			 ) sdv
			 LEFT JOIN cisCriteriaHistory cs WITH(NOLOCK) ON sdv.valueId = cs.criteriaId
				AND cs.cisDetailId = @id	
				AND approvedBy IS NULL		
		END
		ELSE
		BEGIN
			SELECT
				@str = ISNULL(@str + ',', '') + CAST(ISNULL(cs.criteriaId, 0) AS VARCHAR)
			 FROM (
				SELECT 
					sdv.valueId, sdv.detailTitle 
				FROM staticDataValue sdv WITH(NOLOCK) WHERE typeId = 5100
			 ) sdv
			LEFT JOIN cisCriteria cs WITH(NOLOCK) ON sdv.valueId = cs.criteriaId
				AND cs.cisDetailId = @id		
		END
	END
	ELSE IF @flagId = 1002 -- Id setup details criteria (idTypeId)idTypeId
	BEGIN
		IF EXISTS(SELECT 'X' FROM cisCriteriaHistory WITH(NOLOCK) WHERE cisDetailId = @id AND @user = createdBy AND approvedBy IS NULL)
		BEGIN	
			SELECT
				@str = ISNULL(@str + ',', '') + CAST(ISNULL(cs.idTypeId, 0) AS VARCHAR)
			 FROM (
				SELECT 
					sdv.valueId, sdv.detailTitle 
				FROM staticDataValue sdv WITH(NOLOCK) WHERE typeId = 5100
			 ) sdv
			 LEFT JOIN cisCriteriaHistory cs WITH(NOLOCK) ON sdv.valueId = cs.criteriaId
				AND cs.cisDetailId = @id	
				AND approvedBy IS NULL		
		END
		ELSE
		BEGIN
			SELECT
				@str = ISNULL(@str + ',', '') + CAST(ISNULL(cs.idTypeId, 0) AS VARCHAR)
			 FROM (
				SELECT 
					sdv.valueId, sdv.detailTitle 
				FROM staticDataValue sdv WITH(NOLOCK) WHERE typeId = 5100
			 ) sdv
			LEFT JOIN cisCriteria cs WITH(NOLOCK) ON sdv.valueId = cs.criteriaId
				AND cs.cisDetailId = @id		
		END
	END
	
	
	RETURN @str
END	


GO
