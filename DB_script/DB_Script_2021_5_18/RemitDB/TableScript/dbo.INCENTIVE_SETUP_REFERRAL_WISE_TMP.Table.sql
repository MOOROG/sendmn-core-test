USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[INCENTIVE_SETUP_REFERRAL_WISE_TMP]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[INCENTIVE_SETUP_REFERRAL_WISE_TMP](
	[ROW_ID] [int] IDENTITY(1,1) NOT NULL,
	[REFERRAL_ID] [int] NOT NULL,
	[PARTNER_ID] [int] NOT NULL,
	[AGENT_ID] [int] NULL,
	[COMM_PCNT] [decimal](5, 2) NULL,
	[FX_PCNT] [decimal](5, 2) NULL,
	[FLAT_TXN_WISE] [money] NULL,
	[NEW_CUSTOMER] [money] NULL,
	[EFFECTIVE_FROM] [datetime] NULL,
	[IS_ACTIVE] [bit] NULL,
	[CREATED_BY] [varchar](80) NULL,
	[CREATED_DATE] [datetime] NULL
) ON [PRIMARY]
GO
