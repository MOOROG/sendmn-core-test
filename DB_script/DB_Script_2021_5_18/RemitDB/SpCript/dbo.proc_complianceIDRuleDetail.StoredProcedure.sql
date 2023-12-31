USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_complianceIDRuleDetail]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @result1 VARCHAR(MAX)
EXEC proc_complianceIDRuleDetail 'bharat', 1, 10000, NULL, NULL, NULL, 1, NULL, 1, @result = @result1 OUTPUT
PRINT @result1

*/
CREATE proc [dbo].[proc_complianceIDRuleDetail]
		 @user				VARCHAR(50)		= NULL
		,@senId				INT				= NULL
		,@tAmt				MONEY			= NULL
		,@sourceOfFund		VARCHAR(100)	= NULL
		,@purposeOfRemit	VARCHAR(100)	= NULL
		,@relation			VARCHAR(100)	= NULL
		,@paymentMethod		INT				= NULL
		,@collMode			INT				= NULL
		,@masterId			INT				= NULL
		,@result			VARCHAR(MAX)	= NULL OUTPUT

AS
SET NOCOUNT ON
/*

*/
BEGIN
	DECLARE
		 @idTypePrim	INT
		,@idTypeSec		INT
		,@totalAmount	MONEY
		,@totalCount	INT
		
		,@cisAmount		MONEY
		,@cisCount		INT
		,@cisPeriod		INT
		,@detailId		INT
	
	SET @result = ''
	IF ISNULL(@masterId, 0) = 0
		RETURN
	
	SELECT @detailId = cisDetailId FROM cisDetail WHERE ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND cisMasterId = @masterId AND paymentMode = @paymentMethod AND collMode = @collMode
	IF @detailId IS NULL
		SELECT @detailId = cisDetailId FROM cisDetail WHERE ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND cisMasterId = @masterId AND paymentMode IS NULL AND collMode = @collMode
	IF @detailId IS NULL
		SELECT @detailId = cisDetailId FROM cisDetail WHERE ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND cisMasterId = @masterId AND paymentMode = @paymentMethod AND collMode IS NULL
	IF @detailId IS NULL
		SELECT @detailId = cisDetailId FROM cisDetail WHERE ISNULL(isDeleted, 'N') <> 'Y' AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isEnable, 'N') = 'Y' AND cisMasterId = @masterId AND paymentMode IS NULL AND collMode IS NULL

	IF @detailId IS NULL
		RETURN
		
	SELECT
		 @cisAmount = amount
		,@cisCount	= tranCount
		,@cisPeriod	= period
	FROM cisDetail WITH(NOLOCK)
	WHERE cisDetailId = @detailId
	
	SELECT 
		 @totalAmount	= ISNULL(SUM(tAmt), 0) + @tAmt
		,@totalCount	= COUNT(*) FROM 
		(
			SELECT id, tAmt FROM remitTran trn WITH(NOLOCK)
			INNER JOIN
			(
				SELECT tranId FROM tranSenders WITH(NOLOCK)
				WHERE customerId = @senId
			)sen ON trn.id = sen.tranId
			WHERE trn.approvedDate BETWEEN DATEADD(D, -@cisPeriod, GETDATE()) AND GETDATE() + '23:59:59'
		)x
	
	SELECT @idTypePrim = ci.idType FROM customerIdentity ci WITH(NOLOCK) WHERE customerId = @senId AND isPrimary = 'Y' AND ISNULL(isDeleted, 'N') <> 'Y'
	
	IF (@totalAmount >= @cisAmount OR @totalCount >= @cisCount)
	BEGIN
		SELECT 
			 msg = CASE WHEN (criteriaId = 5100 AND (ci.idType IS NULL OR ci.isPrimary <> 'Y')) THEN 'Primary ID ' + idType.detailTitle + ' Missing'
						WHEN (criteriaId = 5100 AND (ci.idType IS NULL OR ci.isPrimary <> 'Y' OR ci.validDate < GETDATE())) THEN 'Primary ID ' + idType.detailTitle + ' is expired'
						WHEN (criteriaId = 5101 AND (ci.idType IS NULL)) THEN 'Secondary ID ' + idType.detailTitle + ' Missing'
						WHEN (criteriaId = 5101 AND (ci.idType IS NULL OR ci.validDate < GETDATE())) THEN 'Secondary ID ' + idType.detailTitle + ' is expired'
						WHEN (criteriaId = 5102 AND @sourceOfFund IS NULL) THEN 'Source of Fund Field Missing'
						WHEN (criteriaId = 5103 AND @purposeOfRemit IS NULL) THEN 'Purpose Of Remittance Field Missing'
						WHEN (criteriaId = 5104 AND @relation IS NULL) THEN 'Relationship Field Missing' END
			INTO #tempMsg
		FROM cisCriteria cisc WITH(NOLOCK)
		LEFT JOIN customerIdentity ci WITH(NOLOCK) ON cisc.idTypeId = ci.idType AND ci.customerId = @senId
		LEFT JOIN staticDataValue idType WITH(NOLOCK) ON cisc.idTypeId = idType.valueId 
		WHERE cisDetailId = @detailId
		
		SELECT @result = COALESCE(@result, '') + ISNULL(msg + '\n', '') FROM #tempMsg
	END
	
END

GO
