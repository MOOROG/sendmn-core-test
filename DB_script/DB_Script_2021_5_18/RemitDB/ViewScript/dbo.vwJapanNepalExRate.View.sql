USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vwJapanNepalExRate]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwJapanNepalExRate]
AS

SELECT
	 [Sending Country]				= UPPER(ISNULL(cam.agentName, '[Anywhere]')) + ' - ' + ccm.countryName
	,[Receiving Country]			= pcm.countryName
	,[customer_rate]				= customerRate
	,[sending_cust_exchangeRate]	= cRate + ISNULL(cMargin, 0) + ISNULL(cHoMargin, 0) + ISNULL(cAgentMargin, 0)
	,[payout_agent_rate]			= pRate - ISNULL(pMargin, 0) - ISNULL(pHoMargin, 0) - ISNULL(pAgentMargin, 0)
FROM exRateTreasury ert WITH(NOLOCK)
LEFT JOIN countryMaster ccm WITH(NOLOCK) ON ert.cCountry = ccm.countryId
LEFT JOIN agentMaster cam WITH(NOLOCK) ON ert.cAgent = cam.agentId
LEFT JOIN countryMaster pcm WITH(NOLOCK) ON ert.pCountry = pcm.countryId
LEFT JOIN agentMaster pam WITH(NOLOCK) ON ert.pAgent = pam.agentId
WHERE cCountry = 113 AND ISNULL(ert.isActive, 'N') = 'Y'

GO
