USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentExRateReport]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_agentExRateReport]') AND TYPE IN (N'P', N'PC'))
	 DROP PROCEDURE [dbo].proc_agentExRateReport
GO
*/
/*
	proc_spExRate @flag = 's', @user = 'admin', @sortBy = 'exRateTreasuryId', @sortOrder = 'ASC', @pageSize = '10', @pageNumber = '1'
*/
CREATE proc [dbo].[proc_agentExRateReport]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)
	,@branch							INT				= NULL
	,@agent								INT				= NULL
	,@country							INT				= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	IF @flag = 'exRateToday'				--Exchange Rate Today
	BEGIN
		
		SELECT
			 pCountryName = pcm.countryName
			,pCountryCode = pcm.countryCode
			,pAgentName = ISNULL(pam.agentName, '[Anywhere]')
			,ert.pCurrency
			,customerRate = ISNULL(ert.crossRateOperation, ert.customerRate) + ISNULL(erbw.premium, ert.premium) 
			,lastModifiedDate = COALESCE(erbw.modifiedDate, ert.modifiedDate, ert.createdDate)
		FROM exRateTreasury ert WITH(NOLOCK)
		LEFT JOIN exRateBranchWise erbw WITH(NOLOCK) ON ert.exRateTreasuryId = erbw.exRateTreasuryId AND erbw.cBranch = @branch AND ISNULL(erbw.isActive, 'N') = 'Y'
		INNER JOIN countryMaster pcm WITH(NOLOCK) ON ert.pCountry = pcm.countryId
		LEFT JOIN agentMaster pam WITH(NOLOCK) ON ert.pAgent = pam.agentId
		WHERE cCountry = @country AND cAgent = @agent AND ISNULL(ert.isActive, 'N') = 'Y'
		ORDER BY pCountryName, pAgentName
		
		/*
		SELECT
			 pCountryName = pcm.countryName
			,pCountryCode = pcm.countryCode
			,pAgent
			,pAgentName = ISNULL(pam.agentName, '[All]')
			,ert.pCurrency
			,customerRate = ISNULL(ert.crossRateOperation, ert.customerRate) + ISNULL(erbw.premium, ert.premium) 
			,lastModifiedDate = COALESCE(erbw.modifiedDate, ert.modifiedDate, ert.createdDate)
		INTO #exRateTemp
		FROM exRateTreasury ert WITH(NOLOCK)
		LEFT JOIN exRateBranchWise erbw WITH(NOLOCK) ON ert.exRateTreasuryId = erbw.exRateTreasuryId AND erbw.cBranch = @branch
		INNER JOIN countryMaster pcm WITH(NOLOCK) ON ert.pCountry = pcm.countryId
		LEFT JOIN agentMaster pam WITH(NOLOCK) ON ert.pAgent = pam.agentId
		WHERE cCountry = @country AND cAgent = @agent AND ISNULL(ert.isActive, 'N') = 'Y'
		ORDER BY pCountryName, pAgentName

		SELECT pCountryName, pCountryCode, pAgentId, pAgentName, pCurrency, customerRate, lastModifiedDate FROM
		(
			SELECT 
				 pCountryName		= agentCountry
				,pCountryCode		= cm.countryCode
				,pAgentId			= agentId
				,pAgentName			= agentName
				,pCurrency			= ert.pCurrency
				,customerRate		= ert.customerRate
				,lastModifiedDate	= ert.lastModifiedDate
			FROM #exRateTemp ert
			INNER JOIN agentMaster am ON ert.pCountryName = am.agentCountry AND ert.pAgent IS NULL AND am.agentType = 2903
			INNER JOIN countryMaster cm ON am.agentCountry = cm.countryName
			WHERE am.agentId NOT IN (SELECT ISNULL(pAgent, 0) FROM #exRateTemp)

			UNION ALL
			SELECT * FROM #exRateTemp WHERE pAgent IS NOT NULL
		)x ORDER BY pCountryName, pAgentName
		*/
	END
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, NULL
END CATCH

GO
