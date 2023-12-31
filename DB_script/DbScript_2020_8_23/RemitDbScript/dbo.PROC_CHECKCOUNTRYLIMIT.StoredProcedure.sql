USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_CHECKCOUNTRYLIMIT]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[PROC_CHECKCOUNTRYLIMIT]
	@flag	VARCHAR(10)
	,@cAmt				MONEY		=	NULL
	,@pAmt				MONEY		=	NULL
	,@sCountryId		INT			=	NULL
	,@collMode			INT			=	NULL
	,@deliveryMethod	VARCHAR(30)	=	NULL
	,@sendingCustType	INT			=	NULL
	,@pCountryId		INT			=   NULL
	,@pCurr				VARCHAR(3)	=	NULL
	,@collCurr			VARCHAR(3)	=	NULL
	,@pAgent			INT			=	NULL
	,@sAgent			INT			=	NULL
	,@sBranch			INT			=	NULL
	,@msg				VARCHAR(50)	=	NULL	OUT
	,@errorCode			VARCHAR(5)	=	NULL	OUT

AS
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

BEGIN
	IF @flag = 's-limit'
	BEGIN
		DECLARE @cAmtUSD MONEY, @pAmtUSD MONEY, @definedCurr CHAR(3), @sCurrCostRate FLOAT, @sCurrHoMargin MONEY, @pCurrCostRate FLOAT, @pCurrHoMargin MONEY

		SELECT @definedCurr = currency 
		FROM sendTranLimit (NOLOCK)
		WHERE countryId = @sCountryId
		AND agentId IS NULL
		AND ( collMode = @collMode OR collMode IS NULL )
		AND ( tranType = @deliveryMethod OR tranType IS NULL )
		AND ( customerType = ISNULL(@sendingCustType,customerType) OR customerType IS NULL )
		AND ( receivingCountry = @pCountryId OR receivingCountry IS NULL )
		AND ISNULL(isActive, 'N') = 'Y'
		AND ISNULL(isDeleted, 'N') = 'N'

		IF @definedCurr IS NULL
		BEGIN
			SELECT @errorCode = 1, @msg = 'Country Sending limit is not defined or exceeds!'
			RETURN
		END

		IF @definedCurr <> @collCurr
		BEGIN
			SELECT 
				@sCurrCostRate			= sCurrCostRate
				,@sCurrHoMargin			= sCurrHoMargin
			FROM dbo.FNAGetExRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod)

			IF @sCurrCostRate IS NULL
			BEGIN
				SELECT @errorCode = '1', @msg = 'Transaction cannot be proceed. Exchange Rate not defined!'
				RETURN
			END
			
			SET @cAmtUSD = @cAmt / (@sCurrCostRate + ISNULL(@sCurrHoMargin, 0))
			SET @cAmt = @cAmtUSD
		END

		IF NOT EXISTS ( SELECT  'X'
					FROM    sendTranLimit WITH ( NOLOCK )
					WHERE   countryId = @sCountryId
					AND agentId IS NULL
					AND ( collMode = @collMode OR collMode IS NULL )
					AND ( tranType = @deliveryMethod OR tranType IS NULL )
					AND ( customerType = ISNULL(@sendingCustType,customerType) OR customerType IS NULL )
					AND ( receivingCountry = @pCountryId OR receivingCountry IS NULL )
					AND ISNULL(minLimitAmt, 0) <= @cAmt
					AND ISNULL(maxLimitAmt, 0) >= @cAmt
					AND ISNULL(isActive, 'N') = 'Y'
					AND ISNULL(isDeleted, 'N') = 'N')
		BEGIN
			SELECT @errorCode = '1', @msg = 'Country Sending limit is not defined or exceeds!'
			RETURN
		END
		ELSE
		BEGIN
			SELECT @errorCode = '0', @msg = 'Sending country per transaction limit verified!'
			RETURN
		END
	END
	IF @flag = 'r-limit'
	BEGIN
		--IF EXISTS ( SELECT  'X'
  --                  FROM    receiveTranLimit WITH ( NOLOCK )
  --                  WHERE   ISNULL(sendingCountry,
  --                                  ISNULL(@sCountryId, 0)) = ISNULL(@sCountryId,0)
  --                          AND countryId = @pCountryId
  --                          AND agentId = @pAgent
  --                          AND ISNULL(tranType, ISNULL(@deliveryMethod, 0)) = ISNULL(@deliveryMethod, 0)
  --                          AND ISNULL(isActive, 'N') = 'Y'
  --                          AND ISNULL(isDeleted, 'N') = 'N' )
  --      BEGIN
			
		--	SELECT  @definedCurr = currency 
		--	FROM receiveTranLimit WITH ( NOLOCK )
		--	WHERE ISNULL(sendingCountry,
  --                      ISNULL(@sCountryId, 0)) = ISNULL(@sCountryId,0)
  --          AND countryId = @pCountryId
  --          AND agentId = @pAgent
  --          AND ISNULL(tranType, ISNULL(@deliveryMethod, 0)) = ISNULL(@deliveryMethod, 0)
  --          AND ISNULL(isActive, 'N') = 'Y'
  --          AND ISNULL(isDeleted, 'N') = 'N'

		--	IF @definedCurr IS NULL
		--	BEGIN
		--		SELECT @errorCode = 1, @msg = 'Payout per transaction limit exceeded!'
		--		RETURN
		--	END

		--	IF @definedCurr <> @pCurr 
		--	BEGIN
		--		SELECT 
		--			@pCurrCostRate			= pCurrCostRate
		--			,@pCurrHoMargin			= pCurrHoMargin
		--		FROM dbo.FNAGetExRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod)

		--		SET @pAmtUSD = @pAmt / (@pCurrCostRate + @pCurrHoMargin)
		--		SET @pAmt = @pAmtUSD
		--	END

		--	IF EXISTS ( SELECT  'X'
		--				FROM receiveTranLimit WITH ( NOLOCK )
  --                      WHERE sendingCountry = @sCountryId
  --                      AND countryId = @pCountryId
  --                      AND ISNULL(agentId, 0) = ISNULL(@pAgent, 0)
  --                      AND tranType = ISNULL(@deliveryMethod, tranType)
  --                      AND @pAmt < maxLimitAmt
  --                      AND ISNULL(isActive, 'N') = 'Y'
		--				AND ISNULL(isDeleted, 'N') = 'N' )
  --          BEGIN
		--		SELECT @errorCode = '1', @msg = 'Payout per transaction limit exceeded!'
  --              RETURN;
  --          END;
		--	ELSE IF EXISTS ( SELECT  'X' 
		--				FROM receiveTranLimit WITH ( NOLOCK )
  --                      WHERE sendingCountry = @sCountryId
  --                      AND countryId = @pCountryId
  --                      AND agentId = @pAgent
  --                      AND tranType IS NULL
  --                      AND @pAmt > maxLimitAmt
  --                      AND ISNULL(isActive, 'N') = 'Y'
  --                      AND ISNULL(isDeleted, 'N') = 'N' )
  --          BEGIN
  --              SELECT @errorCode = '1', @msg = 'Payout per transaction limit exceeded!'
		--		RETURN;
  --          END;
		--	ELSE IF EXISTS ( SELECT  'X'
  --                      FROM receiveTranLimit WITH ( NOLOCK )
  --                      WHERE sendingCountry IS NULL
  --                      AND countryId = @pCountryId
  --                      AND agentId = @pAgent
  --                      AND currency = @pCurr
  --                      AND tranType = @deliveryMethod
  --                      AND @pAmt > maxLimitAmt
  --                      AND ISNULL(isActive, 'N') = 'Y'
  --                      AND ISNULL(isDeleted, 'N') = 'N' )
  --          BEGIN
  --              SELECT @errorCode = '1', @msg = 'Payout per transaction limit exceeded!'
		--		RETURN;
  --          END;
  --          ELSE IF EXISTS ( SELECT  'X'
  --                      FROM receiveTranLimit WITH ( NOLOCK )
  --                      WHERE sendingCountry IS NULL
  --                      AND countryId = @pCountryId
  --                      AND agentId = @pAgent
  --                      AND currency = @pCurr
		--				AND tranType IS NULL
  --                      AND @pAmt > maxLimitAmt
  --                      AND ISNULL(isActive, 'N') = 'Y'
  --                      AND ISNULL(isDeleted, 'N') = 'N' )
  --          BEGIN
		--		SELECT @errorCode = '1', @msg = 'Payout per transaction limit exceeded!'
		--		RETURN;
  --          END;
		--	ELSE
		--	BEGIN
		--		SELECT @errorCode = '0', @msg = 'Payout per transaction limit verified!'
		--		RETURN
		--	END
		--END
		IF EXISTS ( SELECT  'X'
                    FROM receiveTranLimit WITH ( NOLOCK )
                    WHERE ISNULL(sendingCountry,
									ISNULL(@sCountryId, 0)) = ISNULL(@sCountryId,0)
                    AND agentId IS NULL
					AND countryId = @pCountryId
                    AND ISNULL(tranType,ISNULL(@deliveryMethod,0)) = ISNULL(@deliveryMethod,0)
                    AND ISNULL(isActive, 'N') = 'Y'
                    AND ISNULL(isDeleted, 'N') = 'N' )
        BEGIN
			IF EXISTS(SELECT 1
					FROM receiveTranLimit WITH ( NOLOCK )
					WHERE ISNULL(sendingCountry,
								ISNULL(@sCountryId, 0)) = ISNULL(@sCountryId,0)
					AND countryId = @pCountryId
					AND agentId IS NULL
					AND ISNULL(tranType, ISNULL(@deliveryMethod, 0)) = ISNULL(@deliveryMethod, 0)
					AND currency = @pCurr
					AND ISNULL(isActive, 'N') = 'Y'
					AND ISNULL(isDeleted, 'N') = 'N')
			BEGIN
				IF NOT EXISTS (SELECT  'X'
                            FROM receiveTranLimit WITH ( NOLOCK )
                            WHERE ISNULL(sendingCountry,
											ISNULL(@sCountryId, 0)) = ISNULL(@sCountryId,0)
                            AND agentId IS NULL
							AND countryId = @pCountryId
							AND currency = @pCurr
                            AND ISNULL(tranType,ISNULL(@deliveryMethod,0)) = ISNULL(@deliveryMethod,0)
							AND maxLimitAmt >= @pAmt
                            AND ISNULL(isActive, 'N') = 'Y'
                            AND ISNULL(isDeleted, 'N') = 'N' )
				BEGIN
					SELECT @errorCode = '1', @msg = 'Payout per transaction limit exceeded!'
					RETURN;
				END;
				ELSE
				BEGIN
					SELECT @errorCode = '0', @msg = 'Payout per transaction limit verified!'
					RETURN
				END
			END
			ELSE IF EXISTS(SELECT 1
					FROM receiveTranLimit WITH ( NOLOCK )
					WHERE ISNULL(sendingCountry,
								ISNULL(@sCountryId, 0)) = ISNULL(@sCountryId,0)
					AND countryId = @pCountryId
					AND agentId IS NULL
					AND currency = 'USD'
					AND ISNULL(tranType, ISNULL(@deliveryMethod, 0)) = ISNULL(@deliveryMethod, 0)
					AND ISNULL(isActive, 'N') = 'Y'
					AND ISNULL(isDeleted, 'N') = 'N')
			BEGIN
				
				SELECT 
					@pCurrCostRate			= pCurrCostRate
					,@pCurrHoMargin			= pCurrHoMargin
				FROM dbo.FNAGetExRate(@sCountryId, @sAgent, @sBranch, @collCurr, @pCountryId, @pAgent, @pCurr, @deliveryMethod)

				SET @pAmtUSD = @pAmt / (@pCurrCostRate + ISNULL(@pCurrHoMargin, 0))

				IF NOT EXISTS (SELECT  'X'
								FROM receiveTranLimit WITH ( NOLOCK )
								WHERE ISNULL(sendingCountry,
												ISNULL(@sCountryId, 0)) = ISNULL(@sCountryId,0)
								AND agentId IS NULL
								AND countryId = @pCountryId
								AND currency = 'USD'
								AND ISNULL(tranType,ISNULL(@deliveryMethod,0)) = ISNULL(@deliveryMethod,0)
								AND maxLimitAmt >= @pAmtUSD
								AND ISNULL(isActive, 'N') = 'Y'
								AND ISNULL(isDeleted, 'N') = 'N' )
				BEGIN
					SELECT @errorCode = '1', @msg = 'Payout per transaction limit exceeded!'
					RETURN;
				END;
				ELSE
				BEGIN
					SELECT @errorCode = '0', @msg = 'Payout per transaction limit verified!'
					RETURN
				END
			END
			ELSE
			BEGIN
				SELECT @errorCode = '1', @msg = 'Payout per transaction limit exceeded!'
				RETURN;
			END
        END;
		ELSE
		BEGIN
			SELECT @errorCode = '1', @msg = 'Payout per transaction limit exceeded!'
            RETURN;
		END
	END
END


GO
